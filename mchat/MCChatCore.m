//
//  ChatClient.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CFNetwork/CFSocketStream.h>
//#include <sys/socket.h>
#include <netinet/in.h>
#import "MCChatCore.h"

#define BUF_SIZE 2048
#define MAX_RECEIVER_SIZE 2048*1024

#define kClientsField @"clients"
#define kClientField @"client"
#define kMessageTypeField @"type"
#define kVersionField @"version_int"
#define kToField @"to"
#define kMessageTypeWelcome @"welcome"
#define kMessageTypeUserConnected @"connected"
#define kMessageTypeUserDisconnected @"disconnected"
#define kMessageFromField @"from"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define VALID_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatCoreDelegate)]&&[obj respondsToSelector:sel])
#define MESSAGE_HAS_CLIENT_FIELD ([[message allKeys] indexOfObject:kClientField] != NSNotFound&& [message[kClientField] isKindOfClass:[NSString class]])

@interface MCChatCore ()
- (void)_closeStreamsAndClear;
- (void)_releaseStream;
- (void)_callOnErrorWithException:(NSException *)exception;
- (void)_sendMoreData;
- (void)_sendMessage:(NSDictionary *)meesage;
- (void)_closeStreamsAndCallDelegateWithException:(NSException *)exception;
- (void)_sendMoreDataAndControllExceptions;
- (MCChatCoreStatus)getStatus;
@end

@implementation MCChatCore
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSMutableData *received, *toSend;
    NSMutableArray *userList;
    MCChatCoreStatus currentStatus;
}

- (MCChatCoreStatus)getStatus
{
    LOG_SELECTOR()
    return currentStatus;
}

-(NSArray *)getUsers
{
    LOG_SELECTOR()
    return [userList copy];
}

