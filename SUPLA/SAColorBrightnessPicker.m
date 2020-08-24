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
#import "SAColorBrightnessPicker.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

#define ACTIVE_TOUCHPOINT_NONE 0
#define ACTIVE_TOUCHPOINT_COLOR_POINTER 1
#define ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER 2
#define ACTIVE_TOUCHPOINT_POWER_BUTTON 3

@implementation SAColorBrightnessPicker {
    
    BOOL initialized;
    
    NSArray *_colorMarkers;
    NSArray *_brightnessMarkers;
    BOOL _moving;
    BOOL _colorWheelHidden;
    BOOL _circleInsteadArrow;
    BOOL _colorfulBrightnessWheel;
    BOOL _sliderHidden;
    
    CGPoint _arrowTop;
    CGPoint _inversedArrowTop;
    CGRect _sliderRect;
    
    float _arrowHeight;
    
    UIColor *_color;
    float _brightness;
    float _minBrightness;
    float _colorAngle;
    
    float lastPanPosition;
    char activeTouchPoint;
    
    float _brightnessWheelRadius;
    float _colorWheelRadius;
    float _wheelWidth;
    
    CGPoint _colorPointerCentralPoint;
    CGPoint _brightnessPointerCentralPoint;
    float _pointerRadius;
    float _sliderPointerRange;
    
    float _powerBtnRadius;
    BOOL _powerButtonHidden;
    BOOL _powerButtonEnabled;
    BOOL _powerButtonOn;
    BOOL _jumpToThePointOfTouchEnabled;
    
    UIColor *_powerButtonColorOn;
    UIColor *_powerButtonColorOff;
    UIPanGestureRecognizer *_panGr;
    UITapGestureRecognizer *_tapGr;
}

@synthesize delegate;

-(BOOL)moving {
    return _moving;
}

