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

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ChannelCell.h"
#import "MGSwipeButton.h"
#import "SAChannel+CoreDataClass.h"
#import "SAChannelGroup+CoreDataClass.h"
#import "SAChannelStateExtendedValue.h"
#import "SuplaApp.h"
#import "proto.h"
#import "SUPLA-Swift.h"
#import "SharedCore/SharedCore.h"


@interface MGSwipeTableCell (ExposePrivateMethods)
-(void)panHandler: (UIPanGestureRecognizer *)gesture;
@end

@implementation MGSwipeTableCell (SUPLA)
@end

@implementation MGSwipeButton (SUPLA)

-(void) setBackgroundColor:(UIColor *)backgroundColor withDelay:(NSTimeInterval) delay {
    [self performSelector:@selector(setBackgroundColor:) withObject:backgroundColor afterDelay:delay];
}

@end

@implementation SAChannelCell {
    BOOL _initialized;
    BOOL _captionTouched;
    BOOL _measurementSubChannel;
    BOOL _showChannelInfo;
    SAChannelBase *_channelBase;
    DisposeBagContainer *_disposeBagContainer;
    UITapGestureRecognizer *tapGr1;
    UITapGestureRecognizer *tapGr2;
    UILongPressGestureRecognizer *longPressGr;
    SharedCoreGetChannelActionStringUseCase *getChannelActionStringUseCase;
}

@synthesize captionEditable;
-(void) prepareForReuse {
    /* Disable delagate when preparation for reuse is happening. Otherwise
       delegate would receive button hide notifications which is unintended
       (data source is going to reset button states anyway. */
    id<MGSwipeTableCellDelegate> savedDelegate = self.delegate;
    self.delegate = nil;
    [super prepareForReuse];
    self.delegate = savedDelegate;
    
    _disposeBagContainer = [[DisposeBagContainer alloc] init];
    getChannelActionStringUseCase = [[SharedCoreGetChannelActionStringUseCase alloc] init];
}

- (void)initialize {
    if (_initialized) return;
    _initialized = YES;
    _disposeBagContainer = [[DisposeBagContainer alloc] init];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionRotate3D;
    self.rightSwipeSettings.transition = MGSwipeTransitionRotate3D;
    
    self.right_OnlineStatus.onlineColor = [UIColor primary];
    self.right_OnlineStatus.offlineColor = [UIColor error];
    self.right_OnlineStatus.borderColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor surface];
    self.backgroundColor = [UIColor surface];
    self.bottomLine.backgroundColor = [UIColor separator];
    
    [self.left_OnlineStatus assignColors:self.right_OnlineStatus];
    [self.right_ActiveStatus assignColors:self.right_OnlineStatus];

    
    if (self.channelStateIcon) {
        self.channelStateIcon.userInteractionEnabled = YES;
        tapGr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateIconTapped:)];
        [self.channelStateIcon addGestureRecognizer:tapGr1];
    }
        
    longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPressGr.allowableMovement = 5;
    longPressGr.minimumPressDuration = 0.8;
    self.caption.userInteractionEnabled = YES;
    [self.caption addGestureRecognizer:longPressGr];
    
    CGFloat scaleFactor = [self iconScaleFactor];
    for(NSLayoutConstraint *constraint in self.channelIconScalableConstraints) {
        constraint.constant *= scaleFactor;
    }
    
    self.durationTimer.font = UIFont.body2;
    self.durationTimer.textColor = UIColor.gray;
    
    [self.caption setFont: UIFont.cellCaptionFont];
    self.caption.textColor = [UIColor onBackground];
    self.measuredValue.textColor = [UIColor onBackground];
    self.temp.textColor = [UIColor onBackground];
    self.humidity.textColor = [UIColor onBackground];
    self.distance.textColor = [UIColor onBackground];
}