- (void)processMessage:(NSDictionary *)message
{
    LOG_SELECTOR()
    if ([[message allKeys] indexOfObject:kMessageFromField] == NSNotFound) {
        if ([[message allKeys] indexOfObject:kMessageTypeField] == NSNotFound)
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no type field in system message" userInfo:nil] raise];
        if ([message[kMessageTypeField] isEqualToString:kMessageTypeWelcome]) {
            if (!(message[kVersionField]&&[message[kVersionField] isKindOfClass:[NSNumber class]]))
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid server version field in welcome message" userInfo:nil] raise];
            if (!(message[kClientsField]&&[message[kClientsField] isKindOfClass:[NSArray class]]))
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no clients field in welcome message" userInfo:nil] raise];
            [userList removeAllObjects];
            for (NSObject *obj in message[kClientsField]) {
                if (![obj isKindOfClass:[NSString class]])
                    [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Wrong format of clients field of welcome message" userInfo:nil] raise];
                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:(NSString *)obj];
                if (!uuid)
                    [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Wrong format of clients field of welcome message" userInfo:nil] raise];
                [userList addObject:uuid];
            }
            currentStatus = MCChatCoreConnected;
            if VALID_DELEGATE(self.delegate, @selector(connectedToServerVersion:forCore:))
                [self.delegate connectedToServerVersion:[message[kVersionField] longValue] forCore:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserConnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'connected' message" userInfo:nil] raise];
            NSUUID *client = [[NSUUID alloc] initWithUUIDString:message[@"client"]];
            if (!client)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'disconnected' message" userInfo:nil] raise];
            [userList addObject:client];
            if VALID_DELEGATE(self.delegate, @selector(userConnected:forCore:))
                [self.delegate userConnected:client forCore:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserDisconnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'disconnected' message" userInfo:nil] raise];
            NSUUID *client = [[NSUUID alloc] initWithUUIDString:message[@"client"]];
            if (!client)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'disconnected' message" userInfo:nil] raise];
            [userList removeObject:client];
            if VALID_DELEGATE(self.delegate, @selector(userConnected:forCore:))
                [self.delegate userDisconnected:client forCore:self];
        }
    } else {
        if (![message[kMessageFromField] isKindOfClass:[NSString class]])
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Invalid format of 'from' filed in the user message" userInfo:nil] raise];
        NSMutableDictionary *mutableMessage = [message mutableCopy];
        NSUUID *from  = [[NSUUID alloc] initWithUUIDString:message[kMessageFromField]];
        if (!from)
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Invalid format of 'from' filed in the user message" userInfo:nil] raise];
        [mutableMessage removeObjectForKey:kMessageFromField];
        if VALID_DELEGATE(self.delegate, @selector(messageRecieved:fromUser:forCore:))
            [self.delegate messageRecieved:mutableMessage
                                  fromUser:from
                                   forCore:self];
        
    }
}

-(void)bytesRead:(void *)bytes
          length:(CFIndex)bytesRead
{
    LOG_SELECTOR()
    @try {
        [received appendBytes:bytes
                       length:bytesRead];
        NSData *pattern = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
        NSRange range = [received rangeOfData:pattern options:0 range:NSMakeRange(0, received.length)];
        while (range.location != NSNotFound) {
            NSData *encodedMessageData = [received subdataWithRange:NSMakeRange(0, range.location)];
            NSData *messageData = [[NSData alloc] initWithBase64EncodedData:encodedMessageData options:0];
            if (!messageData)
                [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package format error" userInfo:nil] raise];
            NSError *error;
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
            if (error||!message||(![message isKindOfClass:[NSDictionary class]]))
                [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package format error" userInfo:nil] raise];
            @try {
                [self processMessage:message];
            }
            @catch (NSException *exception) {
                [self _callOnErrorWithException:exception];
            }
            @finally {
                if (received.length >= range.location + range.length) {
                    [received replaceBytesInRange:NSMakeRange(0, range.location + range.length) withBytes:NULL length:0];
                    range = [received rangeOfData:pattern options:0 range:NSMakeRange(0, received.length)];
                } else {
                    return;
                }
            }
        }
        if ([received length] > MAX_RECEIVER_SIZE)
            [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package too long" userInfo:nil] raise];
    }
    @catch (NSException *exception) {
        [self _closeStreamsAndCallDelegateWithException:exception];
    }
    
}

int configureSocket(CFSocketNativeHandle handle)
{
    int enable = 1;
    int result = setsockopt(handle, SOL_SOCKET, SO_KEEPALIVE, &enable, sizeof(enable));
//    int count = 20;
//    result |=  setsockopt(handle, IPPROTO_TCP, TCP_KEEPCNT, &count, sizeof(count));
//    //result |=  setsockopt(handle, IPPROTO_TCP, TCP_KEEPIDLE, 180, 4) = 0;
//    int interval = 60;
//    result |=  setsockopt(handle, IPPROTO_TCP, TCP_KEEPINTVL, &interval, sizeof(interval));
    return result;
}

void readcb(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
    @autoreleasepool {
        MCChatCore * chatCore = (__bridge MCChatCore *)clientCallBackInfo;
        switch(eventType) {
            case kCFStreamEventOpenCompleted:
                NSLog(@"Read stream open completed");
                CFDataRef socketData = CFReadStreamCopyProperty(stream, kCFStreamPropertySocketNativeHandle);
                if (socketData) {
                    CFSocketNativeHandle handle;
                    CFDataGetBytes(socketData, CFRangeMake(0, sizeof(CFSocketNativeHandle)), (UInt8 *)&handle);
                    CFRelease(socketData);
                    if (configureSocket(handle) != 0)
                        [chatCore _closeStreamsAndCallDelegateWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:@"Failed to configure socket" userInfo:nil]];
                } else {
                    [chatCore _closeStreamsAndCallDelegateWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:@"Failed to get socket from stream" userInfo:nil]];
                }
                break;
            case kCFStreamEventHasBytesAvailable:{
                NSLog(@"Read stream has bytes available");
                UInt8 buf[BUF_SIZE];
                CFIndex bytesRead = CFReadStreamRead(stream, buf, BUF_SIZE);
                NSLog(@"Received %ld bytes", bytesRead);
                if (bytesRead >= 0) {
                    [chatCore bytesRead:buf length:bytesRead];
                } else {
                    CFErrorRef err = CFReadStreamCopyError(stream);
                    CFStringRef desc = CFErrorCopyDescription(err);
                    [chatCore _closeStreamsAndCallDelegateWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:nil]];
                    CFRelease(err);
                    CFRelease(desc);
                }
                break;
            }
            case kCFStreamEventErrorOccurred: {
                NSLog(@"Read stream error occurred");
                CFErrorRef err = CFReadStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                [chatCore _closeStreamsAndCallDelegateWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:nil]];
                CFRelease(err);
                CFRelease(desc);
                break;
            }
            case kCFStreamEventEndEncountered:
                NSLog(@"Read stream end encountered");
                [chatCore _closeStreamsAndCallDelegateWithException:nil];
                break;
            default:
                break;
        }
    }
}

void writecb( CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo )
{
    @autoreleasepool {
        MCChatCore * chatCore = (__bridge MCChatCore *)clientCallBackInfo;
        switch(eventType) {
            case kCFStreamEventCanAcceptBytes:
                NSLog(@"Write stream can accept bytes");
                [chatCore _sendMoreDataAndControllExceptions];
                break;
            case kCFStreamEventErrorOccurred:
                NSLog(@"Write stream error occurred");
                CFErrorRef err = CFWriteStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                [chatCore _closeStreamsAndCallDelegateWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:nil]];
                CFRelease(err);
                CFRelease(desc);
                break;
            case kCFStreamEventOpenCompleted:
                NSLog(@"Write stream open completed");
                
                break;
            case kCFStreamEventEndEncountered:
                NSLog(@"Write stream end encountered");
                [chatCore _closeStreamsAndCallDelegateWithException:nil];
                break;
            default:
                break;
        }
    }
}



- (instancetype)init;
{
    LOG_SELECTOR()
    if (self = [super init]) {
        currentStatus = MCChatCoreNotConnected;
        userList = [[NSMutableArray alloc] init];
        toSend = [[NSMutableData alloc] init];
        received = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)connect
{
    LOG_SELECTOR()
    
    if (!(readStream || writeStream)) {
        currentStatus = MCChatCoreConnecting;
        if (received.length > 0)
            [received replaceBytesInRange:NSMakeRange(0, received.length) withBytes:NULL length:0];
        if (toSend.length > 0)
            [toSend replaceBytesInRange:NSMakeRange(0, toSend.length) withBytes:NULL length:0];
        static NSString *hostString = @"52.17.115.151";
        //                static NSString *hostString = @"localhost";
        CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostString);
        CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, 9000, &readStream, &writeStream);
        CFRelease(host);
        CFStreamClientContext clientContext = {
            0,
            (__bridge void *)(self),
            (void *(*)(void *info))CFRetain,
            (void (*)(void *info))CFRelease,
            (CFStringRef (*)(void *info))CFCopyDescription
        };
        
        static CFOptionFlags readStreamEvents = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable;
        static CFOptionFlags writeStreamEvents = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes;
        
        if (!(CFReadStreamSetClient(readStream, readStreamEvents, readcb, &clientContext)&&CFWriteStreamSetClient(writeStream, writeStreamEvents, writecb, &clientContext))) {
            [self _releaseStream];
            return NO;
        }
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        if (!(CFReadStreamOpen(readStream)&&CFWriteStreamOpen(writeStream))) {
            [self _closeStreamsAndClear];
            return NO;
        }
        return YES;
    } else
        return YES;
    
}

