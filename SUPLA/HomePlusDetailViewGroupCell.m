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

#import "HomePlusDetailViewGroupCell.h"
#import "SAThermostatHPExtendedValue.h"
#import "SAChannel+CoreDataClass.h"

#import "UIColor+SUPLA.h"
#import "UIButton+SUPLA.h"

@implementation HomePlusDetailViewGroupCell {
    SAChannelBase *_channelBase;
}

- (void)setOn:(BOOL)on {
    [self.bOnOff setTitle:NSLocalizedString(on ? @"ON" : @"OFF", nil)];
    self.bOnOff.backgroundColor = on ? [UIColor hpBtnOn] : [UIColor hpBtnOff];
}

- (void)setNormalOn:(BOOL)on {
    self.bNormal.backgroundColor = on ? [UIColor hpBtnOn] : [UIColor hpBtnOff];
}

- (void)setEcoOn:(BOOL)on {
    self.bEco.backgroundColor = on ? [UIColor hpBtnOn] : [UIColor hpBtnOff];
}

- (void)setAutoOn:(BOOL)on {
    self.bAuto.backgroundColor = on ? [UIColor hpBtnOn] : [UIColor hpBtnOff];
}

- (void)setTurboOn:(BOOL)on {
    self.bTurbo.backgroundColor = on ? [UIColor hpBtnOn] : [UIColor hpBtnOff];
}

- (void)setChannelBase:(SAChannelBase *)channelBase {
    _channelBase = channelBase;
    
    self.status.percent = 0;
    [self setOn:NO];
    [self setNormalOn:NO];
    [self setEcoOn:NO];
    [self setAutoOn:NO];
    [self setTurboOn:NO];
    
    self.status.shapeType = stDot;
    if (_channelBase != nil) {
        self.status.percent = _channelBase.onlinePercent;
        
        if (_channelBase.onlinePercent == 100) {
            SAThermostatHPExtendedValue *thev = nil;
            if (![self.channelBase isKindOfClass:SAChannel.class]
                || (thev = ((SAChannel*)self.channelBase).ev.thermostatHP) == nil) {
                return;
            }
            
            [self setOn:[thev isThermostatOn]];
            [self setNormalOn:[thev isNormalOn]];
            [self setEcoOn:[thev isEcoRecuctionApplied]];
            [self setAutoOn:[thev isAutoOn]];
            [self setTurboOn:[thev isTurboOn]];
            
            [self.lCaption setText:[NSString stringWithFormat:@"%@ | %@", [channelBase getNonEmptyCaption], [[channelBase attrStringValue] string]]];
            
        } else {
            [self.lCaption setText:[channelBase getNonEmptyCaption]];
        }
    }
}

- (SAChannelBase*)channelBase {
    return _channelBase;
}
@end
