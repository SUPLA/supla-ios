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


#import "SAFormatter.h"

@implementation SAFormatter

- (NSString*)doubleToString:(double)dbl withUnit:(nullable NSString *)unit maxPrecision:(short)max {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:NO];
    [formatter setMaximumFractionDigits:50];
    [formatter setMinimumFractionDigits:2];
    NSString *sdbl = [formatter stringFromNumber:[NSNumber numberWithDouble:dbl]];

    NSInteger a;
    for(a=sdbl.length-1;a>=0;a--) {
        char c = [sdbl characterAtIndex:a];
        if (c == ',' || c == '.') {
            NSInteger p = sdbl.length-a-1;
            if (max < p) {
                sdbl = [sdbl substringToIndex:a+max+(max > 0 ? 1 : 0)];
            }
            
            if (max > 0) {
                p = a;
                a = sdbl.length-1;
                
                while (a >= p) {
                    if ([sdbl characterAtIndex:a] != '0' || a-p <= 2) {
                        sdbl = [sdbl substringToIndex:a+1];
                        break;
                    }
                    a--;
                }
            }
            break;
        }
    }

    if (unit == nil) {
        return sdbl;
    }
    
    return [NSString stringWithFormat:@"%@ %@", sdbl, unit];
}

@end