- (DisposeBagContainer *) getDisposeBagContainer {
    return _disposeBagContainer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(SAChannelBase*)channelBase {
    return _channelBase;
}

-(void)btn:(UIButton *)btn SetAction:(SEL)sel {
    
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    
}

- (MGSwipeButton *)makeButtonWithTitle: (NSString *)title {
    MGSwipeButton *btn = [MGSwipeButton buttonWithTitle: title
                                                   icon: nil
                                        backgroundColor: [UIColor blackColor]];
    CGFloat offset = 5;
    UIView *bg = [[UIView alloc] init];
    bg.translatesAutoresizingMaskIntoConstraints = NO;
    bg.backgroundColor = [UIColor surface];
    [btn addSubview: bg];
    [bg.bottomAnchor constraintEqualToAnchor: btn.bottomAnchor].active = YES;
    [bg.leftAnchor constraintEqualToAnchor: btn.leftAnchor].active = YES;
    [bg.rightAnchor constraintEqualToAnchor: btn.rightAnchor].active = YES;
    [bg.heightAnchor constraintEqualToConstant: offset].active = YES;

    return btn;
}

-(void) setShowChannelInfo: (BOOL)showChannelInfo {
    _showChannelInfo = showChannelInfo;
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    _channelBase = channelBase;
    [self updateCellView];
    
    [self observeChannelBaseChanges: _channelBase.remote_id];
}

-(void) updateChannelBase:(SAChannelBase *)channelBase {
    _channelBase = channelBase;
    [self updateCellView];
}

-(void) updateTimerDurationView {
    if (timerEndTime == nil) {
        self.durationTimer.hidden = YES;
        return;
    }
    
    self.durationTimer.hidden = NO;
    
    NSDate* currentTime = [[NSDate alloc] init];
    int leftTime = (int) ([timerEndTime timeIntervalSince1970] - [currentTime timeIntervalSince1970]);
    self.durationTimer.text = [NSString stringWithFormat: @"%02d:%02d:%02d",
                               leftTime / 3600,
                               (leftTime / 60) % 60,
                               leftTime % 60];
}

-(void) setupTimerWithChannel: (SAChannel*) channel {
    if (timer != nil) {
        [timer invalidate];
        timerEndTime = nil;
        [self updateTimerDurationView];
    }
    
    SAChannelExtendedValue* extendedValue = channel.ev;
    if (extendedValue == nil) {
        return;
    }
    TimerState* timerState = [extendedValue timerState];
    if (timerState == nil) {
        return;
    }
    timerEndTime = timerState.countdownEndsAt;
    if (timerEndTime == nil || [timerEndTime timeIntervalSinceDate: [[NSDate alloc] init]] < 1) {
        return;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimerDurationView) userInfo:nil repeats:YES];
}

