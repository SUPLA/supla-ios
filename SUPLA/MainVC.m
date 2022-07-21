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
#import "RGBWDetailView.h"
#import "RSDetailView.h"
#import "ElectricityMeterDetailView.h"
#import "ImpulseCounterDetailView.h"
#import "HomePlusDetailView.h"
#import "TemperatureDetailView.h"
#import "TempHumidityDetailView.h"
#import "SADigiglassDetailView.h"
#import "SARateApp.h"
#import "_SALocation+CoreDataClass.h"
#import "SAEvent.h"
#import "UIColor+SUPLA.h"
#import "SUPLA-Swift.h"

@interface SAMainVC()
@property (nonatomic) BOOL showingDetails;
@end

@interface SAMainVC() <MGSwipeTableCellDelegate,ProfileChooserDelegate>
@end

@implementation SAMainVC {
    NSFetchedResultsController *_cFrc;
    NSFetchedResultsController *_gFrc;
    UINib *_cell_nib;
    UINib *_temp_nib;
    UINib *_temphumidity_nib;
    UINib *_measurement_nib;
    UINib *_distance_nib;
    UINib *_section_nib;
    UINib *_incmeter_nib;
    UINib *_homeplus_nib;
    NSTimer *_nTimer;
    UITapGestureRecognizer *_tapRecognizer;
    SADownloadUserIcons *_task;
    NSArray *_locations;
    CGFloat _standardChannelHeight;
    CGFloat _heightScaleFactor;
	UIImage *_groupsOff;
	UIImage *_groupsOn;
    BOOL _shouldUpdateRowHeight;
    NSMutableDictionary<NSString *, NSNumber *> *_cellConstraintValues;
    BOOL _dataRefreshEnabled;
    BOOL _dataRefreshPending;
    NSMutableDictionary<NSIndexPath*, NSNumber*> *_savedButtonStates;
    
    NSTimer *_endGestureHook;
    NSDate *_lastReload;
    NSTimer *_delayedReloadTimer;
    
    ProfileChooser *_chooser;
}

- (void)registerNibForTableView:(UITableView*)tv {
    [tv registerNib:_cell_nib forCellReuseIdentifier:@"ChannelCell"];
    [tv registerNib:_temp_nib forCellReuseIdentifier:@"ThermometerCell"];
    [tv registerNib:_temphumidity_nib forCellReuseIdentifier:@"TempHumidityCell"];
    [tv registerNib:_measurement_nib forCellReuseIdentifier:@"MeasurementCell"];
    [tv registerNib:_distance_nib forCellReuseIdentifier:@"DistanceCell"];
    [tv registerNib:_incmeter_nib forCellReuseIdentifier:@"IncrementalMeterCell"];
    [tv registerNib:_homeplus_nib forCellReuseIdentifier:@"HomePlusCell"];
    [tv registerNib:_section_nib forCellReuseIdentifier:@"SectionCell"];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _lastReload = [NSDate distantPast];
    
    _savedButtonStates = [NSMutableDictionary new];

    [[NSNotificationCenter defaultCenter]
        addObserver: self selector:@selector(didChangeRowHeight:)
               name: kChannelHeightDidChange object:nil];
    _shouldUpdateRowHeight = YES;
    self.showingDetails = NO;
    ((SAMainView*)self.view).viewController = self;
    _heightScaleFactor = [Config new].channelHeightFactor;
    _cellConstraintValues = [NSMutableDictionary new];

    _cell_nib = [UINib nibWithNibName:@"ChannelCell" bundle:nil];
    _temp_nib = [UINib nibWithNibName:@"ThermometerCell" bundle:nil];
    _temphumidity_nib = [UINib nibWithNibName:@"TempHumidityCell" bundle:nil];
    _measurement_nib = [UINib nibWithNibName:@"MeasurementCell" bundle:nil];
    _distance_nib = [UINib nibWithNibName:@"DistanceCell" bundle:nil];
    _incmeter_nib = [UINib nibWithNibName:@"IncrementalMeterCell" bundle:nil];
    _homeplus_nib = [UINib nibWithNibName:@"HomePlusCell" bundle:nil];
    _section_nib = [UINib nibWithNibName:@"SectionCell" bundle:nil];
    
    [self registerNibForTableView:self.cTableView];
    [self registerNibForTableView:self.gTableView];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.notificationView addGestureRecognizer:_tapRecognizer];
    
    if (@available(iOS 11.0, *)) {
        self.cTableView.clearsContextBeforeDrawing = YES;
        self.cTableView.dragInteractionEnabled = YES;
        self.cTableView.dragDelegate = self;
        self.cTableView.dropDelegate = self;
        
        self.gTableView.clearsContextBeforeDrawing = YES;
        self.gTableView.dragInteractionEnabled = YES;
        self.gTableView.dragDelegate = self;
        self.gTableView.dropDelegate = self;
    }

    if (@available(iOS 15.0, *)) {
        self.cTableView.sectionHeaderTopPadding = 0;
        self.gTableView.sectionHeaderTopPadding = 0;
    }
 
	_groupsOff = [UIImage imageNamed: @"groupsoff"];
	_groupsOn = [UIImage imageNamed: @"groupson"];
    
    [self configureNavigationBar];
}


