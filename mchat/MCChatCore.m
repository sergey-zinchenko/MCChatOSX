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

@interface MCChatCore ()
- (void)_closeStreams;
- (void)_releaseStream;
@end

@implementation MCChatCore
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSMutableData *received, *toSend;
    NSObject *connectionLock;
}

- (void)processMessage:(NSDictionary *)message
{
    if ([[message allKeys] indexOfObject:@"type"] != NSNotFound) {
        if ([[message objectForKey:@"type"] isEqualToString:@"welcome"]) {
            NSObject<MCChatCoreDelegate> *d = self.delegate;
            if (d&&[d conformsToProtocol:@protocol(MCChatCoreDelegate)]&&[d respondsToSelector:@selector(connectedToServerVersion:forClient:)]) {
                [d connectedToServerVersion:[message[@"version_int"] longValue] forClient:self];
            }
        } else if ([[message objectForKey:@"type"] isEqualToString:@"connected"]) {
            
        } else if ([[message objectForKey:@"type"] isEqualToString:@"disconnected"]) {
            
        } else {
            
        }
    }
}

-(void)bytesRead:(void *)bytes
          length:(CFIndex)bytesRead
{
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
        switch(eventType) {
            case kCFStreamEventOpenCompleted:
                NSLog(@"Read stream open completed");
                break;
            case kCFStreamEventHasBytesAvailable:{
                NSLog(@"Read stream has bytes available");
                UInt8 buf[BUF_SIZE];
                CFIndex bytesRead = CFReadStreamRead(stream, buf, BUF_SIZE);
                if (bytesRead > 0) {
                    [(__bridge MCChatCore *)clientCallBackInfo bytesRead:buf length:bytesRead];
                }
                break;
            }
            case kCFStreamEventErrorOccurred: {
                NSLog(@"Read stream error occurred");
                //                CFErrorRef err = CFReadStreamCopyError(stream);
                //                CFStringRef desc = CFErrorCopyDescription(err);
                //                CFStreamStatus status = CFReadStreamGetStatus(stream);
                //
                //                NSLog(@"%@", desc);
                break;
            }
            case kCFStreamEventEndEncountered:
                NSLog(@"Read stream end encountered");
                break;
            default:
                break;
        }
        
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
    if (self = [super init]) {
        connectionLock = [[NSObject alloc] init];
        toSend = [[NSMutableData alloc] init];
        received = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)connect
{
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
                [self _closeStreams];
            }
            return YES;
        } else
            return YES;
    }
}

- (void)sendMessage:(NSDictionary *)message
{
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
    if (readStream) {
        CFRelease(readStream);
        readStream = NULL;
    }
    if (writeStream) {
        CFRelease(writeStream);
        writeStream = NULL;
    }
}

- (void)_closeStreams
{
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
    
}

- (void)disconnect
{
    @synchronized (connectionLock) {
        [self _closeStreams];
    }
}

@end
