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
#define TC_SPACING 2.5

typedef struct {
    short day;
    short hour;
}TCDayHour;

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
    CGSize _boxSize;
    NSArray *_dayNames;
    UIPanGestureRecognizer *_pgr;
    BOOL _setProgramToOne;
    TCDayHour _lastDH;
    BOOL _touched;
}

@synthesize delegate;

-(void)_init {
    if ( initialized )
        return;
    
    initialized = YES;
    _firstDay = 1;
    _program0Label = @"P0";
    _program1Label = @"P1";
    _textSize = 12.0;
    _textColor = nil;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    _dayNames = [formatter shortWeekdaySymbols];
    
    self.readOnly = false;
}

-(id)init {
    
    self = [super init];
    
    if ( self != nil ) {
        [self _init];
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
        _HourProgramGrid[day-1][hour] = one;
    }
}

-(BOOL)programIsSetToOneWithDay:(short)day andHour:(short)hour {
    return [self correctDay:day andHour:hour] && _HourProgramGrid[day-1][hour];
}

-(void)clear {
    for(int d=0;d<7;d++) {
        for(int h=0;h<24;h++) {
            _HourProgramGrid[d][h] = NO;
        }
    }
    [self setNeedsDisplay];
}

-(CGRect)rectangleForDay:(short)day andHour:(short)hour {
    CGFloat leftOffset = day * (_boxSize.width + TC_SPACING);
    CGFloat topOffset = (hour+1) * (_boxSize.height + TC_SPACING);

    return CGRectMake(leftOffset, topOffset, _boxSize.width, _boxSize.height);
}

-(short)addOffsetToDay:(short)day {
    day += _firstDay-1;
    if (day > 7) {
        day-=7;
    }

    return day;
}

-(void)drawText:(NSString *)txt inRect:(CGRect)rect context:(CGContextRef)ctx {
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:self.textSize];
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    [pStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attr = @{NSFontAttributeName:font,
                         NSParagraphStyleAttributeName:pStyle};
        
    CGFloat height = [txt sizeWithAttributes:attr].height;
    rect.origin.y += (rect.size.height - height) / 2;
    rect.size.height = height;

    [txt drawInRect:rect withAttributes:attr];
}

-(short)drawLabel:(NSString *)txt withOffset:(short)offset context:(CGContextRef)ctx {
    if (txt!=nil) {
        CGRect r1 = [self rectangleForDay:offset+1 andHour:24];
        CGRect r2 = [self rectangleForDay:offset+3 andHour:24];
        
        r1.size.width = r2.origin.x+r2.size.width - r1.origin.x;
    
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r1 cornerRadius:6];
        [path fill];
        
        [self.textColor setFill];
        [self drawText:txt inRect:r1 context:ctx];
        offset+=3;
    }
    return offset;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    _boxSize.height = (self.frame.size.height - TC_SPACING * 25.0) / 26.0;
    _boxSize.width = (self.frame.size.width - TC_SPACING * 7.0) / 8.0;
    
    short dayIdx;
    UIBezierPath *path;
   
    for(short d = 0; d <= 7; d++) {
        for(short h = -1; h < 24; h++) {
            rect = [self rectangleForDay:d andHour:h];
            dayIdx = [self addOffsetToDay:d]-1;
            
            if (h == -1 || d == 0) {
                NSString *label = @"";

                if (h == -1 && d > 0) {
                    label = [_dayNames objectAtIndex:dayIdx];
                } else if ( h > -1 )  {
                    label = [NSString stringWithFormat:@"%02d", h];
                }
                
                [self.textColor setFill];
                [self drawText:label inRect:rect context:context];
            } else {
                path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:6];
                [(_HourProgramGrid[dayIdx][h] ? self.program1Color : self.program0Color) setFill];
                [path fill];
            }
        }
    }
    
    [self.program0Color setFill];
    short offset = [self drawLabel:self.program0Label withOffset:0 context:context];
    [self.program1Color setFill];
    [self drawLabel:self.program1Label withOffset:offset context:context];
}

-(BOOL)readOnly {
    return _pgr == nil;
}

-(void)setReadOnly:(BOOL)readOnly {
    
    if ( readOnly ) {
        if ( _pgr != nil ) {
            [self removeGestureRecognizer:_pgr];
            _pgr = nil;
        }
    } else {
        if ( _pgr == nil ) {
            _pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [_pgr setMinimumNumberOfTouches:1];
            [_pgr setMaximumNumberOfTouches:1];
            [self addGestureRecognizer:_pgr];
        }
    }
}

-(TCDayHour)dayHourAndPoint:(CGPoint)point {
    TCDayHour result;
    result.day = 0;
    result.hour = 0;
    
    for(short d = 1; d <= 7; d++) {
        for (short h = 0; h < 24; h++) {
            CGRect rect = [self rectangleForDay:d andHour:h];
           
            if (point.x >= rect.origin.x
                    && point.y >= rect.origin.y
                    && point.x <= rect.origin.x + rect.size.width
                    && point.y <= rect.origin.y + rect.size.height) {

                result.day = d;
                result.hour = h;
                break;
            }
        }
    }
    
    return result;
}

- (BOOL)onTouched:(TCDayHour)dh first:(BOOL)first {
    if (dh.day > 0
        && (first
            || _lastDH.day != dh.day
            || _lastDH.hour != dh.hour)) {
        _lastDH = dh;
        short dayIdx = [self addOffsetToDay:dh.day]-1;
        
        if (first) {
            _setProgramToOne = !_HourProgramGrid[dayIdx][dh.hour];
        }
        
        _HourProgramGrid[dayIdx][dh.hour] = _setProgramToOne;
        
        if (self.delegate != nil) {
            [self.delegate thermostatCalendarPragramChanged:self day:dh.day hour:dh.hour program1:_setProgramToOne];
        }
        
        [self setNeedsDisplay];
        return YES;
    }
    return NO;
}

- (void)handlePan:(UIGestureRecognizer *)gr {
    switch(gr.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            _touched = YES;
            CGPoint point = [gr locationInView:self];
             TCDayHour dh = [self dayHourAndPoint:point];
             [self onTouched:dh first:NO];
            break;
        default:
            _touched = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.allObjects.count > 0) {
        UITouch *touch = [touches.allObjects objectAtIndex:0];
        if ([touch isKindOfClass:[UITouch class]]) {
            CGPoint point = [touch locationInView:self];
            TCDayHour dh = [self dayHourAndPoint:point];
            [self onTouched:dh first:YES];
            _touched = YES;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _touched = NO;
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    
    return v != self
    || self.readOnly
    || point.y < _boxSize.height
    || point.x < _boxSize.width
    || point.y > self.frame.size.height - _boxSize.height ? nil : self;
}

-(BOOL)isTouched {
    return _touched;
}

@end
