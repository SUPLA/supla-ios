/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */

#import "MainVC.h"
#import "ChannelCell.h"
#import "SuplaClient.h"
#import "SuplaApp.h"
#import "Database.h"
#import "SAChannel.h"
#import "SectionCell.h"

@implementation SAMainVC {
    NSFetchedResultsController *_frc;
    UINib *_cell_nib;
    UINib *_temp_nib;
    UINib *_section_nib;
    NSTimer *_nTimer;
    UITapGestureRecognizer *_tapRecognizer;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _cell_nib = [UINib nibWithNibName:@"ChannelCell" bundle:nil];
    _temp_nib = [UINib nibWithNibName:@"ThermometerCell" bundle:nil];
    _section_nib = [UINib nibWithNibName:@"SectionCell" bundle:nil];
    
    [[self tableView] registerNib:_cell_nib forCellReuseIdentifier:@"ChannelCell"];
    [[self tableView] registerNib:_temp_nib forCellReuseIdentifier:@"ThermometerCell"];
    [[self tableView] registerNib:_section_nib forCellReuseIdentifier:@"SectionCell"];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.notificationView addGestureRecognizer:_tapRecognizer];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged) name:kSADataChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEvent:) name:kSAEventNotification object:nil];
        
    }
    return self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onDataChanged {
    _frc = nil;
    [self.channelTable reloadData];
}

- (void)onEvent:(NSNotification *)notification {
    
    if ( notification.userInfo == nil ) return;
    
    SAEvent *event = (SAEvent *)[notification.userInfo objectForKey:@"event"];
    
    if ( event == nil || event.Owner ) return;
    
    SAChannel *channel = [[SAApp DB] fetchChannelById:event.ChannelID];
   
    if ( channel == nil ) return;
    
    UIImage *img = [channel channelIcon];
    
    if ( img == nil ) return;
    
    NSString *msg;
    
    switch(event.Event) {
        case SUPLA_EVENT_CONTROLLINGTHEGATEWAYLOCK:
            msg = NSLocalizedString(@"opened the gateway", nil);
            break;
        case SUPLA_EVENT_CONTROLLINGTHEGATE:
            msg = NSLocalizedString(@"opened / closed the gate", nil);
            break;
        case SUPLA_EVENT_CONTROLLINGTHEGARAGEDOOR:
            msg = NSLocalizedString(@"opened / closed the gate doors", nil);
            break;
        case SUPLA_EVENT_CONTROLLINGTHEDOORLOCK:
            msg = NSLocalizedString(@"opened the door", nil);
            break;
        case SUPLA_EVENT_CONTROLLINGTHEROLLERSHUTTER:
            msg = NSLocalizedString(@"opened / closed roller shutter", nil);
            break;
        case SUPLA_EVENT_POWERONOFF:
            msg = NSLocalizedString(@"turned the power ON/OFF", nil);
            break;
        case SUPLA_EVENT_LIGHTONOFF:
            msg = NSLocalizedString(@"turned the light ON/OFF", nil);
            break;
        default:
            return;
    }
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    msg = [NSString stringWithFormat:@"%@ %@ %@", [timeFormat stringFromDate:[NSDate date]], event.SenderName, msg];
    
    if ( [channel.caption isEqualToString:@""] == NO ) {
        msg = [NSString stringWithFormat:@"%@ (%@)", msg, channel.caption];
    }
    
    [self showNotificationMessage:msg withImage:img];

}

#pragma mark Notification Support

-(void)showNotificationView:(BOOL)show {
    
    self.notificationBottom.constant = show ? self.notificationView.frame.size.height * -1 : 0;
    
    self.notificationView.hidden = NO;
    [self.view bringSubviewToFront:self.notificationView];
    
    [self.view layoutIfNeeded];
    
    self.notificationBottom.constant = show ? 0 : self.notificationView.frame.size.height * -1;
    
    [UIView animateWithDuration:0.10 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

-(void)closeNotificationView {
    
    if ( _nTimer ) {
        [_nTimer invalidate];
        _nTimer = nil;
    }
    
    if ( self.notificationView.hidden == NO ) {
        [self showNotificationView:NO];
    }
    
};

-(void)showNotificationMessage:(NSString*)msg withImage:(UIImage*)img {
    
    self.notificationView.hidden = YES;
    [self closeNotificationView];
    
    [self.notificationImage setImage:img];
    [self.notificationLabel setText:msg];
    [self showNotificationView:YES];
    
    _nTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(onTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)onTimer:(NSTimer *)timer {
    _nTimer = nil;
    [self closeNotificationView];
    
};

-(IBAction) tapGesture:(UITapGestureRecognizer*)recognizer
{
    if ( recognizer.view == self.notificationView ) {
        [self closeNotificationView];
    }
};

#pragma mark Table Support

- (NSFetchedResultsController*)frc {
    
    if ( _frc == nil ) {
        _frc = [SAApp.DB getChannelFrc];
    }
    
    return _frc;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.frc ? [[self.frc sections] count] : 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  [[[self.frc sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ( self.frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SAChannel *channel = [self.frc objectAtIndexPath:indexPath];
    SAChannelCell *cell = nil;
    
    if ( channel ) {

        cell =  [tableView dequeueReusableCellWithIdentifier: [channel.func intValue] == SUPLA_CHANNELFNC_THERMOMETER ? @"ThermometerCell" : @"ChannelCell"];
        
        if ( cell != nil ) {
            cell.channel = channel;
        }
        
    }
  
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SASectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    if ( cell ) {
        [cell.label setText:[[[self.frc sections] objectAtIndex:section] name]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (IBAction)settingsTouched:(id)sender {
    
    [[SAApp UI ] showSettings];
    
}
@end
