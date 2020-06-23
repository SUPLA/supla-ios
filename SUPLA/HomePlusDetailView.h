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

#import <UIKit/UIKit.h>
#import "DetailView.h"
#import "SAThermostatCalendar.h"
#import "SAPreloader.h"

NS_ASSUME_NONNULL_BEGIN
@import Charts;

@class SAHomePlusCfgItem;
@protocol SAHomePlusCfgItemDelegate <NSObject>
@required
-(void) cfgItemChanged:(SAHomePlusCfgItem*)item;
@end

@interface SAHomePlusCfgItem : NSObject
@property (weak, nonatomic) id<SAHomePlusCfgItemDelegate> delegate;
@property (readonly, nonatomic) short cfgId;
@property (readonly, nonatomic) short value;
@end

@interface SAHomePlusDetailView : SADetailView <SARestApiClientTaskDelegate, SAHomePlusCfgItemDelegate, SAThermostatCalendarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lCfgEco;
@property (weak, nonatomic) IBOutlet UILabel *lCfgComfort;
@property (weak, nonatomic) IBOutlet UILabel *lCfgEcoReduction;
@property (weak, nonatomic) IBOutlet UILabel *lCfgWaterMax;
@property (weak, nonatomic) IBOutlet UILabel *lCfgTurbo;
@property (weak, nonatomic) IBOutlet UIButton *btnEcoPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnEcoMinus;
@property (weak, nonatomic) IBOutlet UIButton *btnComfortPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnComfortMinus;
@property (weak, nonatomic) IBOutlet UIButton *btnEcoReductionPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnEcoRecuctionMinus;
@property (weak, nonatomic) IBOutlet UIButton *btnWaterMaxMinus;
@property (weak, nonatomic) IBOutlet UIButton *btnWaterMaxPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnTurboMinus;
@property (weak, nonatomic) IBOutlet UIButton *btnTurboPlus;
@property (weak, nonatomic) IBOutlet UIView *vSettings;
@property (weak, nonatomic) IBOutlet SAThermostatCalendar *vCalendar;
@property (weak, nonatomic) IBOutlet UIView *vMain;
@property (weak, nonatomic) IBOutlet UIView *vError;
@property (weak, nonatomic) IBOutlet UILabel *lErrorMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cErrorHeight;
@property (weak, nonatomic) IBOutlet SAPreloader *lPreloader;
- (IBAction)calendarButtonTouched:(id)sender;
- (IBAction)settingsButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet CombinedChartView *combinedChart;
@property (weak, nonatomic) IBOutlet UITableView *tvChannels;
@property (weak, nonatomic) IBOutlet UIView *vCharts;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnSchedule;
@property (weak, nonatomic) IBOutlet UILabel *lTemperature;
@property (weak, nonatomic) IBOutlet UIButton *btnPlus;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOff;
@property (weak, nonatomic) IBOutlet UIButton *btnNormal;
@property (weak, nonatomic) IBOutlet UIButton *btnEco;
@property (weak, nonatomic) IBOutlet UIButton *btnTurbo;
@property (weak, nonatomic) IBOutlet UIButton *btnAuto;
- (IBAction)plusMinusTouched:(id)sender;
- (IBAction)onOffTouched:(id)sender;

@end

NS_ASSUME_NONNULL_END