-(void)pickerInit {
    
    if ( initialized )
        return;
    
    _sliderHidden = YES;
    _colorfulBrightnessWheel = YES;
    _circleInsteadArrow = YES;
    _colorfulBrightnessWheel = YES;
    _powerButtonEnabled = YES;
    _jumpToThePointOfTouchEnabled = YES;
    // #f7f0dc
    _powerButtonColorOn = [UIColor whiteColor];
    // #404040
    _powerButtonColorOff = [UIColor colorWithRed: 0.25 green: 0.25 blue: 0.25 alpha: 1.00];
    _brightness = 0;
    // #00FF00
    _color = [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
    
    _panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [_panGr setMinimumNumberOfTouches:1];
    [_panGr setMaximumNumberOfTouches:1];
    
    [self addGestureRecognizer:_panGr];
    [self addGestureRecognizer:_tapGr];
    
    initialized = YES;
}

-(id)init {
    
    self = [super init];
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    
    if ( self != nil ) {
        [self pickerInit];
    }
    
    
    return self;
}

-(void)setArrowHeight:(float)arrowHeight {
    _arrowHeight = arrowHeight;
    [self setNeedsDisplay];
}

-(void)setColorWheelHidden:(BOOL)colorWheelHidden {
    _colorWheelHidden = colorWheelHidden;
    [self setNeedsDisplay];
}

-(BOOL)colorWheelHidden {
    return _colorWheelHidden;
}

-(void)setCircleInsteadArrow:(BOOL)circleInsteadArrow {
    _circleInsteadArrow = circleInsteadArrow;
    [self setNeedsDisplay];
}

-(BOOL)circleInsteadArrow {
    return _circleInsteadArrow;
}

-(void)setColorfulBrightnessWheel:(BOOL)colorfulBrightnessWheel {
    _colorfulBrightnessWheel = colorfulBrightnessWheel;
    [self setNeedsDisplay];
}

-(BOOL)colorfulBrightnessWheel {
    return _colorfulBrightnessWheel;
}

-(void)setSliderHidden:(BOOL)sliderHidden {
    _sliderHidden = sliderHidden;
    [self setNeedsDisplay];
}

-(BOOL)sliderHidden {
    return _sliderHidden;
}

-(UIColor*)color {
    return _color;
}

-(float)colorToAngle:(UIColor *)color {
    
    CGFloat hue;
    CGFloat saturation;
    
    [color getHue:&hue saturation:&saturation brightness:nil alpha:nil];
    
    float angle = 360*hue;
    angle = 360 - angle;
    
    return [self addAngle:90 toAngle:angle];
}

-(void)setColor:(UIColor *)color raiseEvent:(BOOL)raiseEvent calcAngle:(BOOL)calcAngle {
    if (color != nil && [color isEqual:_color] == NO ) {
        _color = [color copy];
        
        if (calcAngle) {
          _colorAngle = [self colorToAngle:color];
        }
        
        if ( !self.colorWheelHidden ) {
            [self setNeedsDisplay];
        }
        
        if ( raiseEvent
            && delegate != nil
            && [delegate respondsToSelector:@selector(cbPickerDataChanged:)] ) {
          [delegate cbPickerDataChanged: self];
        }
    }
}

-(void)setColor:(UIColor *)color {
    [self setColor:color raiseEvent:NO calcAngle:YES];
}

-(NSArray*)colorMarkers {
    return _colorMarkers;
}

-(void)setColorMarkers:(NSArray *)colorMarkers {
    _colorMarkers = colorMarkers;
    [self setNeedsDisplay];
}

-(NSArray*)brightnessMarkers {
    return _brightnessMarkers;
}

-(void)setBrightnessMarkers:(NSArray *)brightnessMarkers {
    _brightnessMarkers = brightnessMarkers;
    [self setNeedsDisplay];
}

-(void)setPowerButtonHidden:(BOOL)powerButtonHidden {
    _powerButtonHidden = powerButtonHidden;
    [self setNeedsDisplay];
}

-(BOOL)powerButtonHidden {
    return _powerButtonHidden;
}

-(void)setPowerButtonEnabled:(BOOL)powerButtonEnabled {
    _powerButtonEnabled = powerButtonEnabled;
}

-(BOOL)powerButtonEnabled {
    return _powerButtonEnabled;
}

-(void)setPowerButtonOn:(BOOL)powerButtonOn {
    _powerButtonOn = powerButtonOn;
    [self setNeedsDisplay];
}

-(BOOL)powerButtonOn {
    return _powerButtonOn;
}

-(UIColor*)powerButtonColorOn {
    return _powerButtonColorOn;
}

-(void)setPowerButtonColorOn:(UIColor *)powerButtonColorOn {
    if (powerButtonColorOn != nil) {
        _powerButtonColorOn = [powerButtonColorOn copy];
    }
}

-(UIColor*)powerButtonColorOff {
    return _powerButtonColorOff;
}

-(void)setPowerButtonColorOff:(UIColor *)powerButtonColorOff {
    if (powerButtonColorOff != nil) {
        _powerButtonColorOff = [powerButtonColorOff copy];
    }
}

-(void)setJumpToThePointOfTouchEnabled:(BOOL)jumpToThePointOfTouchEnabled {
    _jumpToThePointOfTouchEnabled = jumpToThePointOfTouchEnabled;
}

-(BOOL)jumpToThePointOfTouchEnabled {
    return _jumpToThePointOfTouchEnabled;
}

-(float)addAngle:(float)angle toAngle:(float)source {
    
    angle = source + angle;
    
    if ( angle > 360 )
        angle = fmod(angle, 360);
    
    if ( angle<0 ) {
        
        angle*=-1;
        
        if ( angle > 360 )
            angle = fmod(angle, 360);
        
        angle = 360 - angle;
    }
    
    return angle;
}


-(UIColor*)calculateColorForAngle:(float)angle baseColor:(UIColor *)base_color {
    
    if ( base_color == nil ) {
        
        angle = 360 - angle;
        return [UIColor colorWithHue:angle/360.00 saturation:1 brightness:1 alpha:1];
        
    } else {
        
        if ( angle > 0 ) {
            
            angle += 60;
            
            if ( angle > 360 )
                angle = 360;
            
        }
        
        CGFloat hue;
        CGFloat saturation;
        
        [base_color getHue:&hue saturation:&saturation brightness:nil alpha:nil];
        
        return [UIColor colorWithHue:hue saturation:saturation brightness:angle/360 alpha:1];
    }
}

- (void)drawMarkerInRect:(CGRect)rect ctx:(CGContextRef)ctx {
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
    
    CGContextSetLineWidth(ctx, rect.size.height/8);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextStrokePath(ctx);
}

- (void)drawWheelMarkers:(NSArray*)markers withRadius:(int)radius markerSize:(float)markerSize brightness:(BOOL)brightness ctx:(CGContextRef)ctx {
    
    if (markers==nil) {
        return;
    }
    
    CGRect rect;
    rect.size.height = markerSize;
    rect.size.width = rect.size.height;
    
    float angle;
    id obj;
    
    for(int a=0;a<markers.count;a++) {
        angle = 0;
        obj = [markers objectAtIndex:a];
        
        if (brightness) {
            
            if (![obj isKindOfClass:[NSNumber class]]) {
                continue;
            }
            
            float b = [obj floatValue];
            
            if (b < 0.5) {
                b = 0.5;
            } else if (b > 99.5) {
                b = 99.5;
            }
            
            angle = b*3.6;
            
        } else {
            if (![obj isKindOfClass:[UIColor class]]) {
                continue;
            }
            
            angle = [self colorToAngle:obj];
        }
        
        angle = DEGREES_TO_RADIANS([self addAngle:270 toAngle:angle]);
        
        rect.origin.x = cosf(angle) * radius - markerSize/2;
        rect.origin.y = sinf(angle) * radius - markerSize/2;
        
        [self drawMarkerInRect:rect ctx:ctx];
    }
}

- (void)drawSliderMarkersInRect:(CGRect)rect markerSize:(CGFloat)size ctx:(CGContextRef)ctx {
    if (self.brightnessMarkers == nil) {
        return;
    }
    
    id obj;
    CGRect markerRect;
    markerRect.origin.x = rect.origin.x + rect.size.width/2 - size / 2;
    markerRect.size.height = size;
    markerRect.size.width = size;
    
    for(int a=0;a<self.brightnessMarkers.count;a++) {
        obj = [self.brightnessMarkers objectAtIndex:a];
        if (![obj isKindOfClass:[NSNumber class]]) {
            continue;
        }
        
        markerRect.origin.y = rect.origin.y + rect.size.width/2 - size /2
        + (rect.size.height - rect.size.width) * [obj floatValue] / 100.0;
        
        [self drawMarkerInRect:markerRect ctx:ctx];
    }
}

-(void)drawWheelWithRadius:(int)wheel_radius wheelWidth:(int)wheel_width baseColor:(UIColor *)base_color {
    
    int steps = 255;
    float angle_step = 360.00/steps;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 1;
    
    
    for(int a=0;a<steps;a++) {
        
        [aPath removeAllPoints];
        
        float angle1 = a*angle_step;
        float angle2 = (a+1)*angle_step;
        
        UIColor *color = [self calculateColorForAngle:angle1 baseColor:base_color];
        
        if ( base_color != nil ) {
            
            angle1 = [self addAngle:270 toAngle:angle1];
            angle2 = [self addAngle:270 toAngle:angle2];
            
        }
        
        [color setFill];
        [color setStroke];
        
        float x = cosf(DEGREES_TO_RADIANS(angle1))*wheel_radius;
        float y = sinf(DEGREES_TO_RADIANS(angle1))*wheel_radius;
        
        [aPath moveToPoint:CGPointMake(x, y)];
        
        x = cosf(DEGREES_TO_RADIANS(angle1))*(wheel_radius+wheel_width);
        y = sinf(DEGREES_TO_RADIANS(angle1))*(wheel_radius+wheel_width);
        
        [aPath addLineToPoint:CGPointMake(x, y)];
        
        
        x = cosf(DEGREES_TO_RADIANS(angle2))*wheel_radius;
        y = sinf(DEGREES_TO_RADIANS(angle2))*wheel_radius;
        
        [aPath moveToPoint:CGPointMake(x, y)];
        
        x = cosf(DEGREES_TO_RADIANS(angle2))*(wheel_radius+wheel_width);
        y = sinf(DEGREES_TO_RADIANS(angle2))*(wheel_radius+wheel_width);
        
        [aPath addLineToPoint:CGPointMake(x, y)];
        
        
        [aPath addArcWithCenter:CGPointMake(0, 0) radius:wheel_radius+wheel_width startAngle:DEGREES_TO_RADIANS(angle2) endAngle:DEGREES_TO_RADIANS(angle1) clockwise:NO];
        [aPath addArcWithCenter:CGPointMake(0, 0) radius:wheel_radius startAngle:DEGREES_TO_RADIANS(angle1) endAngle:DEGREES_TO_RADIANS(angle2) clockwise:YES];
        
        [aPath closePath];
        [aPath fill];
        [aPath stroke];
        
    }
    
}

-(CGPoint)drawCirclePointerInRect:(CGRect)rect color:(UIColor *)color borderColor:(UIColor*)borderColor ctx:(CGContextRef)ctx {
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    CGFloat lw = rect.size.width * 0.05;
    CGContextSetLineWidth(ctx, lw);
    rect.origin.x += lw;
    rect.origin.y += lw;
    rect.size.height -= lw*2;
    rect.size.width -= lw*2;
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextStrokePath(ctx);
    
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

-(CGPoint)drawCirclePointerWithAngle:(float)angle positionRadius:(int)positionRadius circleRadius:(int)circleRadius color:(UIColor *)color borderColor:(UIColor*)borderColor ctx:(CGContextRef)ctx {
    
    angle = DEGREES_TO_RADIANS(angle);
    
    CGRect rect;
    rect.origin.x = cosf(angle) * positionRadius - circleRadius;
    rect.origin.y = sinf(angle) * positionRadius - circleRadius;
    rect.size.height = circleRadius * 2;
    rect.size.width = rect.size.height;
    
    return [self drawCirclePointerInRect:rect color:color borderColor:borderColor ctx:ctx];
}

-(CGPoint)drawArrowWithAngle:(float)angle wheelRadius:(float)wheel_radius wheelWidth:(int)wheel_width inverse:(BOOL)inverse color:(UIColor *)color borderColor:(UIColor*)borderColor {
    
    [borderColor setStroke];
    [color setFill];
    
    angle = DEGREES_TO_RADIANS(angle);
    
    float arrowHeight_a = _arrowHeight;
    float arrowHeight_b = arrowHeight_a * 0.6;
    arrowHeight_a -= arrowHeight_b;
    
    float offset = (arrowHeight_a * 0.30);
    int inv = 1;
    
    if ( inverse ) {
        
        wheel_width = 0;
        inv = -1;
        
    } else {
        offset *= -1;
    }
    
    
    float topX = cosf(angle) * (wheel_radius+wheel_width+offset);
    float topY = sinf(angle) * (wheel_radius+wheel_width+offset);
    
    if ( inverse ) {
        _inversedArrowTop.x = topX;
        _inversedArrowTop.y = topY;
    } else {
        _arrowTop.x = topX;
        _arrowTop.y = topY;
    }
    
    float arrowRad = DEGREES_TO_RADIANS(40);
    
    float leftX = topX + cosf(angle+arrowRad)*arrowHeight_a*inv;
    float leftY = topY + sinf(angle+arrowRad)*arrowHeight_a*inv;
    
    float rightX = topX + cosf(angle-arrowRad)*arrowHeight_a*inv;
    float rightY = topY + sinf(angle-arrowRad)*arrowHeight_a*inv;
    
    float backRad = angle;
    
    float backLeftX = leftX + cosf(backRad)*arrowHeight_b*inv;
    float backLeftY = leftY + sinf(backRad)*arrowHeight_b*inv;
    
    float backRightX = rightX + cosf(backRad)*arrowHeight_b*inv;
    float backRightY = rightY + sinf(backRad)*arrowHeight_b*inv;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 0.5;
    
    [aPath moveToPoint:CGPointMake(topX, topY)];
    [aPath addLineToPoint:CGPointMake(leftX, leftY)];
    [aPath addLineToPoint:CGPointMake(backLeftX, backLeftY)];
    [aPath addLineToPoint:CGPointMake(backRightX, backRightY)];
    [aPath addLineToPoint:CGPointMake(rightX, rightY)];
    
    [aPath closePath];
    [aPath stroke];
    [aPath fill];
    
    return CGPointMake(cosf(angle) * (wheel_radius+wheel_width+offset+_arrowHeight/2* (inverse ? -1 : 1)),
                       sinf(angle) * (wheel_radius+wheel_width+offset+_arrowHeight/2* (inverse ? -1 : 1)));
}

-(CGPoint)drawPointerWithAngle:(float)angle wheelRadius:(float)wheel_radius wheelWidth:(int)wheel_width inverse:(BOOL)inverse color:(UIColor *)color borderColor:(UIColor*)borderColor ctx:(CGContextRef)ctx {
    
    angle = [self addAngle:270 toAngle:angle];
    
    if (_circleInsteadArrow) {
        return [self drawCirclePointerWithAngle:angle positionRadius:wheel_radius+wheel_width/2 circleRadius:wheel_width/2 color:color borderColor:borderColor ctx:ctx];
    }
    
    return [self drawArrowWithAngle:angle wheelRadius:wheel_radius wheelWidth:wheel_width inverse:inverse color:color borderColor:borderColor];
}

-(void)trimBrightnessColorAngle:(float*)angle {
    if (*angle < 4) {
        *angle = 4;
    } else if (*angle > 250) {
        *angle = 250;
    }
}

-(CGFloat)drawPowerButtonWithCtx:(CGContextRef)ctx wheelRadius:(float)wheelRadius {
    CGFloat radius = wheelRadius * 0.3;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0)
                                                        radius:radius
                                                    startAngle:DEGREES_TO_RADIANS(-60)
                                                      endAngle:DEGREES_TO_RADIANS(240)
                                                     clockwise:YES];
    
    
    _powerButtonOn ? [_powerButtonColorOn setStroke] : [_powerButtonColorOff setStroke];
    [path setLineWidth:radius * 0.2];
    [path setLineCapStyle:kCGLineCapRound];
    [path moveToPoint:CGPointMake(0, radius * -1 - radius * 0.15)];
    [path addLineToPoint:CGPointMake(0, radius * -1 + radius * 0.6)];
    [path stroke];
    
    return radius;
}

