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

}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ( cell != nil
        && [cell isKindOfClass:[SAChannelCell class]]
        && !((SAChannelCell*)cell).captionTouched) {
        NSItemProvider *itemProvicer = [[NSItemProvider alloc] init];
        UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvicer];
        dragItem.localObject = cell;
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onDataChanged {
    _cFrc = nil;
    _gFrc = nil;
    _locations = nil;
    
    [self.cTableView reloadData];
    [self.gTableView reloadData];
}

-(void)onMenubarBackButtonPressed {
    [(SAMainView*)self.view onMenubarBackButtonPressed];
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
    [(SAMainView*)self.view detailShow:NO animated:NO];
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
        _SALocation *location = [self locationByName:sectionInfo.name];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SAChannelBase *channel_base = [[self frcForTableView:tableView] objectAtIndexPath:indexPath];
    SAChannelCell *cell = nil;
    
    NSString *identifier = @"ChannelCell";
    
    if ( channel_base ) {
        
        SAChannel *channel = [channel_base isKindOfClass:[SAChannel class]] ? (SAChannel*)channel_base : nil;
        
        switch(channel_base.func) {
            case SUPLA_CHANNELFNC_POWERSWITCH:
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
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
    
    cell =  [tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (cell != nil) {
        cell.channelBase = channel_base;
        cell.captionEditable = tableView == self.cTableView;
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SASectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
    if ( cell ) {
        NSString *name = [[[[self frcForTableView:tableView] sections] objectAtIndex:section] name];
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

- (void)groupTableHidden:(BOOL)hidden {
    self.cTableView.hidden = !hidden;
    self.gTableView.hidden = hidden;
    
    [self onDataChanged];
}

- (IBAction)settingsTouched:(id)sender {
    
    [[SAApp UI ] showSettings];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[SARateApp alloc] init] showDialogWithDelay: 1];
    [self runDownloadTask];
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

@end

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

@implementation SAMainView {
    UIPanGestureRecognizer *_panRecognizer;
    
    SAChannelCell *cell;
    SARGBWDetailView *_rgbwDetailView;
    SARSDetailView *_rsDetailView; // Roller Shutter detail view
    SAElectricityMeterDetailView *_electricityMeterDetailView;
    SAImpulseCounterDetailView *_impulseCounterDetailView;
    SATemperatureDetailView *_temperatureDetailView;
    SATempHumidityDetailView *_tempHumidityDetailView;
    SAHomePlusDetailView *_homePlusDetailView;
    SADigiglassDetailView *_digiglassDetailView;
    
    SADetailView *_detailView;
    
    float last_touched_x;
    BOOL _animating;
}

-(void)initMainView {
    
    cell = nil;
    
    _rgbwDetailView = nil;
    _electricityMeterDetailView = nil;
    _impulseCounterDetailView = nil;
    _homePlusDetailView = nil;
    _tempHumidityDetailView = nil;
    _temperatureDetailView = nil;
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
    
    SAChannel *channel = [_cell.channelBase isKindOfClass:[SAChannel class]] ? (SAChannel*)_cell.channelBase : nil;
    
    if ( _cell.channelBase.isOnline && self.superview != nil) {
        
        if (channel && (channel.type == SUPLA_CHANNELTYPE_ELECTRICITY_METER
            || (channel.value && channel.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS))) {
            // TODO: Remove channel type checking in future versions. Check function instead of type. Issue #82
            if ( _electricityMeterDetailView == nil ) {
                
                _electricityMeterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"ElectricityMeterDetailView" owner:self options:nil] objectAtIndex:0];
                [_electricityMeterDetailView detailViewInit];
            }
            
            result = _electricityMeterDetailView;
        } else if (channel && (channel.type == SUPLA_CHANNELTYPE_IMPULSE_COUNTER
            || (channel.value && channel.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS))) {
            // TODO: Remove channel type checking in future versions. Check function instead of type. Issue #82
            if ( _impulseCounterDetailView == nil ) {
                
                _impulseCounterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"ImpulseCounterDetailView" owner:self options:nil] objectAtIndex:0];
                [_impulseCounterDetailView detailViewInit];
            }
            
            result = _impulseCounterDetailView;
        } else {
            switch(_cell.channelBase.func) {
                case SUPLA_CHANNELFNC_DIMMER:
                case SUPLA_CHANNELFNC_RGBLIGHTING:
                case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                    
                    if ( _rgbwDetailView == nil ) {
                        
                        _rgbwDetailView = [[[NSBundle mainBundle] loadNibNamed:@"RGBWDetail" owner:self options:nil] objectAtIndex:0];
                        [_rgbwDetailView detailViewInit];
                        
                    }
                    
                    result = _rgbwDetailView;
                    break;
                    
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                    
                    if ( _rsDetailView == nil ) {
                        
                        _rsDetailView = [[[NSBundle mainBundle] loadNibNamed:@"RSDetail" owner:self options:nil] objectAtIndex:0];
                        [_rsDetailView detailViewInit];
                        
                    }
                    
                    result = _rsDetailView;
                    break;
                    
                case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                    
                    if ( _homePlusDetailView == nil ) {
                        
                        _homePlusDetailView = [[[NSBundle mainBundle] loadNibNamed:@"HomePlusDetailView" owner:self options:nil] objectAtIndex:0];
                        [_homePlusDetailView detailViewInit];
                        
                    }
                    
                    result = _homePlusDetailView;
                    break;
                case SUPLA_CHANNELFNC_THERMOMETER:
                    
                    if ( _temperatureDetailView == nil ) {
                        
                        _temperatureDetailView = [[[NSBundle mainBundle] loadNibNamed:@"TemperatureDetailView" owner:self options:nil] objectAtIndex:0];
                        [_temperatureDetailView  detailViewInit];
                        
                    }
                    
                    result = _temperatureDetailView;
                    break;
                case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
                    
                    if ( _tempHumidityDetailView == nil ) {
                        
                        _tempHumidityDetailView = [[[NSBundle mainBundle] loadNibNamed:@"TempHumidityDetailView" owner:self options:nil] objectAtIndex:0];
                        [_tempHumidityDetailView  detailViewInit];
                        
                    }
                    
                    result = _tempHumidityDetailView;
                    break;
                case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
                case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
                    if ( _digiglassDetailView == nil ) {
                        
                        _digiglassDetailView  = [[[NSBundle mainBundle] loadNibNamed:@"DigiglassDetailView" owner:self options:nil] objectAtIndex:0];
                        [_digiglassDetailView   detailViewInit];
                        
                    }
                    
                    result = _digiglassDetailView;
                    break;
            };
        }
        
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
    
    if (_detailView) {
        if (show) {
            [_detailView detailWillShow];
        } else {
            [_detailView detailWillHide];
        }
    }
        
    if ( animated ) {
                
        [UIView animateWithDuration:0.2
                         animations:^{
            
            float multiplier = 1;
            
            if ( show ) {
                multiplier = -1;
            }
            
            [self setCenter:CGPointMake((self.frame.size.width/2) * multiplier, self.center.y)];
            [self->_detailView setFrame:[self getDetailFrame]];
            
            
        }
                         completion:^(BOOL finished){
            
            if ( show == NO ) {
                
                if ( self->_detailView ) {
                    [self->_detailView removeFromSuperview];
                    [self->_detailView detailDidHide];
                    self->_detailView = nil;
                }
                
                if ( self->cell ) {
                    self->cell.contentView.backgroundColor = [UIColor cellBackground];
                    self->cell = nil;
                }
                
            } else if (self->_detailView) {
                [self->_detailView detailDidShow];
            }
            
            
            self->_animating = NO;
        }];
        
    } else {
        
        if ( show == NO ) {
            
            [self setCenter:CGPointMake(self.frame.size.width/2, self.center.y)];
            
            if ( _detailView ) {
                [_detailView removeFromSuperview];
                [_detailView detailDidHide];
                _detailView = nil;
            }
            
            if ( cell ) {
                cell.contentView.backgroundColor = [UIColor cellBackground];
                cell = nil;
            }
            
        } else if (_detailView) {
            [_detailView detailDidShow];
        }
        
    }
    
}

- (void)onMenubarBackButtonPressed {
    if (_detailView
        && _detailView.superview
        && [_detailView onMenubarBackButtonPressed]) {
        [self detailShow:NO animated:YES];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    if ( _animating )
        return;
    
    UITableView *tableView = self.cTableView.hidden ? self.gTableView : self.cTableView;
    
    CGPoint touch_point = [gr locationInView:tableView];
    
    if ( gr.state == UIGestureRecognizerStateEnded
        && _detailView != nil ) {
        
        [self detailShow:self.frame.origin.x*-1 > self.frame.size.width/3.5 ? YES : NO animated:YES];
        
        if (cell != nil && [cell isKindOfClass:[MGSwipeTableCell class]]) {
            [(MGSwipeTableCell*)cell hideSwipeAnimated:YES];
        }
        
        return;
    }
    
    NSIndexPath *path = [tableView indexPathForRowAtPoint:touch_point];
    
    if ( path != nil ) {
        
        if ( cell == nil ) {
            cell = [tableView cellForRowAtIndexPath:path];
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
    [[SAApp UI] showGroupBtn:self.frame.origin.x == 0];
}

-(void)moveCenter:(float)x_offset {
    [self setCenter:CGPointMake(self.center.x+x_offset, self.center.y)];
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

@end
