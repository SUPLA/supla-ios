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

#import "UIColor+SUPLA.h"


@implementation UIColor (SUPLA)

+(UIColor*)onLine {
    return [UIColor colorWithRed:0.071 green:0.655 blue:0.118 alpha:1.000];
}

+(UIColor*)offLine {
    return [UIColor redColor];
}

+(UIColor*)btnTouched {
    return [UIColor colorWithRed:0.35 green:0.91 blue:0.40 alpha:1.0];
}

+(UIColor*)colorPickerDefault {
    return [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
}

+(UIColor*)statusYellow {
    return [UIColor colorWithRed:0.996 green:0.906 blue:0.000 alpha:1.000];
}

+(UIColor*)cellBackground {
    return [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
}

+(UIColor*)rgbwDetailBackground {
    return [UIColor colorWithRed: 0.93 green: 0.93 blue: 0.93 alpha: 1.00];
}

+(UIColor*)rgbwSelectedTabColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}

+(UIColor*)diwInputOptionSelected {
    return [UIColor colorWithRed: 1.00 green: 0.60 blue: 0.00 alpha: 1.00];
}

+(UIColor*)rgbwNormalTabColor {
    return [UIColor whiteColor];
}

+(UIColor*)rsDetailBackground {
    return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
}

+(nonnull UIColor*)statusBorder {
    return [UIColor blackColor];
}

+(nonnull UIColor*)rsMarkerColor {
    return [UIColor colorWithRed:0.07 green:0.65 blue:0.12 alpha:1.0];
}

+(nonnull UIColor*)phase1Color {
    return [UIColor colorWithRed:0.56 green:0.92 blue:1.00 alpha:1.0];
}

+(nonnull UIColor*)phase2Color {
    return [UIColor colorWithRed:0.59 green:0.57 blue:1.00 alpha:1.0];
}

+(nonnull UIColor*)phase3Color {
    return [UIColor colorWithRed:1.00 green:0.82 blue:0.57 alpha:1.0];
}

+(nonnull UIColor*)chartValuePositiveColor {
    return [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
}

+(nonnull UIColor*)chartValueNegativeColor {
    return [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
}

+(nonnull UIColor*)pickerViewColor {
    return [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
}

+(nonnull UIColor*)chartRoomTemperature {
    return [UIColor colorWithRed:0.00 green:0.76 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)hpBtnOn {
    return [UIColor colorWithRed:0.14 green:0.75 blue:0.13 alpha:1.0];
}

+(nonnull UIColor*)hpBtnOff {
    return [UIColor colorWithRed:0.94 green:0.27 blue:0.29 alpha:1.0];
}

+(nonnull UIColor*)hpBtnUnknown {
    return [UIColor colorWithRed:0.90 green:0.74 blue:0.49 alpha:1.0];
}

+(nonnull UIColor*)chartTemperatureFillColor {
    return [UIColor colorWithRed:0.99 green:0.97 blue:0.79 alpha:1.0];
}

+(nonnull UIColor*)chartTemperatureLineColor {
    return [UIColor colorWithRed:0.99 green:0.29 blue:0.30 alpha:1.0];
}

+(nonnull UIColor*)chartHumidityColor {
    return [UIColor colorWithRed:0.00 green:0.63 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)chartIncrementalValueColor {
    return [UIColor colorWithRed:0.00 green:0.63 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)menuSeparatorColor {
    return [UIColor colorWithRed: 0.98 green: 0.98 blue: 0.99 alpha: 0.4];
}

+(nonnull UIColor*)mainMenuColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}

+(nonnull UIColor*)vlCfgButtonColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}

+(BOOL) getFloat:(CGFloat*)f fromDictionary:(NSDictionary *)dict withKey:(NSString*)key {
   
    id n = [dict objectForKey:key];
    if (!n || ![n isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    
    *f = [(NSNumber*)n floatValue];
    return YES;
}

+(UIColor*)transformToColor:(id)obj {
    if (obj == nil) {
        return nil;
    }
    
    if ([obj isKindOfClass:[UIColor class]]) {
        return (UIColor*)obj;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        CGFloat red;
        if (![UIColor getFloat:&red fromDictionary:obj withKey:@"red"]) {
            return nil;
        }

        CGFloat green;
        if (![UIColor getFloat:&green fromDictionary:obj withKey:@"green"]) {
            return nil;
        }
        
        CGFloat blue;
        if (![UIColor getFloat:&blue fromDictionary:obj withKey:@"blue"]) {
            return nil;
        }
        
        CGFloat alpha;
        if (![UIColor getFloat:&alpha fromDictionary:obj withKey:@"alpha"]) {
            return nil;
        }
        
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    
    return nil;
}

+(NSDictionary*)transformToDictionary:(UIColor*)color {
    if (color == nil) {
        return nil;
    }
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return @{@"red":[NSNumber numberWithFloat:red],
             @"green":[NSNumber numberWithFloat:green],
             @"blue":[NSNumber numberWithFloat:blue],
             @"alpha":[NSNumber numberWithFloat:alpha],
    };
}

@end

