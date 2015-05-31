//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    MCChatClient *cli;
}

- (void)viewDidAppear
{
   [self performSegueWithIdentifier:@"dialog" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cli = [[MCChatClient alloc] initWithName:@"Петрушка"];
    [cli connect];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    
}




@end