-(void) updateCellView {
    BOOL isGroup = [_channelBase isKindOfClass:[SAChannelGroup class]];
    SAChannel *channel = [_channelBase isKindOfClass:[SAChannel class]] ? (SAChannel*)_channelBase : nil;
    
    _measurementSubChannel = channel && channel.value
    && (channel.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS
        || channel.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS);
    
    self.channelStateIcon.hidden = YES;
    self.durationTimer.hidden = YES;
    self.rightButtons = @[];
    self.leftButtons = @[];
    
    if (self.channelWarningIcon) {
        self.channelWarningIcon.channel = _channelBase;
    }
    
    if ( isGroup ) {
        self.cint_LeftStatusWidth.constant = 6;
        self.cint_RightStatusWidth.constant = 6;
        self.right_ActiveStatus.percent = [UseCaseLegacyWrapper getActivePercentage:(SAChannelGroup*)_channelBase];
        self.right_ActiveStatus.singleColor = YES;
        self.right_ActiveStatus.hidden = NO;
        self.right_OnlineStatus.shapeType = stLinearVertical;
        self.left_OnlineStatus.shapeType = stLinearVertical;
    } else {
        self.cint_LeftStatusWidth.constant = 10;
        self.cint_RightStatusWidth.constant = 10;
        self.right_ActiveStatus.hidden = YES;
        self.right_OnlineStatus.shapeType = stDot;
        self.left_OnlineStatus.shapeType = stDot;
        
        if (channel != nil) {
            if (_showChannelInfo && [channel status].online) {
                UIImage *stateIcon = channel.stateIcon;
                if (stateIcon) {
                    self.channelStateIcon.tintColor = UIColor.onBackground;
                    self.channelStateIcon.hidden = NO;
                    self.channelStateIcon.image = stateIcon;
                }
            }
            [self setupTimerWithChannel: channel];
        }
    }
    
    self.right_OnlineStatus.percent = [_channelBase onlinePercent];
    self.left_OnlineStatus.percent = self.right_OnlineStatus.percent;

    [self.caption setText:[_channelBase getNonEmptyCaption]];
    [self.image1 setImage:[_channelBase getIconWithIndex:0]];
    [self.image2 setImage:[_channelBase getIconWithIndex:1]];
    
    switch(_channelBase.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
        case SUPLA_CHANNELFNC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_GAS_METER:
        case SUPLA_CHANNELFNC_IC_WATER_METER:
        case SUPLA_CHANNELFNC_IC_HEAT_METER:
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
        case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
            self.left_OnlineStatus.hidden = YES;
            self.right_OnlineStatus.hidden = NO;
            break;
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
            self.left_OnlineStatus.hidden = NO;
            self.right_OnlineStatus.hidden = NO;
            break;
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
        case SUPLA_CHANNELFNC_TERRACE_AWNING:
        case SUPLA_CHANNELFNC_PROJECTOR_SCREEN:
        case SUPLA_CHANNELFNC_CURTAIN:
        case SUPLA_CHANNELFNC_VERTICAL_BLIND:
        case SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR:
            self.left_OnlineStatus.hidden = YES;
            self.right_OnlineStatus.hidden = NO;
            break;
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
        case SUPLA_CHANNELFNC_HOTELCARDSENSOR:
        case SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
        case SUPLA_CHANNELFNC_MAILSENSOR:
        case SUPLA_CHANNELFNC_THERMOMETER:
        case SUPLA_CHANNELFNC_PUMPSWITCH:
        case SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH:
            self.left_OnlineStatus.hidden = NO;
            self.right_OnlineStatus.hidden = NO;
            self.right_OnlineStatus.shapeType = stRing;
            self.left_OnlineStatus.shapeType = stRing;
            break;
        default:
            self.left_OnlineStatus.hidden = YES;
            self.right_OnlineStatus.hidden = YES;
            break;
    }
    
    
    if ( _channelBase.func == SUPLA_CHANNELFNC_THERMOMETER ) {
        self.temp.font = UIFont.cellValueFont;
        [self.temp setText:[[_channelBase attrStringValue] string]];
    } else if ( _channelBase.func== SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE ) {
        self.temp.font = UIFont.cellValueFont;
        self.humidity.font = UIFont.cellValueFont;
        [self.temp setText:[[_channelBase attrStringValue] string]];
        [self.humidity setText:[[_channelBase attrStringValueWithIndex:1 font:nil] string]];
       
    } else if ( _channelBase.func == SUPLA_CHANNELFNC_DEPTHSENSOR
                 || _channelBase.func == SUPLA_CHANNELFNC_WINDSENSOR
                 || _channelBase.func == SUPLA_CHANNELFNC_WEIGHTSENSOR
                 || _channelBase.func == SUPLA_CHANNELFNC_PRESSURESENSOR
                 || _channelBase.func == SUPLA_CHANNELFNC_RAINSENSOR
                 || _channelBase.func == SUPLA_CHANNELFNC_HUMIDITY ) {
        
        self.measuredValue.font = UIFont.cellValueFont;
        [self.measuredValue setText:[[_channelBase attrStringValue] string]];
    } else if ( _channelBase.func == SUPLA_CHANNELFNC_DISTANCESENSOR  ) {
        self.distance.font = UIFont.cellValueFont;
        [self.distance setText:[[_channelBase attrStringValue] string]];
    } else if ( _channelBase.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
                || _channelBase.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
                || _channelBase.func == SUPLA_CHANNELFNC_IC_WATER_METER
                || _channelBase.func == SUPLA_CHANNELFNC_IC_GAS_METER
                || _channelBase.func == SUPLA_CHANNELFNC_IC_HEAT_METER ) {
        
        self.measuredValue.font = UIFont.cellValueFont;
        [self.measuredValue setText:[[_channelBase attrStringValue] string]];
                
    } else {
        if ( _channelBase.func == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS ) {
            self.temp.font = UIFont.cellValueFont;
            [self.temp setAttributedText:[_channelBase attrStringValueWithIndex:0 font:self.temp.font]];
        }
        
        [self resetButtonState];
                
        if ( [_channelBase status].online ) {
            MGSwipeButton *bl = nil;
            MGSwipeButton *br = nil;
            
            NSString *leftButtonText = [self leftButtonText:getChannelActionStringUseCase :_channelBase];
            if (leftButtonText != nil) {
                bl = [MGSwipeButton buttonWithTitle:leftButtonText icon:nil backgroundColor:[UIColor blackColor]];
            }
            NSString *rightButtonText = [self rightButtonText:getChannelActionStringUseCase :_channelBase];
            if (rightButtonText != nil) {
                br = [MGSwipeButton buttonWithTitle:rightButtonText icon:nil backgroundColor:[UIColor blackColor]];
            }
            
            switch(_channelBase.func) {
                case SUPLA_CHANNELFNC_POWERSWITCH:
                case SUPLA_CHANNELFNC_LIGHTSWITCH:
                case SUPLA_CHANNELFNC_STAIRCASETIMER:
                case SUPLA_CHANNELFNC_RGBLIGHTING:
                case SUPLA_CHANNELFNC_DIMMER:
                case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                    if (_measurementSubChannel) {
                        [self.measuredValue setText:[[_channelBase attrStringValue] string]];
                    }
                    break;
            }
            
            if ( br ) {
                [br setButtonWidth:105];
                [br.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                br.backgroundColor = [UIColor primary];
                [self btn:br SetAction:@selector(rightTouchDown:)];
                self.rightButtons = @[br];
            }
            
            if ( bl ) {
                [bl setButtonWidth:105];
                [bl.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                bl.backgroundColor = [UIColor primary];
                [self btn:bl SetAction:@selector(leftTouchDown:)];
                self.leftButtons = @[bl];
            }
            
        }
        
    }
    
    [self refreshContentView];
}

- (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)showValveAlertDialog {
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"SUPLA"
                                 message:NSLocalizedString(@"The valve has been closed in manual mode. Before you open it, make sure it has not been closed due to flooding. To turn off the warning, open the valve manually. Are you sure you want to open it from the application ?!", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesBtn = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Yes", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
            [self vibrate];
            [[SAApp SuplaClient] cg:self.channelBase.remote_id Open:1 group:false];
        
    }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"No", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
    }];
    
    
    [alert setTitle: NSLocalizedString(@"Warning", nil)];
    [alert addAction:noBtn];
    [alert addAction:yesBtn];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
}

