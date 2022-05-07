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
#import "SAChannelStatePopup.h"
#import "SAChannelCaptionEditor.h"
#import "SuplaApp.h"
#import "proto.h"
#import "UIColor+SUPLA.h"
#import "SUPLA-Swift.h"

#define CLEFT_MARGIN     5
#define CRIGHT_MARGIN    5
#define CTOP_MARGIN      5
#define CBOTTOM_MARGIN   5

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
    SAChannelBase *_channelBase;
    UITapGestureRecognizer *tapGr1;
    UITapGestureRecognizer *tapGr2;
    UILongPressGestureRecognizer *longPressGr;
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
}

- (void)initialize {
    if (_initialized) return;
    _initialized = YES;
    
    self.leftSwipeSettings.transition = MGSwipeTransitionRotate3D;
    self.rightSwipeSettings.transition = MGSwipeTransitionRotate3D;
    
    self.right_OnlineStatus.onlineColor = [UIColor onLine];
    self.right_OnlineStatus.offlineColor = [UIColor offLine];
    self.right_OnlineStatus.borderColor = [UIColor statusBorder];
    
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
    bg.backgroundColor = [UIColor whiteColor];
    [btn addSubview: bg];
    [bg.bottomAnchor constraintEqualToAnchor: btn.bottomAnchor].active = YES;
    [bg.leftAnchor constraintEqualToAnchor: btn.leftAnchor].active = YES;
    [bg.rightAnchor constraintEqualToAnchor: btn.rightAnchor].active = YES;
    [bg.heightAnchor constraintEqualToConstant: offset].active = YES;

    return btn;
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    //TODO: Add support for WINDSENSOR, PRESSURESENSOR, RAINSENSOR, WEIGHTSENSOR
    _channelBase = channelBase;
    BOOL isGroup = [channelBase isKindOfClass:[SAChannelGroup class]];
    SAChannel *channel = [channelBase isKindOfClass:[SAChannel class]] ? (SAChannel*)channelBase : nil;
    
    _measurementSubChannel = channel && channel.value
    && (channel.value.sub_value_type == SUBV_TYPE_IC_MEASUREMENTS
        || channel.value.sub_value_type == SUBV_TYPE_ELECTRICITY_MEASUREMENTS);
    
    self.channelStateIcon.hidden = YES;
    self.rightButtons = @[];
    self.leftButtons = @[];
    
    if (self.channelWarningIcon) {
        self.channelWarningIcon.channel = channelBase;
    }
    
    if ( isGroup ) {
        self.cint_LeftStatusWidth.constant = 6;
        self.cint_RightStatusWidth.constant = 6;
        self.right_ActiveStatus.percent = ((SAChannelGroup*)channelBase).activePercent;
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
        
        if ([channelBase isKindOfClass:[SAChannel class]] &&
            [Config new].showChannelInfo && [channel isOnline]) {
            UIImage *stateIcon = channel.stateIcon;
            if (stateIcon) {
                self.channelStateIcon.hidden = NO;
                self.channelStateIcon.image = stateIcon;
            }
        }
    }
    
    self.right_OnlineStatus.percent = [channelBase onlinePercent];
    self.left_OnlineStatus.percent = self.right_OnlineStatus.percent;

    [self.caption setText:[channelBase getNonEmptyCaption]];
    [self.image1 setImage:[channelBase getIconWithIndex:0]];
    [self.image2 setImage:[channelBase getIconWithIndex:1]];
    
    switch(channelBase.func) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
        case SUPLA_CHANNELFNC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER:
        case SUPLA_CHANNELFNC_IC_GAS_METER:
        case SUPLA_CHANNELFNC_IC_WATER_METER:
        case SUPLA_CHANNELFNC_IC_HEAT_METER:
        case SUPLA_CHANNELFNC_RGBLIGHTING:
        case SUPLA_CHANNELFNC_DIMMER:
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
        case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
        case SUPLA_CHANNELFNC_THERMOMETER:
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL:
        case SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
            self.left_OnlineStatus.hidden = YES;
            self.right_OnlineStatus.hidden = NO;
            break;
        case SUPLA_CHANNELFNC_POWERSWITCH:
        case SUPLA_CHANNELFNC_LIGHTSWITCH:
        case SUPLA_CHANNELFNC_STAIRCASETIMER:
        case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
            self.left_OnlineStatus.hidden = NO;
            self.right_OnlineStatus.hidden = NO;
            break;
        case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW:
        case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
        case SUPLA_CHANNELFNC_MAILSENSOR:
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
    
    
    if ( channelBase.func == SUPLA_CHANNELFNC_THERMOMETER ) {
        [self.temp setText:[[channelBase attrStringValue] string]];
    } else if ( channelBase.func== SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE ) {
        
        [self.temp setText:[[channelBase attrStringValue] string]];
        [self.humidity setText:[[channelBase attrStringValueWithIndex:1 font:nil] string]];
       
    } else if ( channelBase.func == SUPLA_CHANNELFNC_DEPTHSENSOR
                 || channelBase.func == SUPLA_CHANNELFNC_WINDSENSOR
                 || channelBase.func == SUPLA_CHANNELFNC_WEIGHTSENSOR
                 || channelBase.func == SUPLA_CHANNELFNC_PRESSURESENSOR
                 || channelBase.func == SUPLA_CHANNELFNC_RAINSENSOR
                 || channelBase.func == SUPLA_CHANNELFNC_HUMIDITY ) {
        [self.measuredValue setText:[[channelBase attrStringValue] string]];
    } else if ( channelBase.func == SUPLA_CHANNELFNC_DISTANCESENSOR  ) {
        [self.distance setText:[[channelBase attrStringValue] string]];
    } else if ( channelBase.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
                || channelBase.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
                || channelBase.func == SUPLA_CHANNELFNC_IC_WATER_METER
                || channelBase.func == SUPLA_CHANNELFNC_IC_GAS_METER
                || channelBase.func == SUPLA_CHANNELFNC_IC_HEAT_METER ) {
        
        [self.measuredValue setText:[[channelBase attrStringValue] string]];
                
    } else if ( channelBase.func == SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS ) {
        [self.temp setAttributedText:[channelBase attrStringValueWithIndex:0 font:self.temp.font]];
    } else {
        [self resetButtonState];
                
        if ( [channelBase isOnline] ) {
            MGSwipeButton *bl = nil;
            MGSwipeButton *br = nil;
            
            switch(channelBase.func) {
                case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Open", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Open Close", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
                case SUPLA_CHANNELFNC_POWERSWITCH:
                case SUPLA_CHANNELFNC_LIGHTSWITCH:
                case SUPLA_CHANNELFNC_STAIRCASETIMER:
                {
                    br = [self makeButtonWithTitle: NSLocalizedString(@"On", nil)];
                    bl = [self makeButtonWithTitle: NSLocalizedString(@"Off", nil)];
                    
                    if (_measurementSubChannel) {
                        [self.measuredValue setText:[[channelBase attrStringValue] string]];
                    }
                }
                    break;
                case SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Open", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    bl = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Close", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
            }
            
            if ( br ) {
                [br setButtonWidth:105];
                [br.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                //[br.titleLabel setFont:[UIFont fontWithName:@"OpenSens" size:10]];
                br.backgroundColor = [UIColor onLine];
                [self btn:br SetAction:@selector(rightTouchDown:)];
                self.rightButtons = @[br];
            }
            
            if ( bl ) {
                [bl setButtonWidth:105];
                [bl.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                //[bl.titleLabel setFont:[UIFont fontWithName:@"OpenSens" size:10]];
                bl.backgroundColor = [UIColor onLine];
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
    [sender setBackgroundColor: [UIColor btnTouched]];
    [sender setBackgroundColor: [UIColor onLine] withDelay:0.2];

    BOOL group = [self.channelBase isKindOfClass:[SAChannelGroup class]];
    
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
}

- (IBAction)leftTouchDown:(id)sender {
    [sender setBackgroundColor: [UIColor btnTouched]];
    [sender setBackgroundColor: [UIColor onLine] withDelay:0.2];

    [self vibrate];
    [[SAApp SuplaClient] cg:self.channelBase.remote_id Open:0 group:[self.channelBase isKindOfClass:[SAChannelGroup class]]];
    [self hideSwipeMaybe];
}

- (IBAction)rlTouchCancel:(id)sender {
    [sender setBackgroundColor: [UIColor onLine] withDelay:0.2];
    if([[Config alloc] init].autohideButtons)
        [self resetButtonState];
}

- (void)hideSwipeMaybe {
    if([[Config alloc] init].autohideButtons) {
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

   [SAChannelStatePopup.globalInstance show:(SAChannel*)self.channelBase];
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGR {
    if (self.captionEditable && self.channelBase != nil && longPressGR.state == UIGestureRecognizerStateBegan) {
        [[SAChannelCaptionEditor globalInstance] editCaptionWithRecordId:self.channelBase.remote_id];
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
    CGFloat channelScale = [Config new].channelHeightFactor;
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
