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

#import "SAThermostatCalendar.h"

@implementation SAThermostatCalendar {
    BOOL initialized;
    NSString *_program0Label;
    NSString *_program1Label;
    UIColor *_program0Color;
    UIColor *_program1Color;
    short _firstDay;
    CGFloat _textSize;
    UIColor *_textColor;
    BOOL _HourProgramGrid[7][24];
}

@synthesize readOnly;

-(void)_init {
    if ( initialized )
        return;
    
    initialized = YES;
}

-(id)init {
    
    self = [super init];
    
    if ( self != nil ) {
        [self _init];
        
        _firstDay = 1;
        _program0Label = @"P0";
        _program1Label = @"P1";
        _textSize = 14.0;
        _textColor = nil;
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self _init];
    }
    
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if ( self != nil ) {
        [self _init];
    }
    
    return self;
}

-(void)setTextSize:(CGFloat)textSize {
    _textSize = textSize;
    [self setNeedsDisplay];
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self setNeedsDisplay];
}

-(UIColor *)textColor {
    return _textColor == nil ? [UIColor blackColor] : _textColor;
}

-(void)setProgram0Color:(UIColor *)program0Color {
    _program0Color = program0Color;
    [self setNeedsDisplay];
}

-(UIColor*)program0Color {
    return _program0Color == nil ?
    [UIColor colorWithRed:0.69 green:0.88 blue:0.66 alpha:1.0] : _program0Color;
}

-(void)setProgram1Color:(UIColor *)program1Color {
    _program1Color = program1Color;
    [self setNeedsDisplay];
}

-(UIColor*)program1Color {
    return _program1Color == nil ?
    [UIColor colorWithRed:1.00 green:0.82 blue:0.60 alpha:1.0] : _program1Color;
}

-(void)setProgram1Label:(NSString *)program1Label {
    _program1Label = program1Label;
    [self setNeedsDisplay];
}

-(NSString*)program1Label {
    return _program1Label;
}

-(void)setProgram0Label:(NSString *)program0Label {
    _program0Label = program0Label;
    [self setNeedsDisplay];
}

-(NSString*)program0Label {
    return _program0Label;
}

-(void)setFirstDay:(short)firstDay {
    if (firstDay >= 1 && firstDay <= 7)
    _firstDay = firstDay;
    [self setNeedsDisplay];
}

-(short)firstDay {
    return _firstDay;
}

-(BOOL)correctDay:(short)day andHour:(short)hour {
    return !(day < 1 || day > 7 || hour < 0 || hour > 23);
}

-(void)setProgramForDay:(short)day andHour:(short)hour toOne:(BOOL)one {
    if ([self correctDay:day andHour:hour]) {
        _HourProgramGrid[day][hour] = one;
    }
}

-(BOOL)programIsSetToOneWithDay:(short)day andHour:(short)hour {
    return [self correctDay:day andHour:hour] && _HourProgramGrid[day][hour];
}

-(void)clear {
    for(int d=0;d<7;d++) {
        for(int h=0;h<24;h++) {
            _HourProgramGrid[d][h] = NO;
        }
    }
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}



@end
