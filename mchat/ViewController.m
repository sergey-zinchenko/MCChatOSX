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
                       forCore:(MCChatCore *)core
{
    NSLog(@"Users = %@", core.users);
}

- (void)exception:(NSString *)exception
    withReason:(NSString *)reason
           forCore:(MCChatCore *)core
{
    NSLog(@"Exception = %@ : %@", exception, reason);
    [core performSelector:@selector(connect) withObject:nil afterDelay:5.0];
}

- (void)userConnected:(NSUUID *)user
            forCore:(MCChatCore *)core
{
    
    NSLog(@"User %@ connected", user);
    [core sendMessage:@{@"to":@[[user UUIDString]],@"message":@"Yes!!!"}];
    [core disconnect];
}

- (void)userDisconnected:(NSUUID *)user
               forCore:(MCChatCore *)core
{
     NSLog(@"User %@ disconnected", user);
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)user
              forCore:(MCChatCore *)core
{
    
}


@end
