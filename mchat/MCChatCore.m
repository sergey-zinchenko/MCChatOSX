//
//  ChatClient.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CFNetwork/CFSocketStream.h>
#import "MCChatCore.h"

#define BUF_SIZE 2048
#define MAX_RECEIVER_SIZE 2048*1024

#define kClientsField @"clients"
#define kClientField @"client"
#define kMessageTypeField @"type"
#define kVersionField @"version_int"
#define kMessageTypeWelcome @"welcome"
#define kMessageTypeUserConnected @"connected"
#define kMessageTypeUserDisconnected @"disconnected"
#define kMessageFromField @"from"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define VALID_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatCoreDelegate)]&&[obj respondsToSelector:sel])
#define MESSAGE_HAS_CLIENT_FIELD ([[message allKeys] indexOfObject:kClientField] != NSNotFound&& [message[kClientField] isKindOfClass:[NSString class]])

@interface MCChatCore ()
- (void)_closeStreamsAndClearBuffers;
- (void)_releaseStream;
- (void)_callOnErrorWithException:(NSException *)exception;
- (void)_sendMoreData;
@end

@implementation MCChatCore
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSMutableData *received, *toSend;
    NSObject *connectionLock;
    NSMutableArray *userList;
}

-(NSArray *)getUsers
{
    return [userList copy];
}

