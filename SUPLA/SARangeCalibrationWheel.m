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
#define TOUCHED_NONE 0
#define TOUCHED_LEFT 1
#define TOUCHED_RIGHT 2

@implementation SARangeCalibrationWheel {
    UIColor *_wheelColor;
    UIColor *_borderColor;
    UIColor *_btnColor;
    UIColor *_valueColor;
    UIColor *_insideBtnColor;
    CGFloat _borderLineWidth;
    double _maxRange;
    double _minRange;
    double _numerOfTurns;
    double _minimum;
    double _maximum;
    double _leftEdge;
    double _rightEdge;
    double _boostLevel;
    BOOL _boostHidden;
    BOOL initialized;
    Byte touched;
    CGFloat wheelRadius;
    CGFloat wheelWidth;
    CGFloat halfBtnSize;
    CGFloat btnRad;
    CGPoint btnRightCenter;
    CGPoint btnLeftCenter;
}

-(void)wheelInit {
    if ( initialized ) {
     return;
    }
   
    _maxRange = 1000;
    _minRange = _maxRange * 0.1;
    _numerOfTurns = 5;
    _minimum = 0;
    _maximum = _maxRange;
    _leftEdge = 0;
    _rightEdge = _maxRange;
    _boostLevel = 0;
    _boostHidden = YES;
    
    touched = TOUCHED_NONE;
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

-(double) maxRange {
    return _maxRange;
}

-(void) setMaxRange:(double)maxRange {
    if (_leftEdge > maxRange) {
        maxRange = _leftEdge;
    }

    if (_rightEdge > maxRange) {
        maxRange = _rightEdge;
    }
    _maxRange = maxRange;
    [self setNeedsDisplay];
}

-(double) minRange {
    return _maxRange;
}

-(void) setMinRange:(double)minRange {
    if (minRange < 0) {
        minRange = 0;
    }
    if (minRange > self.maxRange) {
        minRange = self.maxRange;
    }
    
    _minRange = minRange;
    [self setNeedsDisplay];
}

-(double)numerOfTurns {
    return _numerOfTurns;
}

-(void) setNumerOfTurns:(double)numerOfTurns {
    _numerOfTurns = numerOfTurns;
}

-(double)minimum {
    return _minimum;
}

-(void)setMinimum:(double)minimum needsDisplay:(BOOL)needsDisplay {
    if (minimum+self.minRange > self.maximum) {
        minimum = self.maximum - self.minRange;
    }

    if (minimum < self.leftEdge) {
        minimum = self.leftEdge;
    }

    if (minimum > self.boostLevel) {
        _boostLevel = minimum;
    }

    _minimum = minimum;
    if (needsDisplay) {
        [self setNeedsDisplay];
    }
}

-(void)setMinimum:(double)minimum {
    [self setMinimum:minimum needsDisplay:YES];
}

-(double)maximum {
    return _maximum;
}

-(void)setMaximum:(double)maximum needsDisplay:(BOOL)needsDisplay {
    if (self.minimum+self.minRange > maximum) {
        maximum = self.minimum+self.minRange;
    }

    if (maximum > self.rightEdge) {
        maximum = self.rightEdge;
    }

    if (maximum < self.boostLevel) {
        _boostLevel = maximum;
    }

    _maximum = maximum;
    if (needsDisplay) {
        [self setNeedsDisplay];
    }
}

-(void)setMaximum:(double)maximum {
    [self setMinimum:maximum needsDisplay:YES];
}

-(double)leftEdge {
    return _leftEdge;
}

-(void)setLeftEdge:(double)leftEdge {
    if (leftEdge < 0) {
        leftEdge = 0;
    }

    if (leftEdge > self.rightEdge) {
        leftEdge = self.rightEdge;
    }

    if (leftEdge > self.maxRange) {
        leftEdge = self.maxRange;
    }

    _leftEdge = leftEdge;
    self.minimum = self.minimum;
    self.maximum = self.maximum;
}

-(double)rightEdge {
    return _rightEdge;
}

-(void)setRightEdge:(double)rightEdge {
    if (rightEdge < 0) {
        rightEdge = 0;
    }

    if (self.leftEdge > rightEdge) {
        rightEdge = self.leftEdge;
    }

    if (self.rightEdge > self.maxRange) {
        rightEdge = self.maxRange;
    }

    _rightEdge = rightEdge;
    self.minimum = self.minimum;
    self.maximum = self.maximum;
}

-(double)boostLevel {
    return _boostLevel;
}

-(void)setBoostLevel:(double)boostLevel {
    if (boostLevel < self.minimum) {
        boostLevel = self.minimum;
    }

    if (boostLevel > self.maximum) {
        boostLevel = self.maximum;
    }

    _boostLevel = boostLevel;
    if (!self.boostHidden) {
        [self setNeedsDisplay];
    }
}

-(void)setBoostHidden:(BOOL)boostHidden {
    _boostHidden = boostHidden;
    [self setNeedsDisplay];
}

-(BOOL)boostHidden {
    return _boostHidden;
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

    [path applyTransform:CGAffineTransformMakeRotation(rad)];
    
    [self.btnColor setFill];
    [self.btnColor setStroke];
    
    [path fill];
    
    CGFloat hMargin = rect.size.height * 0.35;
    CGFloat wMargin = rect.size.width * 0.2;
    
    rect.origin.x += wMargin;
    rect.origin.y += hMargin;
    rect.size.height -= hMargin * 2;
    rect.size.width -= wMargin * 2;
    
    const Byte lc = 3;
    CGFloat step = rect.size.height / (lc-1);
    CGFloat lineWidth = self.borderLineWidth;
    
    [self.insideBtnColor setFill];
    
    for(float a=0;a<3;a++) {
        CGRect lineRect = CGRectMake(rect.origin.x,
                                     rect.origin.y+step*a-lineWidth/2.0,
                                     rect.size.width,
                                     lineWidth);
        
         path = [UIBezierPath bezierPathWithRoundedRect:lineRect cornerRadius:3];
         [path applyTransform:CGAffineTransformMakeRotation(rad)];
         [path fill];
    }
    
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
    
    if (touched == TOUCHED_NONE) {
        btnRightCenter = [self drawButtonWithCtx:ctx radius:DEGREES_TO_RADIANS(0) hidden:NO];
        btnLeftCenter = [self drawButtonWithCtx:ctx radius:DEGREES_TO_RADIANS(180) hidden:!_boostHidden];
    } else {
        if (touched == TOUCHED_RIGHT) {
             [self drawButtonWithCtx:ctx radius:btnRad hidden:NO];
        } else if (touched == TOUCHED_LEFT) {
             [self drawButtonWithCtx:ctx radius:btnRad hidden:!_boostHidden];
        }
    }
   
    CGFloat distanceToEdge = halfBtnSize + self.borderLineWidth * 2;
    CGRect valueFrame = CGRectMake(btnLeftCenter.x+distanceToEdge,
                                   btnLeftCenter.y-halfBtnSize,
                                   btnRightCenter.x -btnLeftCenter.x - distanceToEdge * 2,
                                   halfBtnSize * 2);
    
    CGFloat vleft = valueFrame.origin.x + (valueFrame.size.width * self.minimum *100.00/self.maxRange/100.00);
    CGFloat vwidth = valueFrame.size.width * self.maximum *100.00/self.maxRange/100.00;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:valueFrame cornerRadius:3];
    [path stroke];
}

@end