-(void)drawWheelWithCtx:(CGContextRef)ctx {
    float radius = self.bounds.size.width > self.bounds.size.height
    ? self.bounds.size.height : self.bounds.size.width;
    
    if (_circleInsteadArrow) {
        _wheelWidth = radius / (_colorWheelHidden ? 7.0: 3.50);
        [self setArrowHeight: 0.00];
    } else {
        _wheelWidth = radius / 10.00;
        [self setArrowHeight:_wheelWidth * 0.9];
    }
    
    radius /= 2;
    radius -= _wheelWidth;
    radius -= _arrowHeight;
    
    float brightness_angle = _brightness*3.6;
    float brightness_color_angle = brightness_angle;
    
    CGFloat red,green,blue,alpha;
    [_color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (_circleInsteadArrow
        && (!_colorfulBrightnessWheel
            || _colorWheelHidden
            || (!_colorWheelHidden
                && red == 1 && green == 1 && blue == 1))) {
        [self trimBrightnessColorAngle:&brightness_color_angle];
    }
    
    UIColor *brightness_pointer_color = [self calculateColorForAngle:brightness_color_angle baseColor:!_colorWheelHidden
                                         && _colorfulBrightnessWheel ? _color: [UIColor blackColor]];
    UIColor *pointer_border_color = _circleInsteadArrow ? [UIColor whiteColor] : [UIColor blackColor];
    UIColor *brightness_base_color = _colorfulBrightnessWheel && !_colorWheelHidden ? _color : [UIColor blackColor];
    
    if ( !_colorWheelHidden ) {
        _wheelWidth /= 2;
    }
    
    float markerSize = _wheelWidth/(_circleInsteadArrow ? 5 : 3);
    
    if (!_powerButtonHidden) {
        _powerBtnRadius = [self drawPowerButtonWithCtx: ctx wheelRadius:_circleInsteadArrow ? radius : radius * 0.8];
    }
    
    _brightnessWheelRadius = radius;
    [self drawWheelWithRadius:radius wheelWidth:_wheelWidth baseColor:brightness_base_color];
    _brightnessPointerCentralPoint = [self drawPointerWithAngle:brightness_angle wheelRadius:radius
                                                     wheelWidth:_wheelWidth inverse:!_colorWheelHidden color:brightness_pointer_color
                                                    borderColor:pointer_border_color ctx:ctx];
    [self drawWheelMarkers:self.brightnessMarkers withRadius:radius+_wheelWidth/2 markerSize:markerSize brightness:YES ctx:ctx];
    
    if ( !_colorWheelHidden ) {
        radius+=_wheelWidth;
        _colorWheelRadius = radius;
        
        [self drawWheelWithRadius:radius wheelWidth:_wheelWidth baseColor:nil];
        _colorPointerCentralPoint = [self drawPointerWithAngle:_colorAngle wheelRadius:radius
                                                    wheelWidth:_wheelWidth inverse:NO color:_color borderColor:pointer_border_color ctx:ctx];
        [self drawWheelMarkers:self.colorMarkers withRadius:radius+_wheelWidth/2
                    markerSize:markerSize brightness:NO ctx:ctx];
        
    }
    
    _pointerRadius = (_circleInsteadArrow ? _wheelWidth : _arrowHeight) / 2;
    
}

-(void)drawSliderWithCtx:(CGContextRef)ctx {
    
    CGFloat width = self.bounds.size.width;
    width /= 7.0;
    
    CGFloat height = self.bounds.size.height - width/2;
    _sliderRect = CGRectMake(width/-2.0, height /-2.0, width, height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_sliderRect cornerRadius:45];
    [path addClip];
    
    CGContextSetLineWidth(ctx, 2);
    UIColor *color;
    
    for(int a=0;a<height;a++) {
        color = [self calculateColorForAngle:360-(360.0*a/height) baseColor:[UIColor blackColor]];
        [color setStroke];
        
        CGContextMoveToPoint(ctx, _sliderRect.origin.x, _sliderRect.origin.y+a);
        CGContextAddLineToPoint(ctx, _sliderRect.origin.x+_sliderRect.size.width, _sliderRect.origin.y+a);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
    }
    
    _sliderPointerRange = _sliderRect.size.height - _sliderRect.size.width;
    float yoffset = _sliderPointerRange - _sliderPointerRange * _brightness / 100;
    CGRect pointerRect = _sliderRect;
    pointerRect.origin.y += yoffset;
    pointerRect.size.height = pointerRect.size.width;
    
    float angle = 360-(360.0*yoffset/_sliderPointerRange);
    [self trimBrightnessColorAngle:&angle];
    color = [self calculateColorForAngle:angle baseColor:[UIColor blackColor]];
    
    _brightnessPointerCentralPoint = [self drawCirclePointerInRect:pointerRect
                                                             color:color
                                                       borderColor:[UIColor whiteColor] ctx:ctx];
    _pointerRadius = pointerRect.size.width / 2;
    [self drawSliderMarkersInRect:_sliderRect markerSize:_sliderRect.size.width/5 ctx:ctx];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    
    CGContextTranslateCTM(ctx, self.bounds.size.width/2, self.bounds.size.height/2);
    
    if (_sliderHidden) {
        [self drawWheelWithCtx:ctx];
    } else {
        [self drawSliderWithCtx:ctx];
    }
    
}

-(float)angleForPoint:(CGPoint)point {
    
    CGRect r = self.bounds;
    
    r.origin.x = r.size.width / 2;
    r.origin.y = r.size.height / 2;
    
    float angle = atan2f(r.origin.y - point.y, r.origin.x - point.x) * 180.0 / M_PI;
    
    if ( angle < 0 )
        angle = 360 + angle;
    
    return angle;
    
}

- (BOOL)touchOverCircle:(CGPoint)touch_point centralPoint:(CGPoint)central_point radius:(CGFloat)radius {
    return sqrtf(pow(central_point.x - touch_point.x , 2) + pow(central_point.y - touch_point.y , 2)) <= radius;
}

- (BOOL)touchOverSlider:(CGPoint)touch_point {
    return CGRectContainsPoint(_sliderRect, touch_point);
}

- (BOOL) touchOverColorWheel:(CGPoint)touch_point {
    CGPoint center = CGPointMake(0, 0);
    
    return !_colorWheelHidden
           && ![self touchOverCircle:touch_point centralPoint:center radius:_colorWheelRadius]
           && [self touchOverCircle:touch_point centralPoint:center radius:_colorWheelRadius+_wheelWidth];
}

- (BOOL) touchOverBrightnessWheel:(CGPoint)touch_point {
    CGPoint center = CGPointMake(0, 0);
    
    return ![self touchOverCircle:touch_point centralPoint:center radius:_brightnessWheelRadius]
           && [self touchOverCircle:touch_point centralPoint:center radius:_brightnessWheelRadius+_wheelWidth];
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden) {
        return nil;
    }
    
    CGPoint transPoint = point;
    transPoint.x -= self.bounds.size.width / 2;
    transPoint.y -= self.bounds.size.height / 2;
    
    activeTouchPoint = ACTIVE_TOUCHPOINT_NONE;
    _moving = NO;
    
    if (_jumpToThePointOfTouchEnabled) {
        if (_sliderHidden) {
            
            float angle = [self angleForPoint:point];
            
            if ([self touchOverColorWheel:transPoint]) {
                 activeTouchPoint = ACTIVE_TOUCHPOINT_COLOR_POINTER;
                angle = [self addAngle:180 toAngle:angle];
                UIColor *color = [self calculateColorForAngle:angle baseColor:nil];
                [self setColor:color raiseEvent:YES calcAngle:YES];
                
            } else if ([self touchOverBrightnessWheel:transPoint]) {
               activeTouchPoint = ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER;
                angle = [self addAngle:-90 toAngle:angle];
                
                float brightness = angle * 100 / 360;
                if (brightness < _minBrightness) {
                    brightness = _minBrightness;
                }
                
               [self setBrightness:brightness raiseEvent:YES];
            }
        } else if ([self touchOverSlider: transPoint]) {
            activeTouchPoint = ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER;
            float percent = (transPoint.y - _sliderRect.origin.y
                             - (_sliderRect.size.height-_sliderPointerRange)/2)
                             * 100 / _sliderPointerRange;
            
            float brightness = 100-percent;
               if (brightness < _minBrightness) {
                   brightness = _minBrightness;
               }
            
            [self setBrightness:brightness raiseEvent:YES];
        }
    } else {
        if ( !_colorWheelHidden
            && [self touchOverCircle:transPoint centralPoint:_colorPointerCentralPoint radius:_pointerRadius] ) {
            activeTouchPoint = ACTIVE_TOUCHPOINT_COLOR_POINTER;
        } else if ( [self touchOverCircle:transPoint centralPoint:_brightnessPointerCentralPoint radius:_pointerRadius] ) {
            activeTouchPoint = ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER;
        }
    }
    
    if ( activeTouchPoint != ACTIVE_TOUCHPOINT_NONE ) {
        
        if (_sliderHidden) {
            lastPanPosition = [self angleForPoint:point];
        } else {
            lastPanPosition = point.y;
        }
        
        _moving = YES;
        return self;
    } else if ( !_powerButtonHidden
               && _powerButtonEnabled
               && [self touchOverCircle:transPoint centralPoint:CGPointMake(0, 0) radius:_powerBtnRadius]  ) {
        
        activeTouchPoint = ACTIVE_TOUCHPOINT_POWER_BUTTON;
        return self;
    }
    
    return nil;
}