- (void)processMessage:(NSDictionary *)message
{
    LOG_SELECTOR()
    if ([[message allKeys] indexOfObject:kMessageFromField] == NSNotFound) {
        if ([[message allKeys] indexOfObject:kMessageTypeField] == NSNotFound)
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no type field in system message" userInfo:NULL] raise];
        if ([message[kMessageTypeField] isEqualToString:kMessageTypeWelcome]) {
            if (!(message[kClientsField]&&[message[kClientsField] isKindOfClass:[NSArray class]]))
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no clients field in welcome message" userInfo:NULL] raise];
            for (NSObject *obj in message[kClientsField])
                if (![obj isKindOfClass:[NSString class]])
                    [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Wrong format of clients field of welcome message" userInfo:NULL] raise];
            if (!(message[kVersionField]&&[message[kVersionField] isKindOfClass:[NSNumber class]]))
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid server version field in welcome message" userInfo:NULL] raise];
            [userList removeAllObjects];
            [userList addObjectsFromArray:message[kClientsField]];
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if VALID_DELEGATE(d, @selector(connectedToServerVersion:forCore:))
                [d connectedToServerVersion:[message[kVersionField] longValue] forCore:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserConnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'connected' message" userInfo:NULL] raise];
            [userList addObject:message[@"client"]];
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if VALID_DELEGATE(d, @selector(userConnected:forCore:))
                [d userConnected:message[@"client"] forCore:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserDisconnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'disconnected' message" userInfo:NULL] raise];
            [userList removeObject:message[@"client"]];
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if VALID_DELEGATE(d, @selector(userConnected:forCore:))
                [d userDisconnected:message[@"client"] forCore:self];
        }
    } else {
        if (![message[kMessageFromField] isKindOfClass:[NSString class]])
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Invalid format of 'from' filed in the user message" userInfo:NULL] raise];
        NSMutableDictionary *mutableMessage = [message mutableCopy];
        NSString *from  = message[kMessageFromField];
        [mutableMessage removeObjectForKey:kMessageFromField];
        NSObject<MCChatCoreDelegate> *d = self.delegate;
        if VALID_DELEGATE(d, @selector(messageRecieved:fromUser:forCore:))
            [d messageRecieved:mutableMessage
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
                [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package format error" userInfo:NULL] raise];
            NSError *error;
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
            if (error||!message||(![message isKindOfClass:[NSDictionary class]]))
                [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package format error" userInfo:NULL] raise];
            [self processMessage:message];
            [received replaceBytesInRange:NSMakeRange(0, range.location + range.length) withBytes:NULL length:0];
            range = [received rangeOfData:pattern options:0 range:NSMakeRange(0, received.length)];
        }
        if ([received length] > MAX_RECEIVER_SIZE)
            [[NSException exceptionWithName:ERRONOUS_MESSAGE_PACKAGE reason:@"Message package too long" userInfo:NULL] raise];
    }
    @catch (NSException *exception) {
        [self _callOnErrorWithException:exception];
    }
    
}


void readcb(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
    @autoreleasepool {
        MCChatCore * chatCore = (__bridge MCChatCore *)clientCallBackInfo;
        switch(eventType) {
            case kCFStreamEventOpenCompleted:
                NSLog(@"Read stream open completed");
                break;
            case kCFStreamEventHasBytesAvailable:{
                NSLog(@"Read stream has bytes available");
                UInt8 buf[BUF_SIZE];
                CFIndex bytesRead = CFReadStreamRead(stream, buf, BUF_SIZE);
                NSLog(@"Received %ld bytes", bytesRead);
                if (bytesRead > 0) {
                    [chatCore bytesRead:buf length:bytesRead];
                }
                break;
            }
            case kCFStreamEventErrorOccurred: {
                NSLog(@"Read stream error occurred");
                CFErrorRef err = CFReadStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                [chatCore _callOnErrorWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:NULL]];
                break;
            }
            case kCFStreamEventEndEncountered:
                NSLog(@"Read stream end encountered");
                [chatCore _closeStreamsAndClearBuffers];
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
                [chatCore _sendMoreData];
                break;
            case kCFStreamEventErrorOccurred:
                NSLog(@"Write stream error occurred");
                CFErrorRef err = CFWriteStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                [chatCore _callOnErrorWithException:[NSException exceptionWithName:LOWLEVEL_ERROR reason:(__bridge NSString *)(desc) userInfo:NULL]];
                break;
            case kCFStreamEventOpenCompleted:
                NSLog(@"Write stream open completed");
                
                break;
            case kCFStreamEventEndEncountered:
                NSLog(@"Write stream end encountered");
                [chatCore _closeStreamsAndClearBuffers];
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
        userList = [[NSMutableArray alloc] init];
        connectionLock = [[NSObject alloc] init];
        toSend = [[NSMutableData alloc] init];
        received = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)connect
{
    LOG_SELECTOR()
    @synchronized (connectionLock) {
        if (!(readStream || writeStream)) {
            if (received.length > 0)
                [received replaceBytesInRange:NSMakeRange(0, received.length) withBytes:NULL length:0];
            if (toSend.length > 0)
                [toSend replaceBytesInRange:NSMakeRange(0, toSend.length) withBytes:NULL length:0];
            static NSString *hostString = @"52.17.115.151";
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
                [self _closeStreamsAndClearBuffers];
            }
            return YES;
        } else
            return YES;
    }
}

- (void)sendMessage:(NSDictionary *)message
{
    LOG_SELECTOR()
    @synchronized (connectionLock) {
        if (writeStream) {
            CFStreamStatus streamStatus = CFWriteStreamGetStatus(writeStream);
            if (streamStatus == kCFStreamStatusOpen||streamStatus == kCFStreamStatusWriting) {
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:&err];
                NSMutableString *base64String = [[jsonData base64EncodedStringWithOptions:kNilOptions] mutableCopy];
                [base64String appendString:@"\r\n"];
                NSData *base64Data = [base64String dataUsingEncoding:NSASCIIStringEncoding];
                [toSend appendData:base64Data];
                if (CFWriteStreamCanAcceptBytes(writeStream)) {
                    [self _sendMoreData];
                }
            }
            
        }
    }
}

- (void)_sendMoreData
{
    LOG_SELECTOR();
    NSUInteger length = [toSend length];
    if (length > 0) {
        UInt8 buf[BUF_SIZE];
        CFIndex bytesToSend = MIN(length, BUF_SIZE);
        [toSend getBytes:&buf length:bytesToSend];
        CFIndex sent = CFWriteStreamWrite(writeStream, buf, bytesToSend);
        if (sent > 0) {
            NSLog(@"%ld bytes sent", sent);
            [toSend replaceBytesInRange:NSMakeRange(0, sent) withBytes:NULL length:0];
        }
    }
}

- (void)_releaseStream
{
    LOG_SELECTOR()
    if (readStream) {
        CFRelease(readStream);
        readStream = NULL;
    }
    if (writeStream) {
        CFRelease(writeStream);
        writeStream = NULL;
    }
}

- (void)_closeStreamsAndClearBuffers
{
    LOG_SELECTOR()
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
}

- (void)_callOnErrorWithException:(NSException *)exception
{
    LOG_SELECTOR()
    [self _closeStreamsAndClearBuffers];
    NSObject<MCChatCoreDelegate> *d = self.delegate;
    if VALID_DELEGATE(d, @selector(exception:withReason:forCore:))
        [d exception:exception.name withReason:exception.reason forCore:self];
}

- (void)disconnect
{
    LOG_SELECTOR()
    @synchronized (connectionLock) {
        [self _closeStreamsAndClearBuffers];
    }
}

@end