- (void)_sendMessage:(NSDictionary *)message
{
    LOG_SELECTOR()
    
    if (writeStream) {
        CFStreamStatus streamStatus = CFWriteStreamGetStatus(writeStream);
        if (streamStatus == kCFStreamStatusOpen||streamStatus == kCFStreamStatusWriting) {
            NSError *err;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:&err];
            if (err||!jsonData)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Failed while moving message to json" userInfo:nil] raise];
            NSMutableString *base64String = [[jsonData base64EncodedStringWithOptions:kNilOptions] mutableCopy];
            [base64String appendString:@"\r\n"];
            NSData *base64Data = [base64String dataUsingEncoding:NSASCIIStringEncoding];
            [toSend appendData:base64Data];
            if (CFWriteStreamCanAcceptBytes(writeStream)) {
                [self _sendMoreData];
            }
        } else {
            [[NSException exceptionWithName:LOWLEVEL_ERROR reason:@"Write stream is not in good state" userInfo:nil] raise];
        }
        
    }
    
}

- (void)_sendMoreDataAndControllExceptions
{
    LOG_SELECTOR()
    @try {
        [self _sendMoreData];
    }
    @catch (NSException *exception) {
        [self _closeStreamsAndCallDelegateWithException:exception];
    }
}

- (void)_sendMoreData
{
    LOG_SELECTOR();
    NSUInteger length = [toSend length];
    if (length <= 0)
        return;
    UInt8 buf[BUF_SIZE];
    CFIndex bytesToSend = MIN(length, BUF_SIZE);
    [toSend getBytes:&buf length:bytesToSend];
    CFIndex sent = CFWriteStreamWrite(writeStream, buf, bytesToSend);
    if (sent >= 0) {
        NSLog(@"%ld bytes sent", sent);
        [toSend replaceBytesInRange:NSMakeRange(0, sent) withBytes:NULL length:0];
    } else {
        CFErrorRef err = CFWriteStreamCopyError(writeStream);
        CFStringRef desc = CFErrorCopyDescription(err);
        [[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:nil] raise];
    }
}