-(float)brightness {
    return _brightness;
}

-(void)setBrightness:(float)brightness raiseEvent:(BOOL)raiseEvent {
    if (brightness < 0) {
        brightness = 0;
    } else if (brightness > 100) {
        brightness = 100;
    }
    
    if ( brightness != _brightness ) {
        _brightness = brightness;
        [self setNeedsDisplay];
        
        if ( raiseEvent
            && delegate != nil
            && [delegate respondsToSelector:@selector(cbPickerDataChanged:)] )
            [delegate cbPickerDataChanged: self];
    }

}

-(void)setBrightness:(float)brightness {
    [self setBrightness:brightness raiseEvent:NO];
}

-(void)setMinBrightness:(float)minBrightness {
    if (minBrightness > 100) {
        minBrightness = 100;
    } else if (minBrightness < 0) {
        minBrightness = 0;
    }
    
    _minBrightness = minBrightness;
}

-(float)minBrightness {
    return _minBrightness;
}

- (void)addBrightnessOffset:(float)offset {
    float brightness = _brightness+offset;
    if (brightness < _minBrightness) {
        brightness = _minBrightness;
    }
    [self setBrightness:brightness raiseEvent:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)gr {
    if ( gr.state == UIGestureRecognizerStateEnded) {
        _moving = NO;
        
        if (activeTouchPoint == ACTIVE_TOUCHPOINT_POWER_BUTTON) {
            self.powerButtonOn = !self.powerButtonOn;
            if (delegate != nil
                && [delegate respondsToSelector:@selector(cbPickerPowerButtonValueChanged:)]) {
                [delegate cbPickerPowerButtonValueChanged: self];
            }
            [self setNeedsDisplay];
        }
        
        activeTouchPoint = ACTIVE_TOUCHPOINT_NONE;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    if (activeTouchPoint == ACTIVE_TOUCHPOINT_NONE) {
        return;
    }
    
    if ( gr.state == UIGestureRecognizerStateEnded) {
        _moving = NO;
        activeTouchPoint = ACTIVE_TOUCHPOINT_NONE;
        
        if (delegate != nil
            && [delegate respondsToSelector:@selector(cbPickerMoveEnded:)] ) {
            [delegate cbPickerMoveEnded: self];
        }
        return;
    }
    
    CGPoint touch_point = [gr locationInView:self];
    
    if (!_sliderHidden) {
        
        if ( activeTouchPoint != ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER ) {
            return;
        }
        
        [self addBrightnessOffset:(lastPanPosition-touch_point.y) * 100 / _sliderPointerRange];
        
        lastPanPosition = touch_point.y;
        
    } else if ( activeTouchPoint != ACTIVE_TOUCHPOINT_POWER_BUTTON ) {
        
        CGRect r = self.bounds;
        
        r.origin.x = r.size.width / 2;
        r.origin.y = r.size.height / 2;
        
        float angle = [self angleForPoint:touch_point];
        
        if ( angle < 0 )
            angle = 360+angle;
        
        float angle_offset;
        
        if ( angle < 100 && lastPanPosition > 300 ) {
            angle_offset = (angle + 360 - lastPanPosition) * -1;
            
        } else if ( angle > 300 && lastPanPosition < 100 ) {
            angle_offset = lastPanPosition + 360 - angle;
            
        } else {
            angle_offset = lastPanPosition-angle;
        }
        
        
        angle_offset*=-1;
        
        if ( activeTouchPoint == ACTIVE_TOUCHPOINT_COLOR_POINTER ) {
            
            UIColor *color = nil;
            
            _colorAngle = [self addAngle:angle_offset toAngle:_colorAngle];
            color = [self calculateColorForAngle:[self addAngle:270 toAngle:_colorAngle] baseColor:nil];
            [self setColor:color raiseEvent:YES calcAngle:NO];
                        
        } else if ( activeTouchPoint == ACTIVE_TOUCHPOINT_BRIGHTNESS_POINTER ) {
            [self addBrightnessOffset: angle_offset * 100 / 360];
        }
        
        lastPanPosition = angle;
    }
    
    [self setNeedsDisplay];
}

@end

