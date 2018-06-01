/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
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
 */

#import "MainVC.h"
#import "ChannelCell.h"
#import "SuplaClient.h"
#import "SuplaApp.h"
#import "Database.h"
#import "SAChannel+CoreDataClass.h"
#import "SectionCell.h"
#import "RGBDetailView.h"
#import "RSDetailView.h"
#import "SARateApp.h"

@implementation SAMainVC {
    NSFetchedResultsController *_frc;
    UINib *_cell_nib;
    UINib *_temp_nib;
    UINib *_temphumidity_nib;
    UINib *_depth_nib;
    UINib *_distance_nib;
    UINib *_section_nib;
    NSTimer *_nTimer;
    UITapGestureRecognizer *_tapRecognizer;

}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _cell_nib = [UINib nibWithNibName:@"ChannelCell" bundle:nil];
    _temp_nib = [UINib nibWithNibName:@"ThermometerCell" bundle:nil];
    _temphumidity_nib = [UINib nibWithNibName:@"TempHumidityCell" bundle:nil];
    _depth_nib = [UINib nibWithNibName:@"DepthCell" bundle:nil];
    _distance_nib = [UINib nibWithNibName:@"DistanceCell" bundle:nil];
    _section_nib = [UINib nibWithNibName:@"SectionCell" bundle:nil];
    
    [[self tableView] registerNib:_cell_nib forCellReuseIdentifier:@"ChannelCell"];
    [[self tableView] registerNib:_temp_nib forCellReuseIdentifier:@"ThermometerCell"];
    [[self tableView] registerNib:_temphumidity_nib forCellReuseIdentifier:@"TempHumidityCell"];
    [[self tableView] registerNib:_depth_nib forCellReuseIdentifier:@"DepthCell"];
    [[self tableView] registerNib:_distance_nib forCellReuseIdentifier:@"DistanceCell"];
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
    [self.tableView reloadData];
}

