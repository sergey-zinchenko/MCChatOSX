//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "CompanionsLstViewController.h"

@interface CompanionsLstViewController ()
- (void)showProgressIndicator;
- (void)hideProgressIndicator;
- (void)playDingSound;
@end

@implementation CompanionsLstViewController
{
    __weak IBOutlet NSTableView *tblView;
    __weak IBOutlet NSView *progressIndicatorHolderView;
    __weak IBOutlet NSProgressIndicator *progressIndicatorView;
    __weak IBOutlet NSTextField *progressIndicatorLabelView;
    NSMutableArray *companions;
    AVAudioPlayer *player;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL en = [CLLocationManager locationServicesEnabled];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 500;
    locationManager.delegate = self;
    geocoder = [[CLGeocoder alloc] init];
    [locationManager startUpdatingLocation];
    
    companions = [[NSMutableArray alloc] init];
    [companions addObjectsFromArray:[MCChatClient sharedInstance].companions];
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

- (void)showProgressIndicator
{
    progressIndicatorHolderView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptStartedNotifcation object:self userInfo:nil];
}

- (void)hideProgressIndicator
{
    progressIndicatorHolderView.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{@"successfully" : @YES}];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [companions removeAllObjects];
    [self showProgressIndicator];
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client
{
    [self hideProgressIndicator];
}

- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client
{
    [companions addObject:user];
    [tblView reloadData];
    [self playDingSound];
}

- (void)onUserDisconnected:(MCChatUser *)user
                 forClient:(MCChatClient *)client
{
    [companions removeObject:user];
    [tblView reloadData];
    [self playDingSound];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [companions count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *viewIdentifier = @"companionCell";
    NSTableCellView *cell = [tblView makeViewWithIdentifier:viewIdentifier owner:self];
    [cell.textField setStringValue:((MCChatUser *)companions[row]).name];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (tblView.numberOfSelectedRows > 0) {
        [self performSegueWithIdentifier:@"openchat" sender:self];
        [tblView deselectRow:tblView.selectedRow];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations&&([locations count] > 0)) {
        CLLocation *mostRecentLocation = [locations lastObject];
        if (!geocoder.isGeocoding) {
            [geocoder reverseGeocodeLocation:mostRecentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (placemarks&&!error&&([placemarks count] > 0)) {
                    CLPlacemark *lp = [placemarks lastObject];
                    NSString *locationString = [NSString stringWithFormat:@"%@, %@, %@", lp.country, lp.administrativeArea, lp.subAdministrativeArea];
                    NSLog(@"%@", locationString);
                }
            }];
        }
    }
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