- (void)didChangeRowHeight: notification {
    _shouldUpdateRowHeight = YES;
    [self adjustChannelHeight: YES];
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ( cell != nil
        && [cell isKindOfClass:[SAChannelCell class]]
        && !((SAChannelCell*)cell).captionTouched) {
        NSItemProvider *itemProvicer = [[NSItemProvider alloc] init];
        UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvicer];
        dragItem.localObject = cell;
        _dataRefreshEnabled = NO;
        return @[dragItem];
    }

    return @[];
}

- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator  API_AVAILABLE(ios(11.0)){

    SAChannelCell *dstCell = [tableView cellForRowAtIndexPath:coordinator.destinationIndexPath];
    SAChannelCell *srcCell = (SAChannelCell *)coordinator.items.firstObject.dragItem.localObject;

    if (tableView == self.cTableView) {
        [SAApp.DB  moveChannel:srcCell.channelBase toPositionOfChannel:dstCell.channelBase];
        _cFrc = nil;
    } else if (tableView == self.gTableView) {
        [SAApp.DB  moveChannelGroup:srcCell.channelBase toPositionOfChannelGroup:dstCell.channelBase];
        _gFrc = nil;
    }
    _dataRefreshEnabled = YES;
    [tableView reloadData];
}

- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath  API_AVAILABLE(ios(11.0)){
    
    UIDropOperation dropOperation = UIDropOperationForbidden;
    
    if (session.items.count == 1
        && [session.items.firstObject.localObject isKindOfClass:[SAChannelCell class]]) {
        SAChannelCell *srcCell = (SAChannelCell *)session.items.firstObject.localObject;
        if (srcCell.channelBase && srcCell.channelBase.location) {
            SAChannelCell *dstCell = [tableView cellForRowAtIndexPath:destinationIndexPath];
            if ([dstCell isKindOfClass:[SAChannelCell class]]
                && dstCell.channelBase
                && dstCell.channelBase.location
                && dstCell.channelBase.location == srcCell.channelBase.location) {
                dropOperation = UIDropOperationMove;
            }
        }
    }
    
    return [[UITableViewDropProposal alloc] initWithDropOperation:dropOperation intent:UITableViewDropIntentInsertAtDestinationIndexPath];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMenubarBackButtonPressed) name:kSAMenubarBackButtonPressed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged) name:kSADataChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEvent:) name:kSAEventNotification object:nil];
        
    }
    return self;
}



#define DATA_REFRESH_MIN_INTERVAL 0.5