- (void)onEvent:(NSNotification *)notification {
    
    if ( notification.userInfo == nil ) return;
    
    SAEvent *event = (SAEvent *)[notification.userInfo objectForKey:@"event"];
    
    if ( event == nil || event.Owner ) return;
    
    SAChannel *channel = [[SAApp DB] fetchChannelById:event.ChannelID];
   
    if ( channel == nil ) return;
    
    UIImage *img = [channel getIcon];
    
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

- (void)detailHide {
    [(SAMainView*)self.view detailShow:NO animated:NO];
}

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
    
    SAChannelBase *channel_base = [self.frc objectAtIndexPath:indexPath];
    SAChannelCell *cell = nil;
    
    if ( channel_base ) {

        NSString *identifier;
        
        switch(channel_base.func) {
            case SUPLA_CHANNELFNC_THERMOMETER:
                identifier = @"ThermometerCell";
                break;
            case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                identifier = @"TempHumidityCell";
                break;
            case SUPLA_CHANNELFNC_DEPTHSENSOR:
                identifier = @"DepthCell";
                break;
            case SUPLA_CHANNELFNC_DISTANCESENSOR:
                identifier = @"DistanceCell";
                break;
            default:
                identifier = @"ChannelCell";
                break;
        }
        
        cell =  [tableView dequeueReusableCellWithIdentifier: identifier];
        
        if ( cell != nil ) {
            cell.channelBase = channel_base;
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

- (void) viewWillAppear:(BOOL)animated {

    [[[SARateApp alloc] init] showDialogWithDelay: 1];
    
}

@end

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

@implementation SAMainView {
    UIPanGestureRecognizer *_panRecognizer;
    
    SAChannelCell *cell;
    SARGBDetailView *_rgbDetailView;
    SARSDetailView *_rsDetailView; // Roller Shutter detail view
    SADetailView *_detailView;
    
    float last_touched_x;
    BOOL _animating;
}

-(void)initMainView {
    
   cell = nil;
    
   _rgbDetailView = nil;
    _detailView = nil;
   _animating = NO;
   _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:_panRecognizer];
    
}

-(SADetailView*)detailView {
    return _detailView;
}

- (CGRect)getDetailFrame {
    
    return CGRectMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (SADetailView*)getDetailViewForCell:(SAChannelCell*)_cell {
    
    SADetailView *result = nil;
    
    if ( _cell.channelBase.isOnline ) {
        
        switch(_cell.channelBase.func) {
            case SUPLA_CHANNELFNC_DIMMER:
            case SUPLA_CHANNELFNC_RGBLIGHTING:
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                
                if ( _rgbDetailView == nil
                    && self.superview != nil ) {
                    
                    _rgbDetailView = [[[NSBundle mainBundle] loadNibNamed:@"RGBDetail" owner:self options:nil] objectAtIndex:0];
                    [_rgbDetailView detailViewInit];
                    
                }
                
                result = _rgbDetailView;
                
                break;
                
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                
                if ( _rsDetailView == nil
                    && self.superview != nil ) {
                    
                    _rsDetailView = [[[NSBundle mainBundle] loadNibNamed:@"RSDetail" owner:self options:nil] objectAtIndex:0];
                    [_rsDetailView detailViewInit];
                    
                }
                
                result = _rsDetailView;
                
                break;
        };
    }
    
    if ( result != nil ) {
    
        SAChannelBase *channelBase = cell == nil ? nil : cell.channelBase;
        
        if ( result.main_view != self ) {
            result.main_view = self;
        }
        
        if ( result.channelBase != channelBase ) {
            result.channelBase  = channelBase;
        }
    }

    return result;
}

-(id)init {
    
    self = [super init];
    if ( self ) {
        [self initMainView];
        return self;
    }
    
    return nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self initMainView];
        return self;
    }
    
    return nil;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if ( self ) {
        [self initMainView];
        return self;
    }
    
    return nil;
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    last_touched_x = point.x;
    return [super hitTest:point withEvent:event];
}

- (void)detailShow:(BOOL)show animated:(BOOL)animated {
 
    [UIView commitAnimations];
    _animating = NO;
    
    if ( animated ) {
        
        _animating = YES;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             float multiplier = 1;
                             
                             if ( show ) {
                                 multiplier = -1;
                             }
                             
                             [self setCenter:CGPointMake((self.frame.size.width/2) * multiplier, self.center.y)];
                             [_detailView setFrame:[self getDetailFrame]];

                         }
                         completion:^(BOOL finished){
                             
                             if ( show == NO ) {
                                
                                 if ( _detailView ) {
                                     [_detailView removeFromSuperview];
                                     _detailView = nil;
                                 }
                                 
                                 if ( cell ) {
                                     cell.contentView.backgroundColor = [UIColor cellBackground];
                                     cell = nil;
                                 }
                                 
                             }
                             
                             
                             _animating = NO;
                         }];
        
    } else {
        
        if ( show == NO ) {
            
            [self setCenter:CGPointMake(self.frame.size.width/2, self.center.y)];
            
            if ( _detailView ) {
                [_detailView removeFromSuperview];
                _detailView = nil;
            }
            
            if ( cell ) {
                cell.contentView.backgroundColor = [UIColor cellBackground];
                cell = nil;
            }
            
        }
        
    }
    

    
}


- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    if ( _animating )
        return;
    
    CGPoint touch_point = [gr locationInView:self.tableView];
    
    if ( gr.state == UIGestureRecognizerStateEnded
         && _detailView != nil ) {
        
        [self detailShow:self.frame.origin.x*-1 > self.frame.size.width/3.5 ? YES : NO animated:YES];
        
        return;
    }
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:touch_point];
    
    if ( path != nil ) {
        
        if ( cell == nil ) {
            cell = [self.tableView cellForRowAtIndexPath:path];
        }
        
        if ( cell == nil || [cell isKindOfClass:[SAChannelCell class]] == NO ) {
            
            cell = nil;
            
        } else {
        
            SADetailView *detailView = detailView = [self getDetailViewForCell:cell];
            
            if ( detailView == nil ) {
                
                cell = nil;
                
            } else {
            
                cell.contentView.backgroundColor = detailView.backgroundColor;
                
                float offset = touch_point.x-last_touched_x;
                
                if ( self.frame.origin.x+offset > 0 )
                    offset -= self.frame.origin.x+offset;
                
                if ( _detailView == nil ) {
                    _detailView = detailView;
                    [self.superview addSubview:detailView];
                }
                
                [self moveCenter:offset];
                touch_point.x -= offset;
 
            }
            

        }
    }
    

    last_touched_x = touch_point.x;
    
}

-(void)setCenter:(CGPoint)center {
    [super setCenter: center];
    
    if ( _detailView != nil ) {
        [_detailView setFrame:[self getDetailFrame]];
    }
    
    [[SAApp UI] showMenuBtn:self.frame.origin.x == 0];
}

-(void)moveCenter:(float)x_offset {
    [self setCenter:CGPointMake(self.center.x+x_offset, self.center.y)];
}




@end