- (void)_releaseStream
{
    LOG_SELECTOR()
    currentStatus = MCChatCoreNotConnected;
    if (readStream) {
        CFRelease(readStream);
        readStream = NULL;
    }
    if (writeStream) {
        CFRelease(writeStream);
        writeStream = NULL;
    }
}

- (void)_closeStreamsAndClear
{
    LOG_SELECTOR()
    currentStatus = MCChatCoreNotConnected;
    if (readStream) {
        if (CFReadStreamGetStatus(readStream) != kCFStreamStatusClosed)
            CFReadStreamClose(readStream);
        CFRelease(readStream);
        readStream = NULL;
    }
    if (writeStream) {
        if (CFWriteStreamGetStatus(writeStream) != kCFStreamStatusClosed)
            CFWriteStreamClose(writeStream);
        CFRelease(writeStream);
        writeStream = NULL;
    }
    [userList removeAllObjects];
    if (received.length > 0)
        [received replaceBytesInRange:NSMakeRange(0, received.length) withBytes:NULL length:0];
    if (toSend.length > 0)
        [toSend replaceBytesInRange:NSMakeRange(0, toSend.length) withBytes:NULL length:0];
}

- (void)_callOnErrorWithException:(NSException *)exception
{
    LOG_SELECTOR()
    NSObject<MCChatCoreDelegate> *d = self.delegate;
    if VALID_DELEGATE(d, @selector(exception:withReason:forCore:))
        [d exception:exception.name withReason:exception.reason forCore:self];
}


- (void)_closeStreamsAndCallDelegateWithException:(NSException *)exception;
{
    LOG_SELECTOR()
    [self _closeStreamsAndClear];
    if VALID_DELEGATE(self.delegate, @selector(disconnectedBecauseOfException:withReason:forCore:)) {
        if (!exception)
            [self.delegate disconnectedBecauseOfException:nil withReason:nil forCore:self];
        else
            [self.delegate disconnectedBecauseOfException:exception.name withReason:exception.reason forCore:self];
    }
}


- (void)disconnect
{
    LOG_SELECTOR()
    if (readStream&&writeStream)
        [self _closeStreamsAndCallDelegateWithException:nil];
}

- (void)sendMessage:(NSDictionary *)message
             toUser:(NSUUID *)user
{
    LOG_SELECTOR()
    if (!(message&&user&&[message isKindOfClass:[NSDictionary class]]&&[user isKindOfClass:[NSUUID class]]))
        [[NSException exceptionWithName:ERRONOUS_PARAMETERS reason:@"Invalid parameters passed" userInfo:nil] raise];
    NSMutableDictionary *mutableMessage = [message mutableCopy];
    [mutableMessage setObject:@[[user UUIDString]] forKey:kToField];
    [self _sendMessage:mutableMessage];
}

- (void)sendBroadcastMessage:(NSDictionary *)message
{
    LOG_SELECTOR()
    [self sendMessage:message
              toUsers:self.users];
}

- (void)sendMessage:(NSDictionary *)message
            toUsers:(NSArray *)users
{
    LOG_SELECTOR()
    if (!(message&&users&&[message isKindOfClass:[NSDictionary class]]&&[users isKindOfClass:[NSArray class]]))
        [[NSException exceptionWithName:ERRONOUS_PARAMETERS reason:@"Invalid parameters passed" userInfo:nil] raise];
    NSMutableArray *strUsers = [[NSMutableArray alloc] init];
    for (NSObject *obj in users) {
        if (![obj isKindOfClass:[NSUUID class]])
            [[NSException exceptionWithName:ERRONOUS_PARAMETERS reason:@"Invalid parameters passed" userInfo:nil] raise];
        [strUsers addObject:[(NSUUID*)obj UUIDString]];
    }
    NSMutableDictionary *mutableMessage = [message mutableCopy];
    [mutableMessage setObject:strUsers forKey:kToField];
    [self _sendMessage:mutableMessage];
}

@end