-(void)onDataChanged {
    if(_dataRefreshEnabled && [_lastReload timeIntervalSinceNow] < -DATA_REFRESH_MIN_INTERVAL) {
        _lastReload = [NSDate new];
        _cFrc = nil;
        _gFrc = nil;
        _locations = nil;
        [self.cTableView reloadData];
        [self.gTableView reloadData];

        if(_shouldUpdateRowHeight)
            [self adjustChannelHeight: YES];
        _dataRefreshPending = NO;
    } else {
        _dataRefreshPending = YES;
        if(_dataRefreshEnabled) {
            _delayedReloadTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_MIN_INTERVAL
                                                               target: self
                                                                 selector:@selector(onDataChanged)
                                                                 userInfo:nil repeats:NO];
        }
    }
}

- (void)onEvent:(NSNotification *)notification {
    
    if ( notification.userInfo == nil ) return;
    
    SAEvent *event = [SAEvent notificationToEvent:notification];
    
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
        case SUPLA_EVENT_CONTROLLINGTHEROOFWINDOW:
            msg = NSLocalizedString(@"opened / closed the roof window", nil);
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
	if([self.navigationController.topViewController
		   isKindOfClass: [DetailViewController class]]) {
		[self.navigationController popViewControllerAnimated: NO];
    }
}

#pragma mark Locations

- (_SALocation *) locationByName:(NSString *)name {
    if (name == nil) {
        return nil;
    }
    
    if (_locations == nil) {
        _locations = [SAApp.DB fetchVisibleLocations];
        if (_locations == nil) {
            _locations = [[NSArray alloc] init];
        }
    }
    
    NSUInteger idx = [_locations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [((_SALocation*)obj).caption isEqualToString:name];
    }];
    
    return idx == NSNotFound ? nil : (_SALocation*)[_locations objectAtIndex:idx];
}

#pragma mark Table Support

- (NSFetchedResultsController*)frcForTableView:(UITableView*)tableView {
    
    if (tableView == self.cTableView) {
        if ( _cFrc == nil ) {
            _cFrc = [SAApp.DB getChannelFrc];
        }
        return _cFrc;
    } else {
        if ( _gFrc == nil ) {
            _gFrc = [SAApp.DB getChannelGroupFrc];
        }
        return _gFrc;
    }
    
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSFetchedResultsController *frc = [self frcForTableView:tableView];
    return frc ? [[frc sections] count] : 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  [[[[self frcForTableView:tableView] sections] objectAtIndex:section] name];
}

