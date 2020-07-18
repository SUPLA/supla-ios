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

#import "SADialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAChannelStatePopup : SADialog
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *lTitle;
@property (weak, nonatomic) IBOutlet UILabel *lIPTitle;
@property (weak, nonatomic) IBOutlet UILabel *lIP;
@property (weak, nonatomic) IBOutlet UILabel *lMACTitle;
@property (weak, nonatomic) IBOutlet UILabel *lMAC;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryLevelTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryPoweredTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryPowered;
@property (weak, nonatomic) IBOutlet UILabel *lWifiRSSITitle;
@property (weak, nonatomic) IBOutlet UILabel *lWifiRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lWifiSignalStrengthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lWifiSignalStrength;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeOnlineTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeOnline;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeSignalStrengthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeSignalStrength;
@property (weak, nonatomic) IBOutlet UILabel *lUptimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lUptime;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionUptimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionUptime;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryHealthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryHealth;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionResetCauseTitle;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionResetCause;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceLifespanTitle;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceLifespan;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceOperatingTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceOperatingTime;
@property (weak, nonatomic) IBOutlet UIView *vList;

@end

NS_ASSUME_NONNULL_END
