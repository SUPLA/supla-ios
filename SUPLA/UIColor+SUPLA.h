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

NS_ASSUME_NONNULL_BEGIN


@interface UIColor (SUPLA)
+(nonnull UIColor*)btnTouched;
+(nonnull UIColor*)onLine;
+(nonnull UIColor*)offLine;
+(nonnull UIColor*)colorPickerDefault;
+(nonnull UIColor*)statusYellow;
+(nonnull UIColor*)cellBackground;
+(nonnull UIColor*)rgbwDetailBackground;
+(nonnull UIColor*)rgbwSelectedTabColor;
+(nonnull UIColor*)rgbwNormalTabColor;
+(nonnull UIColor*)rsDetailBackground;
+(nonnull UIColor*)statusBorder;
+(nonnull UIColor*)rsMarkerColor;
+(nonnull UIColor*)phase1Color;
+(nonnull UIColor*)phase2Color;
+(nonnull UIColor*)phase3Color;
+(nonnull UIColor*)chartValuePositiveColor;
+(nonnull UIColor*)chartValueNegativeColor;
+(nonnull UIColor*)pickerViewColor;
+(nonnull UIColor*)chartRoomTemperature;
+(nonnull UIColor*)hpBtnOn;
+(nonnull UIColor*)hpBtnOff;
+(nonnull UIColor*)hpBtnUnknown;
+(nonnull UIColor*)chartTemperatureFillColor;
+(nonnull UIColor*)chartTemperatureLineColor;
+(nonnull UIColor*)chartHumidityColor;
+(nonnull UIColor*)chartIncrementalValueColor;
+(nonnull UIColor*)menuSeparatorColor;
+(nonnull UIColor*)mainMenuColor;
+(nonnull UIColor*)vlCfgButtonColor;
+(nonnull UIColor*)diwInputOptionSelected;
+(UIColor*)transformToColor:(id)obj;
+(NSDictionary*)transformToDictionary:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
