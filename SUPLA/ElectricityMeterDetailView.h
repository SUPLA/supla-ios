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

#import "DetailView.h"
#import "SADownloadElectricityMeasurements.h"
#import "SAChartFilterField.h"
#import "SAPreloader.h"
#import "SAWarningIcon.h"
@import Charts;

NS_ASSUME_NONNULL_BEGIN

@interface SAElectricityMeterDetailView : SADetailView <SARestApiClientTaskDelegate, SAChartFilterFieldDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UILabel *lConsumptionProduction;
@property (weak, nonatomic) IBOutlet UILabel *lTotalActiveEnergy;
@property (weak, nonatomic) IBOutlet UILabel *lTotalActiveEnergyValue;
@property (weak, nonatomic) IBOutlet UILabel *lConsumptionProductionValue;
@property (weak, nonatomic) IBOutlet UILabel *lCurrentCost;
@property (weak, nonatomic) IBOutlet UILabel *lTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *lFrequency;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cFrequencyTop;
@property (weak, nonatomic) IBOutlet UILabel *lFrequencyValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cFrequencyValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lVoltage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cVoltageTop;
@property (weak, nonatomic) IBOutlet UILabel *lVoltageValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cVoltageValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lCurrent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cCurrentTop;
@property (weak, nonatomic) IBOutlet UILabel *lCurrentValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cCurrentValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lActivePower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cActivePowerTop;
@property (weak, nonatomic) IBOutlet UILabel *lActivePowerValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cActivePowerValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lReactivePower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReactivePowerTop;
@property (weak, nonatomic) IBOutlet UILabel *lReactivePowerValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReactivePowerValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lApparentPower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cApparentPowerTop;
@property (weak, nonatomic) IBOutlet UILabel *lApparentPowerValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cApparentPowerValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lPowerFactor;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cPowerFactorTop;
@property (weak, nonatomic) IBOutlet UILabel *lPowerFactorValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cPowerFactorValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lPhaseAngle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cPhaseAngleTop;
@property (weak, nonatomic) IBOutlet UILabel *lPhaseAngleValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cPhaseAngleValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lForwardActiveEnergy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardActiveEnergyTop;
@property (weak, nonatomic) IBOutlet UILabel *lForwardActiveEnergyValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardActiveEnergyValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lReverseActiveEnergy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseActiveEnergyTop;
@property (weak, nonatomic) IBOutlet UILabel *lReverseActiveEnergyValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseActiveEnergyValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lForwardReactiveEnergy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardReactiveEnergyTop;
@property (weak, nonatomic) IBOutlet UILabel *lForwardReactiveEnergyValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardReactiveEnergyValueTop;
@property (weak, nonatomic) IBOutlet UILabel *lReverseReactiveEnergy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseReactiveEnergyTop;
@property (weak, nonatomic) IBOutlet UILabel *lReverseReactiveEnergyValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseReactiveEnergyValueTop;
@property (weak, nonatomic) IBOutlet UIButton *btnPhase1;
@property (weak, nonatomic) IBOutlet UIButton *btnPhase2;
@property (weak, nonatomic) IBOutlet UIButton *btnPhase3;
@property (weak, nonatomic) IBOutlet UIButton *btnPhaseSum;
- (IBAction)phaseBtnTouch:(id)sender;
- (IBAction)directionBtnTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnChart;
@property (weak, nonatomic) IBOutlet UIButton *btnDirection;
- (IBAction)chartBtnTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *vPhases;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet UIView *vCharts;
@property (weak, nonatomic) IBOutlet CombinedChartView *combinedChart;
@property (weak, nonatomic) IBOutlet PieChartView *pieChart;
@property (weak, nonatomic) IBOutlet SAPreloader *lPreloader;
@property (weak, nonatomic) IBOutlet SAChartFilterField *tfChartTypeFilter;
@property (weak, nonatomic) IBOutlet SAChartFilterField *ftDateRangeFilter;
@property (weak, nonatomic) IBOutlet UILabel *lForwardActiveEnergyBalance;
@property (weak, nonatomic) IBOutlet UILabel *lReverseActiveEnergyBalance;
@property (weak, nonatomic) IBOutlet UILabel *lForwardActiveEnergyValueBalance;
@property (weak, nonatomic) IBOutlet UILabel *lReverseActiveEnergyValueBalance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardActiveEnergyBalanceTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseActiveEnergyBalanceTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cForwardActiveEnergyValueBalanceTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cReverseActiveEnergyValueBalanceTop;
@property (weak, nonatomic) IBOutlet UILabel *lPhaseToPhase;
@property (weak, nonatomic) IBOutlet UIView *vLabelsBalance;
@property (weak, nonatomic) IBOutlet UIView *vValuesBalance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cIntLabelsTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cIntValuesTop;
@property (weak, nonatomic) IBOutlet SAWarningIcon *warningIcon;



@end

NS_ASSUME_NONNULL_END