- (short)bitFlagCollapse {
    return self.cTableView.hidden == NO ? 0x1 : 0x2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSFetchedResultsController *frc = [self frcForTableView:tableView];
    if ( frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:section];
        NSRange r = [sectionInfo.name rangeOfString:@":"];
        NSString *name = [sectionInfo.name substringFromIndex: r.location + 1];
        _SALocation *location = [self locationByName:name];
        if (location != nil
            && (location.collapsed & [self bitFlagCollapse]) > 0) {
            return 0;
        }
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (void)sectionCellTouch:(SASectionCell*)section {
    
    _SALocation *location = [self locationByName:section.label.text];
    if (location) {
        short bit = [self bitFlagCollapse];
        if ((location.collapsed & bit) > 0) {
            location.collapsed ^= bit;
        } else {
            location.collapsed |= bit;
        }
        
        [SAApp.DB saveContext];
        [self onDataChanged];
    }
}

- (void)resetCellButtonStates: (SAChannelCell *)cell {
    NSNumber *stateObject = _savedButtonStates[cell.currentIndexPath];
    enum MGSwipeState state = MGSwipeStateNone;
    
    if(stateObject) {
        state = [stateObject integerValue];
    }

    switch(state) {
    case MGSwipeStateSwipingLeftToRight:
        [cell showSwipe: MGSwipeDirectionLeftToRight animated: NO];
        break;
    case MGSwipeStateSwipingRightToLeft:
        [cell showSwipe: MGSwipeDirectionRightToLeft animated: NO];
        break;
    case MGSwipeStateNone:
    default:
        [cell hideSwipeAnimated: NO];
        break;
      
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SAChannelBase *channel_base =  [[self frcForTableView:tableView]
                        objectAtIndexPath:indexPath];
    SAChannelCell *cell = nil;
    
    NSString *identifier = @"ChannelCell";
    
    if ( channel_base ) {
        
        SAChannel *channel = [channel_base isKindOfClass:[SAChannel class]] ? (SAChannel*)channel_base : nil;
        
        switch(channel_base.func) {
            case SUPLA_CHANNELFNC_POWERSWITCH:
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
            case SUPLA_CHANNELFNC_STAIRCASETIMER:
                if (channel
                    && channel.value
                    && (channel.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS
                        || channel.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS)) {
                    identifier = @"IncrementalMeterCell";
                }
                break;
            case SUPLA_CHANNELFNC_THERMOMETER:
                identifier = @"ThermometerCell";
                break;
            case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                identifier = @"TempHumidityCell";
                break;
            case SUPLA_CHANNELFNC_DEPTHSENSOR:
            case SUPLA_CHANNELFNC_WINDSENSOR:
            case SUPLA_CHANNELFNC_WEIGHTSENSOR:
            case SUPLA_CHANNELFNC_PRESSURESENSOR:
            case SUPLA_CHANNELFNC_RAINSENSOR:
            case SUPLA_CHANNELFNC_HUMIDITY:
                identifier = @"MeasurementCell";
                break;
            case SUPLA_CHANNELFNC_DISTANCESENSOR:
                identifier = @"DistanceCell";
                break;
            case SUPLA_CHANNELFNC_ELECTRICITY_METER:
            case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
            case SUPLA_CHANNELFNC_IC_GAS_METER:
            case SUPLA_CHANNELFNC_IC_WATER_METER:
            case SUPLA_CHANNELFNC_IC_HEAT_METER:
                identifier = @"IncrementalMeterCell";
                break;
            case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                identifier = @"HomePlusCell";
                break;
        }
    }
    
    cell =  [tableView dequeueReusableCellWithIdentifier: identifier forIndexPath: indexPath];
    cell.delegate = nil;
    cell.currentIndexPath = indexPath;
    cell.channelBase = channel_base;
    cell.delegate = self;
    cell.captionEditable = tableView == self.cTableView;
    CGFloat scaleFactor = _heightScaleFactor;
    for(NSLayoutConstraint *cstr in cell.channelIconScalableConstraints) {
        CGFloat val, sf = scaleFactor;
        NSString *cstrId = [identifier stringByAppendingString: cstr.identifier];
        if(_cellConstraintValues[cstrId]) {
            val = [_cellConstraintValues[cstrId] floatValue];
        } else {
            val = cstr.constant;
            if(sf < 0.7) val /= sf; // Correct initial lower scale got from autoresize
            _cellConstraintValues[cstrId] = [NSNumber numberWithFloat:val];
        }
        if(sf < 1.0 && [@"distanceValueHeight" isEqualToString: cstr.identifier]) {
            sf = 1.0;
        }
        if([cstr.firstItem isKindOfClass: [UILabel class]] ||
           [cstr.secondItem isKindOfClass: [UILabel class]]) {
            id lbl = [cstr.firstItem isKindOfClass: [UILabel class]]?cstr.firstItem:cstr.secondItem;
            CGFloat tfs = sf;
            if(lbl == cell.caption) {
                if(tfs < 1.0) tfs = 0.8;
                if(sf < 1.0) sf *= 1.2;
            }
            [self adjustFontSize: lbl forScale: tfs
                       isCaption: lbl == cell.caption];
        }

        if([cstr.identifier isEqualToString: @"captionToBottom"]) {
            val = 9;
        }
        
        cstr.constant = val * sf;
        if([cstr.firstItem isKindOfClass: [UIImageView class]]) {
            [cstr.firstItem setNeedsDisplay];
        }
    }
    [self resetCellButtonStates:cell];
    
    return cell;
}

- (void)adjustFontSize: (UILabel *)itm forScale: (CGFloat)scale
             isCaption: (BOOL)isCaption {
    CGFloat origSize, minSize = 12;
    if(isCaption)
        origSize = 12;
    else {
        origSize = 20;
        if(scale < 1.0) scale = 1.0;
    }
    itm.font = [itm.font fontWithSize: MAX(origSize * scale, minSize)];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SASectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    if ( cell ) {
        NSString *rawTitle = [[[[self frcForTableView:tableView] sections] objectAtIndex:section] name];
        NSRange r = [rawTitle rangeOfString:@":"];
        NSString *name = [rawTitle substringFromIndex: r.location + 1];
        _SALocation *location = [self locationByName:name];
        cell.ivCollapsed.hidden = location == nil || (location.collapsed & [self bitFlagCollapse]) == 0;
        cell.locationId = [location.location_id intValue];
        cell.captionEditable = tableView == self.cTableView;
        [cell.label setText:name];
        cell.delegate = self;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


- (BOOL)isGroupTableHidden {
   return self.gTableView.hidden;
 }

 
- (void)groupTableHidden:(BOOL)hidden {
    self.cTableView.hidden = !hidden;
    self.gTableView.hidden = hidden;
    
    [self onDataChanged];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[SARateApp alloc] init] showDialogWithDelay: 1];
    _dataRefreshEnabled = YES;
    _dataRefreshPending = NO;
    [self runDownloadTask];
    if(self.showingDetails) {
        [(SAMainView*)self.view detailDidHide];
        self.showingDetails = NO;
    }
    
}

-(void)runDownloadTask {
    if (_task && ![_task isTaskIsAliveWithTimeout:90]) {
        [_task cancel];
        _task = nil;
    }
    
    if (!_task) {
        _task = [[SADownloadUserIcons alloc] init];
        _task.delegate = self;
        [_task start];
    }
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    // NSLog(@"onRestApiTaskStarted");
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    // NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        if (_task.channelsUpdated) {
            [self onDataChanged];
        }
        _task.delegate = nil;
        _task = nil;
    }
}
#pragma mark Support for navigation bar
- (UIImage *)imageForGroupState {
	if([self isGroupTableHidden]) {
		return _groupsOff;
	} else {
		return _groupsOn;
	}
}
#pragma mark MGSwipeTableCellDelegate

