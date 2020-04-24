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

#import "SARangeCalibrationWheel.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@implementation SARangeCalibrationWheel {
    UIColor *_wheelColor;
    UIColor *_borderColor;
    UIColor *_btnColor;
    UIColor *_valueColor;
    UIColor *_insideBtnColor;
    CGFloat _borderLineWidth;
    BOOL initialized;
    CGFloat wheelRadius;
    CGFloat wheelWidth;
    CGFloat halfBtnSize;
}

-(void)wheelInit {
    if ( initialized ) {
     return;
    }
   
    _borderLineWidth = 1.5;
    initialized = YES;
}

-(id)init {
    self = [super init];
    
    if ( self != nil ) {
        [self wheelInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self wheelInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if ( self != nil ) {
        [self wheelInit];
    }

    return self;
}

- (void)setWheelColor:(UIColor *)wheelColor {
    _wheelColor = wheelColor == nil ? nil : [wheelColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)wheelColor {
    if (_wheelColor == nil) {
        _wheelColor = [UIColor colorWithRed: 0.78 green: 0.84 blue: 0.94 alpha: 1.00];
    }
    return _wheelColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor == nil ? nil : [borderColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)borderColor {
    if (_borderColor == nil) {
        _borderColor = [UIColor colorWithRed: 0.27 green: 0.52 blue: 0.91 alpha: 1.00];
    }
    return _borderColor;
}

- (void)setBtnColor:(UIColor *)btnColor {
    _btnColor = btnColor == nil ? nil : [btnColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)btnColor {
    if (_btnColor == nil) {
        _btnColor = [UIColor colorWithRed: 0.27 green: 0.52 blue: 0.91 alpha: 1.00];
    }
    return _btnColor;
}

- (void)setValueColor:(UIColor *)valueColor {
    _valueColor = valueColor == nil ? nil : [valueColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)valueColor {
    if (_valueColor == nil) {
        _valueColor = [UIColor colorWithRed: 1.00 green: 0.90 blue: 0.09 alpha: 1.00];
    }
    return _valueColor;
}

- (void)setInsideBtnColor:(UIColor *)insideBtnColor {
    _insideBtnColor = insideBtnColor == nil ? nil : [insideBtnColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)insideBtnColor {
    if (_insideBtnColor == nil) {
        _insideBtnColor = [UIColor whiteColor];
    }
    return _insideBtnColor;
}

-(CGPoint)drawButtonWithCtx:(CGContextRef)cfx radius:(CGFloat)rad hidden:(BOOL)hidden {
    CGFloat btnSize = wheelWidth+self.borderLineWidth*4;
    halfBtnSize = btnSize / 2;
    CGFloat x = wheelRadius - self.borderLineWidth;
    CGPoint result = CGPointMake(cosf(rad)*wheelRadius, sinf(rad)*wheelRadius);
    
    if (hidden) {
        return result;
    }
    
    CGRect rect = CGRectMake(x-halfBtnSize, halfBtnSize * -1, halfBtnSize*2, halfBtnSize*2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3];
    [path closePath];
    
    [path applyTransform:CGAffineTransformMakeRotation(rad)];
    
    [self.btnColor setFill];
    [path fill];
    [path stroke];
    
    return result;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
   
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    CGContextTranslateCTM(ctx, rect.size.width / 2, rect.size.height / 2);
    
    wheelRadius = (rect.size.width > rect.size.height
                  ? rect.size.height : rect.size.width) / 2;
    
    wheelRadius *= 0.8;
    wheelWidth = wheelRadius * 0.25;
    
    CGRect r;
    
    r.origin.x = wheelRadius * -1;
    r.origin.y = wheelRadius * -1;
    r.size.height = wheelRadius * 2;
    r.size.width = wheelRadius * 2;
   
    CGContextSetLineWidth(ctx, wheelWidth);
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextAddEllipseInRect(ctx, r);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, wheelWidth-self.borderLineWidth*2);
    CGContextSetStrokeColorWithColor(ctx, self.wheelColor.CGColor);
    CGContextAddEllipseInRect(ctx, r);
    CGContextStrokePath(ctx);
    
    [self drawButtonWithCtx:ctx radius:DEGREES_TO_RADIANS(90) hidden:NO];
}

@end