- (IBAction)rightTouchDown:(id)sender {
    [sender setBackgroundColor: [UIColor buttonPressed]];
    [sender setBackgroundColor: [UIColor primary] withDelay:0.2];

    BOOL group = [self.channelBase isKindOfClass:[SAChannelGroup class]];
    
    if (_channelBase.isRGBW || _channelBase.func == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS) {
        [self turnOn: self.channelBase];
        [self hideSwipeMaybe];
        return;
    }
    if (_channelBase.isShadingSystem) {
        [self reveal: self.channelBase];
        [self hideSwipeMaybe];
        return;
    }
    
    if ([SAApp.SuplaClient turnOn:YES remoteId:_channelBase.remote_id group:group channelFunc:_channelBase.func vibrate:YES]) {
        [self hideSwipeMaybe];
        return;
    }
    
      if ((_channelBase.func == SUPLA_CHANNELFNC_VALVE_OPENCLOSE
          || _channelBase.func == SUPLA_CHANNELFNC_VALVE_PERCENTAGE)
          && (_channelBase.isManuallyClosed || _channelBase.flooding)
          && _channelBase.isClosed) {
          [self hideSwipeMaybe];
          [self showValveAlertDialog];
          return;
      }
    
    [self vibrate];
    
    [[SAApp SuplaClient] cg:self.channelBase.remote_id Open:1 group:group];
    [self hideSwipeMaybe];
    [self notifyDelegate];
}