-(void) swipeTableCell:(MGSwipeTableCell*) cell
   didChangeSwipeState:(MGSwipeState) state
       gestureIsActive:(BOOL) gestureIsActive {
    [_endGestureHook invalidate];
    if(gestureIsActive) {
        _endGestureHook = nil;
        _dataRefreshEnabled = NO;
    } else {
        _endGestureHook = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                           target: self
                                                         selector: @selector(deferredEnableRefresh:) userInfo: nil
                                                          repeats: NO];
    }

    if([cell isKindOfClass: [SAChannelCell class]] && !gestureIsActive) {
        SAChannelCell *cc = (SAChannelCell *)cell;
        if(state != MGSwipeStateNone) {
            [_savedButtonStates removeAllObjects];
        }
        _savedButtonStates[cc.currentIndexPath] = [NSNumber numberWithInt: state];
    }
}

#ifdef DEBUG
- (NSString *)describeButtonState: (MGSwipeState)state {
    switch(state) {
        case MGSwipeStateNone: return @"none";
        case MGSwipeStateSwipingLeftToRight: return @"swiping ->";
        case MGSwipeStateSwipingRightToLeft: return @"swiping <-";
        case MGSwipeStateExpandingLeftToRight: return @"swiping ->";
        case MGSwipeStateExpandingRightToLeft: return @"swiping <-";
    }
    return @"wtf";
}
#endif

- (void)deferredEnableRefresh: timer {
    _dataRefreshEnabled = YES;
    if(_dataRefreshEnabled && _dataRefreshPending) {
        [self onDataChanged];
    }
}

- (void)configureNavigationBar {
    self.title = NSLocalizedString(@"supla", @"Title bar text");
    if (@available(iOS 14.0, *)) {
        self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    }
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu"]
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(onMenuToggle:)];

    NSMutableArray *itms = [[NSMutableArray alloc] initWithCapacity: 2];
    if([self hasManyProfiles]) {
        [itms addObject:
                  [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"profile-navbar"]
                                                   style: UIBarButtonItemStylePlain
                                                  target: self
                                                  action: @selector(onProfileSelection:)]];
    }
    [itms addObject:
        [[UIBarButtonItem alloc] initWithImage: [self imageForGroupState]
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(onGroupsToggle:)]];
    self.navigationItem.rightBarButtonItems = itms;
}

