//
//  SoundEffects.h
//  MChat
//
//  Created by Сергей Зинченко on 05.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundEffects : NSObject<AVAudioPlayerDelegate>

- (void)playUserSound;
- (void)playChatSound;
- (void)playChatEventSound;
- (void)playMessageSound;

+ (SoundEffects *)sharedInstance;

+ (void)playUserSound;
+ (void)playChatSound;
+ (void)playChatEventSound;
+ (void)playMessageSound;

@end
