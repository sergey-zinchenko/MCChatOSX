//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    IBOutlet NSView *progressIndicatorHolderView;
    IBOutlet NSProgressIndicator *progressIndicatorView;
    IBOutlet NSTextField *progressIndicatorLabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MCChatClient sharedInstance].deligate = self;
    [progressIndicatorView startAnimation:self];
    progressIndicatorHolderView.alphaValue = 0.8;
    progressIndicatorHolderView.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    progressIndicatorHolderView.layer.cornerRadius = 10;
    progressIndicatorHolderView.hidden = YES;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    progressIndicatorHolderView.hidden = NO;
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                ForClient:(MCChatClient *)client
{
    progressIndicatorHolderView.hidden = YES;
}

@end
