//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidAppear
{
   [self performSegueWithIdentifier:@"dialog" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MCChatCore *cli = [[MCChatCore alloc] init];
    cli.delegate = self;
    [cli connect];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)connectedToServerVersion:(NSUInteger)version
                       forClient:(MCChatCore *)client
{
    NSLog(@"users = %@", client.users);
}

- (void)connectingFailedforClient:(MCChatCore *)client
{
   
}

- (void)userConnected:(NSString *)user
            forClient:(MCChatCore *)client
{
    NSLog(@"users = %@", client.users);
}

- (void)userDisconnected:(NSString *)user
               forClient:(MCChatCore *)client
{
     NSLog(@"users = %@", client.users);
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSString *)user
              forClient:(MCChatCore *)client
{
    
}


@end
