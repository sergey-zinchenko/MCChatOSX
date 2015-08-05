//
//  SoundEffects.m
//  MChat
//
//  Created by Сергей Зинченко on 05.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "SoundEffects.h"

@interface SoundEffects ()
-(void)playSound:(NSString *)sound;
@end

@implementation SoundEffects
{
    AVAudioPlayer *player;
    NSDate *previousEnd;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p
                       successfully:(BOOL)flag
{
    player = nil;
    previousEnd = [NSDate date];
}

-(void)playSound:(NSString *)sound
{
    BOOL intervalOk = (!previousEnd)||fabs([previousEnd timeIntervalSinceNow]) > 1;
    if (intervalOk&&!player) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:sound];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                        error:nil];
        player.delegate = self;
        [player play];
    }
}

- (void)playUserSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"user-sound"
                                    ofType:@"mp3"];
    [self playSound:soundFilePath];
}

- (void)playChatSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"chat-sound"
                                    ofType:@"mp3"];
    [self playSound:soundFilePath];
}

- (void)playChatEventSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"chat-event-sound"
                                    ofType:@"mp3"];
    [self playSound:soundFilePath];
}

- (void)playMessageSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"message-sound"
                                    ofType:@"mp3"];
    [self playSound:soundFilePath];
}

+ (SoundEffects *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[SoundEffects alloc] init];
    });
    return sharedInstance;
}

+ (void)playUserSound
{
    [[SoundEffects sharedInstance] playUserSound];
}

+ (void)playChatSound
{
    [[SoundEffects sharedInstance] playChatSound];
}

+ (void)playChatEventSound
{
    [[SoundEffects sharedInstance] playChatEventSound];
}

+ (void)playMessageSound
{
    [[SoundEffects sharedInstance] playMessageSound];
}


@end
