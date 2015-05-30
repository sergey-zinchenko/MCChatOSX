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

#define BUF_SIZE 4096

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
            if VALID_DELEGATE(d, @selector(connectedToServerVersion:forClient:))
                [d connectedToServerVersion:[message[kVersionField] longValue] forClient:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserConnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'connected' message" userInfo:NULL] raise];
            [userList addObject:message[@"client"]];
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if VALID_DELEGATE(d, @selector(userConnected:forClient:))
                [d userConnected:message[@"client"] forClient:self];
        } else if ([message[kMessageTypeField] isEqualToString:kMessageTypeUserDisconnected]) {
            if (!MESSAGE_HAS_CLIENT_FIELD)
                [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"There is no valid client filed in 'disconnected' message" userInfo:NULL] raise];
            [userList removeObject:message[@"client"]];
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if VALID_DELEGATE(d, @selector(userConnected:forClient:))
                [d userDisconnected:message[@"client"] forClient:self];
        }
    } else {
        if (![message[kMessageFromField] isKindOfClass:[NSString class]])
            [[NSException exceptionWithName:MESSAGE_FORMAT_EXCEPTION reason:@"Invalid format of 'from' filed in the user message" userInfo:NULL] raise];
        NSMutableDictionary *mutableMessage = [message mutableCopy];
        NSString *from  = message[kMessageFromField];
        [mutableMessage removeObjectForKey:kMessageFromField];
        NSObject<MCChatCoreDelegate> *d = self.delegate;
        if VALID_DELEGATE(d, @selector(messageRecieved:fromUser:forClient:))
            [d messageRecieved:mutableMessage
                      fromUser:from
                     forClient:self];
        
    }
}

-(void)bytesRead:(void *)bytes
          length:(CFIndex)bytesRead
{
    LOG_SELECTOR()
    [received appendBytes:bytes
                   length:bytesRead];
    NSData *pattern = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange range = [received rangeOfData:pattern options:0 range:NSMakeRange(0, received.length)];
    while (range.location != NSNotFound) {
        NSData *encodedMessageData = [received subdataWithRange:NSMakeRange(0, range.location)];
        NSData *messageData = [[NSData alloc] initWithBase64EncodedData:encodedMessageData options:0];
        if (messageData) {
            NSError *error;
            NSDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
            if (!error&&message&&([message isKindOfClass:[NSDictionary class]]))
                [self processMessage:message];
        }
        [received replaceBytesInRange:NSMakeRange(0, range.location + range.length) withBytes:NULL length:0];
        range = [received rangeOfData:pattern options:0 range:NSMakeRange(0, received.length)];
    }
}


void readcb(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
    @autoreleasepool {
        // @try {
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
                    [(__bridge MCChatCore *)clientCallBackInfo bytesRead:buf length:bytesRead];
                }
                break;
            }
            case kCFStreamEventErrorOccurred: {
                NSLog(@"Read stream error occurred");
                CFErrorRef err = CFReadStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                CFStreamStatus status = CFReadStreamGetStatus(stream);
                
                NSLog(@"%@", desc);
                
                
                break;
            }
            case kCFStreamEventEndEncountered:
                NSLog(@"Read stream end encountered");
                break;
            default:
                break;
        }
        //  } @catch (NSException * e) {
        //       NSLog(@"exception ->>>> %@", e);
        //   }
        
        
        
    }
}

void writecb( CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo )
{
    @autoreleasepool {
        switch(eventType) {
            case kCFStreamEventCanAcceptBytes:
                NSLog(@"Write stream can accept bytes");
                
                //CFWriteStreamWrite(stream, const UInt8 *buffer, <#CFIndex bufferLength#>)
                break;
            case kCFStreamEventErrorOccurred:
                NSLog(@"Write stream error occurred");
                CFErrorRef err = CFWriteStreamCopyError(stream);
                CFStringRef desc = CFErrorCopyDescription(err);
                CFStreamStatus status = CFWriteStreamGetStatus(stream);
                
                NSLog(@"%@", desc);
                break;
            case kCFStreamEventOpenCompleted:
                NSLog(@"Write stream open completed");
                
                break;
            case kCFStreamEventEndEncountered:
                NSLog(@"Write stream end encountered");
                
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
                    UInt8 buf[BUF_SIZE];
                    CFIndex len = MIN([toSend length], BUF_SIZE);
                    [toSend getBytes:&buf length:BUF_SIZE];
                    CFIndex writed = CFWriteStreamWrite(writeStream, buf, len);
                    NSLog(@"%ld", writed);
                }
            }
            
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
    [received replaceBytesInRange:NSMakeRange(0, received.length - 1) withBytes:NULL length:0];
    [toSend replaceBytesInRange:NSMakeRange(0, toSend.length - 1) withBytes:NULL length:0];
    [userList removeAllObjects];
}

- (void)disconnect
{
    LOG_SELECTOR()
    @synchronized (connectionLock) {
        [self _closeStreamsAndClearBuffers];
    }
}

@end
