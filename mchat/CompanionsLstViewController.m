//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "CompanionsLstViewController.h"
#import "CompanionTableCellView.h"

@interface CompanionsLstViewController ()

- (void)playDingSound;
@end

@implementation CompanionsLstViewController
{
    __weak IBOutlet NSTableView *tblView;
    
    NSMutableArray *companions;
    AVAudioPlayer *player;
    LocationMonitor *locationMonitor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationMonitor = [[LocationMonitor alloc] init];
    locationMonitor.delegate = self;
    companions = [[NSMutableArray alloc] init];
    [companions addObjectsFromArray:[MCChatClient sharedInstance].companions];
    [MCChatClient sharedInstance].deligate = self;
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}



- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [companions removeAllObjects];
    [tblView reloadData];
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client
{
    @try {
        if (successfully) {
            [locationMonitor start];
        }
    }
    @catch (NSException *exception) {
        
    }
    
}

- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client
{
    [companions addObject:user];
    [tblView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:([companions count] - 1)] withAnimation:NSTableViewAnimationSlideLeft];
    [self playDingSound];
}

- (void)onUserDisconnected:(MCChatUser *)user
                 forClient:(MCChatClient *)client
{
    [tblView removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([companions indexOfObject:user], 1)] withAnimation:NSTableViewAnimationSlideRight];
    [companions removeObject:user];
}

- (void)onUserInfoChanged:(MCChatUser *)user
                forClient:(MCChatClient *)client
{
    [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[companions indexOfObject:user]]
                       columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [companions count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *viewIdentifier = @"companionCell";
    CompanionTableCellView *cell = (CompanionTableCellView *)[tblView makeViewWithIdentifier:viewIdentifier owner:self];
    MCChatUser *companion = companions[row];
    [cell setName:companion.name];
    [cell setLocation:companion.location];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (tblView.numberOfSelectedRows > 0) {
       // [self performSegueWithIdentifier:@"openchat" sender:self];
        [tblView deselectRow:tblView.selectedRow];
    }
}


- (void)locationDidChangedTo:(NSString *)locationString
{
    [[MCChatClient sharedInstance] updateMyLocation:locationString];
}

- (void)playDingSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"ding-sound"
                                    ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                           error:nil];
    [player play];
}

@end
