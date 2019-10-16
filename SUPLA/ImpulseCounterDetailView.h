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
#import "SADownloadImpulseCounterMeasurements.h"
#import "SAPreloader.h"
#import "SAChartFilterField.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAImpulseCounterDetailView : SADetailView <SARestApiClientTaskDelegate, SAChartFilterFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UILabel *lMeterValue;
@property (weak, nonatomic) IBOutlet UILabel *lCurrentConsumption;
@property (weak, nonatomic) IBOutlet UILabel *lCurrentCost;
@property (weak, nonatomic) IBOutlet UILabel *lTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *lCaption;
@property (weak, nonatomic) IBOutlet SAPreloader *lPreloader;
@property (weak, nonatomic) IBOutlet SAChartFilterField *tfChartTypeFilter;
@property (weak, nonatomic) IBOutlet SAChartFilterField *ftDateRangeFilter;
@property (weak, nonatomic) IBOutlet PieChartView *pieChart;
@property (weak, nonatomic) IBOutlet CombinedChartView *combinedChart;
- (IBAction)chartBtnTouch:(id)sender;

@end

NS_ASSUME_NONNULL_END
