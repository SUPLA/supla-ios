/*
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

#import "SARollerShutter.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@implementation SARollerShutter {
    BOOL initialized;
    BOOL moving;
    NSArray *_markers;
    UIColor *_windowFrameColor;
    UIColor *_windowFrameLineColor;
    UIColor *_sunColor;
    UIColor *_glassColor;
    UIColor *_markerColor;
    UIColor *_rollerShutterBackgroundColor;
    UIColor *_rollerShutterColor;
    UIColor *_rollerShutterLineColor;
    CGFloat _frameLineWidth;
    CGFloat _spaceing;
    CGFloat _louverSpaceing;
    short _louverCount;
    float _percent;
    float virtPercent;
    float _bottomPosition;
    UIPanGestureRecognizer *_gr;
    CGFloat moveX, moveY;
}

@synthesize delegate;

-(void)rsInit {
    
    if ( initialized )
        return;
    
    _markers = nil;
    _windowFrameColor = [UIColor whiteColor];
    _windowFrameLineColor = [UIColor blackColor];
    _markerColor = [UIColor redColor];
    _sunColor = [UIColor whiteColor];
    _glassColor = [UIColor colorWithRed: 0.75 green: 0.85 blue: 0.95 alpha: 1.00];
    _rollerShutterBackgroundColor = [UIColor colorWithRed: 0.93 green: 0.93 blue: 0.93 alpha: 1.00];
    _rollerShutterColor = [UIColor whiteColor];
    _rollerShutterLineColor = [UIColor blackColor];
    _frameLineWidth = 2;
    _spaceing = 3;
    _louverCount = 10;
    _louverSpaceing = 1.5;
    _percent = 0;
    virtPercent = 0;
    
    self.gestureEnabled = NO;
    
    initialized = YES;
}

-(id)init {
    
    self = [super init];
    
    if ( self != nil ) {
        [self rsInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self rsInit];
    }
    
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    
    if ( self != nil ) {
        [self rsInit];
    }
    
    
    return self;
}

-(NSArray*)markers {
    return _markers;
}

-(void)setMarkers:(NSArray *)markers {
    _markers = markers;
    
    if ( initialized ) {
        [self setNeedsDisplay];
    }
}

-(UIColor*)windowFrameColor {
    return _windowFrameColor;
}

-(void)setWindowFrameColor:(UIColor *)windowFrameColor {
    if (windowFrameColor != nil) {
        _windowFrameColor = windowFrameColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)windowFrameLineColor {
    return _windowFrameLineColor;
}

-(void)setWindowFrameLineColor:(UIColor *)windowFrameLineColor {
    if (windowFrameLineColor != nil) {
        _windowFrameLineColor = windowFrameLineColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)sunColor {
    return _sunColor;
}

-(void)setSunColor:(UIColor *)sunColor {
    if (sunColor != nil) {
        _sunColor = sunColor;
        [self setNeedsDisplay];
    }
}

-(void)setMarkerColor:(UIColor *)markerColor {
    if (markerColor != nil) {
        _markerColor = markerColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)markerColor {
    return _markerColor;
}

-(void)setGlassColor:(UIColor *)glassColor {
    if (glassColor != nil) {
        _glassColor = glassColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)glassColor {
    return _glassColor;
}

-(void)setRollerShutterBackgroundColor:(UIColor *)rollerShutterBackgroundColor {
    if (rollerShutterBackgroundColor != nil) {
        _rollerShutterBackgroundColor = rollerShutterBackgroundColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)rollerShutterBackgroundColor {
    return _rollerShutterBackgroundColor;
}

-(void)setRollerShutterColor:(UIColor *)rollerShutterColor {
    if (rollerShutterColor != nil) {
        _rollerShutterColor = rollerShutterColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)rollerShutterColor {
    return _rollerShutterColor;
}

-(void)setRollerShutterLineColor:(UIColor *)rollerShutterLineColor {
    if (rollerShutterLineColor != nil) {
        _rollerShutterLineColor = rollerShutterLineColor;
        [self setNeedsDisplay];
    }
}

-(UIColor*)rollerShutterLineColor {
    return _rollerShutterLineColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor == nil ? [UIColor whiteColor] : backgroundColor];
}

-(CGFloat)frameLineWidth {
    return _frameLineWidth;
}

-(void)setFrameLineWidth:(CGFloat)frameLineWidth {
    _frameLineWidth = frameLineWidth;
    
    if ( initialized )
        [self setNeedsDisplay];
}

-(float)percent {
    return _percent;
}

-(void)setPercent:(float)percent {
    _percent = percent;
    
    if ( initialized )
        [self setNeedsDisplay];
}

-(float)bottomPosition {
    return _bottomPosition;
}

-(void)setBottomPosition:(float)bottomPosition {
    if (bottomPosition < 0) {
        bottomPosition = 0;
    } else if (bottomPosition > 100) {
        bottomPosition = 100;
    }
    
    _bottomPosition = bottomPosition;
    [self setNeedsDisplay];
}

-(BOOL)gestureEnabled {
    return _gr != nil;
}

-(void)setGestureEnabled:(BOOL)gestureEnabled {
    
    if ( gestureEnabled ) {
        
        if ( _gr == nil ) {
            
            _gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            
            [_gr setMinimumNumberOfTouches:1];
            [_gr setMaximumNumberOfTouches:1];
            
            [self addGestureRecognizer:_gr];
            
        }
        
    } else {
        
        if ( _gr != nil ) {
            [self removeGestureRecognizer:_gr];
            _gr = nil;
        }
        
    }
    
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if ( initialized == NO ) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    [_windowFrameLineColor setStroke];
    [_windowFrameColor setFill];
    
    CGFloat lrMargin = _frameLineWidth * 0.5;
    
    CGFloat x = _frameLineWidth/2+lrMargin;
    CGFloat y = _frameLineWidth/2;
    CGFloat width = self.bounds.size.width - _frameLineWidth * 2;
    CGFloat height = self.bounds.size.height - _frameLineWidth;

    UIBezierPath *path =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, width, height) cornerRadius:1];
    path.lineWidth = _frameLineWidth;
    [path fill];
    [path stroke];
    
    x = lrMargin + _frameLineWidth * 1.5 + _spaceing;
    y = _frameLineWidth * 1.5 + _spaceing;
    width = self.bounds.size.width - _frameLineWidth * 4 - _spaceing * 3;
    height = self.bounds.size.height - _frameLineWidth * 3 - _spaceing * 3;
    
    width=width/2 - _frameLineWidth / 2;
    height=height/2 - _frameLineWidth / 2;
 
    [_glassColor setFill];
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, width, height)];
    path.lineWidth = _frameLineWidth;
    [path fill];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(x+width+_frameLineWidth+_spaceing, y, width, height)];
    path.lineWidth = _frameLineWidth;
    [path fill];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y+height+_frameLineWidth+_spaceing, width, height)];
    path.lineWidth = _frameLineWidth;
    [path fill];
    [path stroke];
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(x+width+_frameLineWidth+_spaceing, y+height+_frameLineWidth+_spaceing, width, height)];
    path.lineWidth = _frameLineWidth;
    [path fill];
    [path stroke];
    
    x += width+_frameLineWidth*1.5+_spaceing;
    y += _frameLineWidth/2;
    
    width -= _frameLineWidth;
    height -= _frameLineWidth;

    CGFloat h = (width > height ? height / 6 : width / 6)*2;
    
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x+width-h*1.5, y+h*0.5, h, h)];
    [_sunColor setStroke];
    path.lineWidth = _frameLineWidth/1.5;
    [path stroke];
    
    CGFloat ray_x = x+width-h;
    CGFloat ray_y = y+h;
    CGFloat ray_n = h/2 + (h*(float)0.1);
    CGFloat ray_m = h*(float)0.2;
    
    CGContextSetStrokeColorWithColor(context, _sunColor.CGColor);
    CGContextSetLineWidth(context, path.lineWidth);
    
    int a;
    for(a=0;a<360;a+=30) {
        
        double r = DEGREES_TO_RADIANS(a);
        CGFloat _ray_x = (float)(ray_x + cos(r)*(ray_n));
        CGFloat _ray_y = (float)(ray_y + sin(r)*(ray_n));
        
        CGContextMoveToPoint(context, _ray_x, _ray_y);
        CGContextAddLineToPoint(context, _ray_x + cos(r)*ray_m, _ray_y + sin(r)*ray_m);
        CGContextStrokePath(context);
    }
    
    float percent = moving ? virtPercent : _percent;
    CGContextSetLineWidth(context, 0.5);
    
    if (!moving && self.percent == 0 && self.markers != nil && self.markers.count > 0) {
        
        float markerHalfHeight = _spaceing + _frameLineWidth / 2;
        float markerArrowWidth = _spaceing * 2;
        float markerWidth = self.bounds.size.width / 20 + markerArrowWidth;
        float markerMargin = _frameLineWidth / 2;
        float pos;
        
        CGContextSetFillColorWithColor(context, _markerColor.CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        for (int a = 0; a < self.markers.count; a++) {
            for(short b=0;b<2;b++) {
                path = [UIBezierPath bezierPath];
                pos = (float) ((self.bounds.size.height - markerHalfHeight * 2) * [[self.markers objectAtIndex:a] intValue] / 100.00) + markerHalfHeight;
                
                [path moveToPoint: CGPointMake(markerMargin, pos)];
                [path addLineToPoint:CGPointMake(markerMargin + markerArrowWidth, pos - markerHalfHeight)];
                [path addLineToPoint:CGPointMake(markerMargin + markerWidth, pos - markerHalfHeight)];
                [path addLineToPoint:CGPointMake(markerMargin + markerWidth, pos + markerHalfHeight)];
                [path addLineToPoint:CGPointMake(markerMargin + markerArrowWidth, pos + markerHalfHeight)];
                [path addLineToPoint:CGPointMake(markerMargin, pos)];
                
                if (b==0) {
                    [path fill];
                } else {
                    [path stroke];
                }
                
            }
        }
    }
   
    if ( percent > 100 )
        percent = 100;
    else if ( percent < 0 )
        percent = 0;
    
    height = self.bounds.size.height;
    
    if (_bottomPosition > 0) {
        if (percent <= _bottomPosition) {
            height *= (percent * 100 / _bottomPosition) / 100;
        }
    } else {
        height *= percent / 100;
    }
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, height)];
    [_rollerShutterBackgroundColor setFill];
    [path fill];

    CGFloat LouverHeight = (self.bounds.size.height - _louverSpaceing * (_louverCount-1)) / _louverCount - _frameLineWidth;
    
    height-=_frameLineWidth/2;
    width = self.bounds.size.width - _frameLineWidth;
    x = _frameLineWidth/2;
    
    [_rollerShutterLineColor setStroke];
    [_rollerShutterColor setFill];
    
    short louverCount = _louverCount;
    
    if (_bottomPosition > 0 && percent > _bottomPosition) {
      louverCount = (int)(self.bounds.size.height / LouverHeight)+1;
    }

    for(a=0;a<louverCount;a++) {
        if (height < 0)
            break;

        float louverSpaceing = _louverSpaceing;

        if (_bottomPosition > 0 && percent > _bottomPosition) {
            float n = (louverCount-1)-((100-percent)/((100-_bottomPosition) / (louverCount-1)));

            if (n-a > 0) {
                n = 1 - (n-a);
                louverSpaceing = _louverSpaceing * n;
                if (louverSpaceing < 0) {
                    louverSpaceing = 0;
                }
            }
        }
        
        path = [UIBezierPath bezierPathWithRect:CGRectMake(x, height-LouverHeight, width, LouverHeight)];
        path.lineWidth = _frameLineWidth;
        [path fill];
        [path stroke];
        
        height=height-LouverHeight-louverSpaceing-_frameLineWidth;
    }
    
    CGContextSetStrokeColorWithColor(context, _rollerShutterLineColor.CGColor);
    CGContextMoveToPoint(context, 0, 0.25);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0.25);
    CGContextStrokePath(context);
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    CGPoint touch_point = [gr locationInView:self];
    
    if ( gr.state == UIGestureRecognizerStateEnded
         || gr.state == UIGestureRecognizerStateCancelled
         || gr.state == UIGestureRecognizerStateFailed ) {
        
        moving = NO;
        _percent = virtPercent;
        
        if ( delegate != nil )
            [delegate rsChanged:self withPercent:_percent];
        
    } else {
        
        if ( moving == NO ) {
            
            if ( gr.state == UIGestureRecognizerStateBegan  ) {
                
                virtPercent = _percent;
                moving = YES;
                
            }
            
        } else {
            
            CGFloat delta = touch_point.y - moveY;
            
            if ( fabs(touch_point.x-moveX) < fabs(delta)  ) {
                
                float p = fabs(delta) * 100.00 / self.bounds.size.height;
                
                if ( delta > 0 )
                    virtPercent += p;
                else
                    virtPercent -= p;
                
                if ( virtPercent < 0 )
                    virtPercent = 0;
                else if ( virtPercent > 100 )
                    virtPercent = 100;
                
                if ( delegate != nil )
                    [delegate rsChangeing:self withPercent:virtPercent];
                
            }
            
        }

    }
    
    moveX = touch_point.x;
    moveY = touch_point.y;
    
    [self setNeedsDisplay];
    
}

@end