- (IBAction)leftTouchDown:(id)sender {
    [sender setBackgroundColor: [UIColor buttonPressed]];
    [sender setBackgroundColor: [UIColor primary] withDelay:0.2];
    
    if (_channelBase.isRGBW || _channelBase.func == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS) {
        [self turnOff: self.channelBase];
        [self hideSwipeMaybe];
        return;
    }
    if (_channelBase.isShadingSystem) {
        [self shut: self.channelBase];
        [self hideSwipeMaybe];
        return;
    }

    [self vibrate];
    [[SAApp SuplaClient] cg:self.channelBase.remote_id Open:0 group:[self.channelBase isKindOfClass:[SAChannelGroup class]]];
    [self hideSwipeMaybe];
    [self notifyDelegate];
}

- (void)notifyDelegate {
    if([self.delegate conformsToProtocol: @protocol(SAChannelCellDelegate)]) {
        [((id<SAChannelCellDelegate>)self.delegate) channelButtonClicked: self];
    }
}

- (IBAction)rlTouchCancel:(id)sender {
    [sender setBackgroundColor: [UIColor primary] withDelay:0.2];
    if([GlobalSettingsLegacy new].autohideButtons)
        [self resetButtonState];
}

- (void)hideSwipeMaybe {
    if([GlobalSettingsLegacy new].autohideButtons) {
        [self hideSwipeAnimated:YES];
        [self resetButtonState];
    }
}

- (void)resetButtonState {
    if([self.delegate respondsToSelector: @selector(swipeTableCell:didChangeSwipeState:gestureIsActive:)]) {
        [self.delegate swipeTableCell:self didChangeSwipeState:MGSwipeStateNone gestureIsActive:NO];
    }
}

- (void)stateIconTapped:(UITapGestureRecognizer *)tapRecognizer {
    if (self.channelBase == nil
        || ![self.channelBase isKindOfClass:[SAChannel class]]
        || self.channelStateIcon == nil
        || self.channelStateIcon.hidden) {
        return;
    }

    [((id<SAChannelCellDelegate>)self.delegate) infoIconPressed: self.channelBase.remote_id];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGR {
    if (self.captionEditable && self.channelBase != nil && longPressGR.state == UIGestureRecognizerStateBegan) {
        if([self.delegate conformsToProtocol: @protocol(SAChannelCellDelegate)]) {
            [((id<SAChannelCellDelegate>)self.delegate) channelCaptionLongPressed: self.channelBase.remote_id];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    _captionTouched = self.captionEditable && touch != nil && touch.view == self.caption;
}

- (BOOL)captionTouched {
    return _captionTouched;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([super gestureRecognizerShouldBegin:gestureRecognizer]) {
        if (_measurementSubChannel
            && self.swipeState == MGSwipeStateSwipingRightToLeft
            && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]]) {
            
            CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
            if (translation.x < 0) {
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}


- (CGFloat)iconScaleFactor {
    CGFloat channelScale = [GlobalSettingsLegacy new].channelHeightFactor;
    return MIN(1.0, channelScale);
}


-(void)panHandler: (UIPanGestureRecognizer *)gesture {
    [super panHandler: gesture];
    
    if((gesture.state == UIGestureRecognizerStateEnded ||
       gesture.state == UIGestureRecognizerStateCancelled) &&
       [self.delegate respondsToSelector: @selector(swipeTableCell:didChangeSwipeState:gestureIsActive:)]) {
       [self.delegate swipeTableCell: self
                 didChangeSwipeState: self.swipeState
                     gestureIsActive: NO];
    }
}
@end