- (BOOL)hasManyProfiles {
    return YES; // TODO: replace with actual code
}

- (void)onProfileSelection: sender {
    NSLog(@"sb wants to change profile");
    if(_chooser) return;

    
    _chooser = [[ProfileChooser alloc]
                   initWithProfileManager: [SAApp profileManager]];
    _chooser.delegate = self;
    [_chooser showFrom: self.navigationController];
}

- (void)profileChooserDidDismissWithProfileChanged: (BOOL)change {
    _chooser = nil;
}

- (void)onMenuToggle: sender {
    [[SAApp mainNavigationCoordinator] toggleMenuBar];
}

- (void)onGroupsToggle: sender {
    [self groupTableHidden: ![self isGroupTableHidden]];
	[self.navigationItem.rightBarButtonItems lastObject].image = [self imageForGroupState];
}


- (id<UIViewControllerInteractiveTransitioning>)interactionController {
    return ((SAMainView*)self.view).panController;
}

#pragma mark Support for customizable channel height
/**
   Calculate the "default" channel row height
*/
- (CGFloat)computeChannelHeight {
    return 103;
}

- (void)adjustChannelHeight: (BOOL)needsUpdateConstraints {

    if(_standardChannelHeight == 0) {
        _standardChannelHeight = [self computeChannelHeight];
    }
    if(_standardChannelHeight > 0 && _shouldUpdateRowHeight) {
        _shouldUpdateRowHeight = NO;
        if(needsUpdateConstraints) {
            [self.view setNeedsUpdateConstraints];
        }
    }

}	

- (void)updateViewConstraints {
    [super updateViewConstraints];
	[self adjustChannelHeight: NO];
    if(_standardChannelHeight > 0) {
        CGFloat multiplier = _heightScaleFactor;
        self.cTableView.rowHeight = multiplier * _standardChannelHeight;
        self.gTableView.rowHeight = multiplier * _standardChannelHeight;
        [self.cTableView setNeedsLayout];
        [self.cTableView reloadData];
        [self.gTableView setNeedsLayout];
        [self.gTableView reloadData];
    }
}

- (void)reloadTables {
    _cFrc = nil;
    _gFrc = nil;
    _heightScaleFactor = [Config new].channelHeightFactor;
    [self adjustChannelHeight:YES];
}
@end

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

@implementation SAMainView {
    UIPanGestureRecognizer *_panRecognizer;
    UIPercentDrivenInteractiveTransition *_panTransition;
    
    SAChannelCell *cell;
    
    float last_touched_x;
    BOOL _animating;
}

-(void)initMainView {
    
    cell = nil;
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:_panRecognizer];
}

