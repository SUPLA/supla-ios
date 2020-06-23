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

#import "TempHumidityDetailView.h"
#import "SATempHumidityChartHelper.h"
#import "SADownloadTempHumidityMeasurements.h"

@implementation SATempHumidityDetailView

-(SAChartHelper*)newChartHelper {
    return [[SATempHumidityChartHelper alloc] init];
}

-(SADownloadMeasurements*)newDownloadTask {
   return [[SADownloadTempHumidityMeasurements alloc] init];
}

- (void)updateView {
    [super updateView];
    [self.ivHumidityImage setImage:[self.channelBase getIconWithIndex:1]];
    [self.lHumidity setText:[[self.channelBase attrStringValueWithIndex:1 font:nil] string]];
}

-(void)detailWillShow {
    self.swTemperature.on = YES;
    self.swHumidity.on= YES;
    
    [super detailWillShow];
}

- (void)applyChartFilter {
    [super applyChartFilter];
    
    SATempHumidityChartHelper* chartHelper = (SATempHumidityChartHelper*)self.chartHelper;
    chartHelper.displayHumidity = self.swHumidity.on;
    chartHelper.displayTemperature = self.swTemperature.on;
}

- (IBAction)optionValueChanged:(id)sender {
    if (!self.swHumidity.on
        && !self.swTemperature.on) {
        if (sender == self.swHumidity) {
            self.swTemperature.on = YES;
        } else {
            self.swHumidity.on= YES;
        }
    }
    

    [self loadChartWithAnimation:YES moveToEnd:YES];
}

@end