- (SADetailView*)getDetailViewForCell:(SAChannelCell*)_cell {
    
    SADetailView *result = nil;
    
    SAChannel *channel = [_cell.channelBase isKindOfClass:[SAChannel class]] ? (SAChannel*)_cell.channelBase : nil;
    
    if ( _cell.channelBase.isOnline && self.superview != nil) {
        
        if (channel && (channel.type == SUPLA_CHANNELTYPE_ELECTRICITY_METER
            || (channel.value && channel.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS))) {
            // TODO: Remove channel type checking in future versions. Check function instead of type. Issue #82
            result = [[[NSBundle mainBundle] loadNibNamed:@"ElectricityMeterDetailView" owner:self options:nil] objectAtIndex:0];
        } else if (channel && (channel.type == SUPLA_CHANNELTYPE_IMPULSE_COUNTER
            || (channel.value && channel.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS))) {
            // TODO: Remove channel type checking in future versions. Check function instead of type. Issue #82
            result = [[[NSBundle mainBundle] loadNibNamed:@"ImpulseCounterDetailView" owner:self options:nil] objectAtIndex:0];
        } else {
            switch(_cell.channelBase.func) {
                case SUPLA_CHANNELFNC_DIMMER:
                case SUPLA_CHANNELFNC_RGBLIGHTING:
                case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                    
                    result = [[[NSBundle mainBundle] loadNibNamed:@"RGBWDetail" owner:self options:nil] objectAtIndex:0];
                    break;
                    
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                    
                    result = [[[NSBundle mainBundle] loadNibNamed:@"RSDetail" owner:self options:nil] objectAtIndex:0];
                    break;
                    
                case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                    
                    result = [[[NSBundle mainBundle] loadNibNamed:@"HomePlusDetailView" owner:self options:nil] objectAtIndex:0];
                    break;
                case SUPLA_CHANNELFNC_THERMOMETER:
                    result = [[[NSBundle mainBundle] loadNibNamed:@"TemperatureDetailView" owner:self options:nil] objectAtIndex:0];
                    break;
                case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                    result = [[[NSBundle mainBundle] loadNibNamed:@"TempHumidityDetailView" owner:self options:nil] objectAtIndex:0];
                    break;
                case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
                case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
                    result  = [[[NSBundle mainBundle] loadNibNamed:@"DigiglassDetailView" owner:self options:nil] objectAtIndex:0];
                    break;
            };
        }
        
    }
    
    if ( result != nil ) {
        [result detailViewInit];
        SAChannelBase *channelBase = _cell == nil ? nil : _cell.channelBase;
        
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

- (void)detailDidHide {
    UITableView *tableView = self.cTableView.hidden ? self.gTableView : self.cTableView;
    
    for(UITableViewCell *cell in tableView.visibleCells) {
        if ([cell isKindOfClass:[MGSwipeTableCell class]]
            && ((MGSwipeTableCell*)cell).swipeState != MGSwipeStateNone) {
            [(MGSwipeTableCell*)cell hideSwipeAnimated:YES];
        }
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)gr {
    if(gr.state == UIGestureRecognizerStateBegan) {
        UITableView *tableView = self.cTableView.hidden ? self.gTableView : self.cTableView;
        CGPoint touch_point = [gr locationInView: tableView];
        NSIndexPath *path = [tableView indexPathForRowAtPoint:touch_point];
        if(path) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath: path];
            if([cell isKindOfClass: [SAChannelCell class]]) {
                SADetailView *detailView = [self getDetailViewForCell:cell];
                if(detailView) {
                    BaseViewController *detailVC = [[DetailViewController alloc]
                                                    initWithDetailView: detailView];
                    detailVC.navigationCoordinator = self.viewController.navigationCoordinator;
                    _panTransition = [[UIPercentDrivenInteractiveTransition alloc]
                                      init];
                    [self.viewController.navigationController pushViewController:detailVC
																		animated:YES];
                    self.viewController.showingDetails = YES;
                    
                 }
             }
         }
    } else if(gr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView: self];
        CGFloat d = (translation.x / CGRectGetWidth(self.bounds)) * -1;
        [_panTransition updateInteractiveTransition:d];
    } else if(gr.state == UIGestureRecognizerStateEnded) {
        if(_panTransition.percentComplete > 0.28) {
            [_panTransition finishInteractiveTransition];
         } else {
            [_panTransition cancelInteractiveTransition];
         }
        _panTransition = nil;
     }
}

- (void)handleTap:(UITapGestureRecognizer *)gr {
    if ( _animating )
        return;
    
    UITableView *tableView = self.cTableView.hidden ? self.gTableView : self.cTableView;
    CGPoint touch_point = [gr locationInView:tableView];
    NSIndexPath *path = [tableView indexPathForRowAtPoint:touch_point];
    
    SASectionCell *section = [tableView cellForRowAtIndexPath:path];
    if ([section isKindOfClass:[SASectionCell class]]) {
        
    }
}


- (id<UIViewControllerInteractiveTransitioning>)panController {
    return _panTransition;
}

@end
