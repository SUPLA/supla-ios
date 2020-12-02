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

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180.0)
#define MAXIMUM_OPENING_ANGLE 40
#define WINDOW_ROTATION_X 30
#define WINDOW_ROTATION_Y 330
#define WINDOW_HEIGHT_MULTIPLIER 1.0
#define WINDOW_WIDTH_RATIO 0.69
#define LINE_WIDTH 1.5

#import "SARoofWindowController.h"

@implementation SARoofWindowController {
    BOOL initialized;
    float _rotationX;
    float _rotationY;
    float _rotationZ;
    float _closingPercentage;
    float _closingPercentageWhileMoving;
    UIColor *_lineColor;
    UIColor *_frameColor;
    UIColor *_glassColor;
    UIColor *_markerColor;
    CGFloat lastX;
    CGFloat lastY;
    UIPanGestureRecognizer *_gr;
    NSArray *_markers;
}

@synthesize delegate;

-(void)rwcInit {
    if ( initialized )
        return;
    
    _closingPercentageWhileMoving = -1;
    _markers = nil;
    _lineColor = [UIColor blackColor];
    _frameColor = [UIColor whiteColor];
    _glassColor = [UIColor colorWithRed: 0.75 green: 0.85 blue: 0.95 alpha: 1.00];
    _markerColor = [_glassColor copy];
    
    _gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [_gr setMinimumNumberOfTouches:1];
    [_gr setMaximumNumberOfTouches:1];
    
    [self addGestureRecognizer:_gr];
}

-(id)init {
    self = [super init];
    
    if ( self != nil ) {
        [self rwcInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self rwcInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if ( self != nil ) {
        [self rwcInit];
    }
    
    return self;
}

-(void)makeRotationOfPoints:(float[])points pLength:(int)pLen rotationXoffset:(float)rotationXoffset {
    CGPoint p;
    
    CATransform3D transform3d = CATransform3DMakeRotation(DEGREES_TO_RADIANS(WINDOW_ROTATION_Y), 0, 1, 0);
    transform3d = CATransform3DRotate(transform3d, DEGREES_TO_RADIANS((WINDOW_ROTATION_X+rotationXoffset)), 1, 0, 0);
    CGAffineTransform transform = CATransform3DGetAffineTransform(transform3d);
    
    for(int a=0;a<pLen-1;a+=2) {
        p.x = points[a];
        p.y = points[a+1];
        
        p = CGPointApplyAffineTransform(p, transform);
        points[a] = p.x;
        points[a+1] = p.y;
    }
}

-(void)preparePathWithPoints:(float[])points pLength:(int)pLen context:(CGContextRef)ctx excluded:(BOOL (^ __nullable)(int a))excluded {
    for(int a=0;a<pLen-1;a+=2) {
        if (a==0 || (excluded && excluded(a))) {
            CGContextMoveToPoint(ctx, points[a], points[a+1]);
        } else {
            CGContextAddLineToPoint(ctx, points[a], points[a+1]);
        }
    }
}

-(void)drawMarkersWithContext:(CGContextRef)ctx
                                frameWidth:(float)frameWidth
                                frameHeight:(float)frameHeight
                                framePostWidth:(float)framePostWidth
                                frameBarWidth:(float)frameBarWidth
{
    if (_markers == nil || _markers.count == 0) {
        return;
    }
    
    [_markerColor setStroke];
    
    int mpLen = 0;
    float xoffset = 0;
    
    for(int a=0;a<_markers.count;a++) {
        float markerPoints[] = {
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
        };
        
        mpLen = sizeof(markerPoints)/sizeof(float);
        xoffset = [self closingPercentageToXoffset:[[_markers objectAtIndex:a] floatValue]];
    
        [self makeRotationOfPoints:markerPoints pLength:mpLen rotationXoffset:xoffset];
        [self preparePathWithPoints:markerPoints pLength:mpLen context:ctx excluded:nil];
        CGContextStrokePath(ctx);
    }
}

-(void)drawInnerFrameWithOuterLineExcusion:(BOOL)excludeOuterLines
                                frameWidth:(float)frameWidth
                                frameHeight:(float)frameHeight
                             framePostWidth:(float)framePostWidth
                              frameBarWidth:(float)frameBarWidth
                            rotationXoffset:(float)rotationXoffset
                                   Context:(CGContextRef)ctx
{

    [_frameColor setStroke];
    [_frameColor setFill];
    
    float framePoints[] = {
            frameWidth/-2, frameHeight/-2,
            frameWidth/2, frameHeight/-2,
            frameWidth/2, 0,
            frameWidth/2, frameHeight/2,
            frameWidth/-2, frameHeight/2,
            frameWidth/-2, 0,
            frameWidth/-2, frameHeight/-2,

            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
    };
    
    int fpLen = sizeof(framePoints)/sizeof(float);
    [self makeRotationOfPoints:framePoints pLength:fpLen rotationXoffset:rotationXoffset];
    [self preparePathWithPoints:framePoints pLength:fpLen context:ctx excluded:^BOOL(int a) {
        return a == 14;
    }];
        
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    float mirrorPoints[] = {
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/2-framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/2-frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
    };
    
    int mpLen = sizeof(mirrorPoints)/sizeof(float);
    [self makeRotationOfPoints:mirrorPoints pLength:mpLen rotationXoffset:rotationXoffset];
    [self preparePathWithPoints:mirrorPoints pLength:mpLen context:ctx excluded:nil];
        
    [_glassColor setFill];
    CGContextFillPath(ctx);
    
    [self preparePathWithPoints:framePoints pLength:fpLen context:ctx excluded:^BOOL(int a) {
        return a == 14 || (excludeOuterLines && a>=6 && a<=10);
    }];
        
    [_lineColor setStroke];
    CGContextStrokePath(ctx);
}

-(void)drawOuterFrameRemainPartWithInnerLineExcusion:(BOOL)excludeInnerLines
                                frameWidth:(float)frameWidth
                                frameHeight:(float)frameHeight
                                bottomFramePostWidth:(float)bottomFramePostWidth
                                bottomFrameBarWidth:(float)bottomFrameBarWidth
                                Context:(CGContextRef)ctx
{
    float points[] = {
            frameWidth/-2+bottomFramePostWidth, 0,
            frameWidth/-2+bottomFramePostWidth, frameHeight/2-bottomFrameBarWidth,
            frameWidth/-2, frameHeight/2,
            frameWidth/-2, 0
    };
    
    int pLen = sizeof(points)/sizeof(float);
    [self makeRotationOfPoints:points pLength:pLen rotationXoffset:0];
    
    for(int a=0;a<pLen-1;a+=2) {
        if (a==0) {
            CGContextMoveToPoint(ctx, points[a], points[a+1]);
        } else {
            CGContextAddLineToPoint(ctx, points[a], points[a+1]);
        }
    }
    
    [_frameColor setFill];
    [_frameColor setStroke];
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    [self preparePathWithPoints:points pLength:pLen context:ctx excluded:^BOOL(int a) {
        return a == 4 || (excludeInnerLines && a == 2);
    }];
        
    [_lineColor setStroke];
    CGContextStrokePath(ctx);
}

-(void)drawOuterFrameMainPartWithInnerLineExcusion:(BOOL)excludeInnerLines
                                        frameWidth:(float)frameWidth
                                       frameHeight:(float)frameHeight
                                    framePostWidth:(float)framePostWidth
                              bottomFramePostWidth:(float)bottomFramePostWidth
                                     frameBarWidth:(float)frameBarWidth
                               bottomFrameBarWidth:(float)bottomFrameBarWidth
                                           Context:(CGContextRef)ctx
{
    float points[] = {
            frameWidth/-2, 0,
            frameWidth/-2, frameHeight/-2,
            frameWidth/2, frameHeight/-2,
            frameWidth/2, frameHeight/2,
            frameWidth/-2, frameHeight/2,
            frameWidth/-2+bottomFramePostWidth, frameHeight/2-bottomFrameBarWidth,
            frameWidth/2-bottomFramePostWidth, frameHeight/2-bottomFrameBarWidth,
            frameWidth/2-bottomFramePostWidth, 0,
            frameWidth/2-framePostWidth, 0,
            frameWidth/2-framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/-2+framePostWidth, frameHeight/-2+frameBarWidth,
            frameWidth/-2+framePostWidth, 0,
            frameWidth/-2+bottomFramePostWidth, 0,
    };
    
    int pLen = sizeof(points)/sizeof(float);
    [self makeRotationOfPoints:points pLength:pLen rotationXoffset:0];
    [self preparePathWithPoints:points pLength:pLen context:ctx excluded:nil];
    
    [_frameColor setFill];
    [_frameColor setStroke];
   
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    [_frameColor setFill];
    [_lineColor setStroke];
    
    [self preparePathWithPoints:points pLength:pLen context:ctx excluded:^BOOL(int a) {
        return a==10 || (excludeInnerLines && ((a >= 12 && a <= 16) || a == 24));
    }];
    
    CGContextStrokePath(ctx);
}

- (float)closingPercentageToXoffset:(float)percent {
    return MAXIMUM_OPENING_ANGLE * (100.0 - percent / 100.00);
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    CGContextTranslateCTM(ctx, self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextSetLineWidth(ctx, LINE_WIDTH);

    CGFloat windowHeight = self.bounds.size.height * WINDOW_HEIGHT_MULTIPLIER;
    CGFloat windowWidth = windowHeight * WINDOW_WIDTH_RATIO;
    if (windowWidth > self.bounds.size.width * 0.70) {
        windowWidth = self.bounds.size.width * 0.70;
        windowHeight = windowWidth / WINDOW_WIDTH_RATIO;
    }
    
    CGFloat outerFramePostWidth = windowWidth * 0.1f;
    CGFloat outerFrameBarWidth = outerFramePostWidth * 0.8f;
    
    CGFloat closingPercentage = _closingPercentageWhileMoving > -1 ? _closingPercentageWhileMoving : _closingPercentage;

    CGFloat rotationXoffset = [self closingPercentageToXoffset:closingPercentage];
    
    [self drawOuterFrameRemainPartWithInnerLineExcusion:closingPercentage >= 100
                                    frameWidth:windowWidth
                                    frameHeight:windowHeight
                                    bottomFramePostWidth:outerFramePostWidth/2
                                    bottomFrameBarWidth:outerFrameBarWidth/2
                                    Context:ctx];
    
    if (closingPercentage == 0
        && _closingPercentageWhileMoving == -1
        && _markers != nil && _markers.count > 0) {
        [self drawMarkersWithContext:ctx
                                    frameWidth:windowWidth-outerFramePostWidth
                                    frameHeight:windowHeight-outerFrameBarWidth
                                    framePostWidth:outerFramePostWidth/2
                                    frameBarWidth:outerFrameBarWidth/2];
    } else {
        [self drawInnerFrameWithOuterLineExcusion:closingPercentage >= 100
                                    frameWidth:windowWidth-outerFramePostWidth
                                    frameHeight:windowHeight-outerFrameBarWidth
                                    framePostWidth:outerFramePostWidth/2
                                    frameBarWidth:outerFrameBarWidth/2
                                    rotationXoffset:rotationXoffset
                                    Context:ctx];
    }
    
    [self drawOuterFrameMainPartWithInnerLineExcusion:closingPercentage >= 100
                                           frameWidth:windowWidth
                                          frameHeight:windowHeight
                                       framePostWidth:outerFramePostWidth
                                 bottomFramePostWidth:outerFramePostWidth/2
                                        frameBarWidth:outerFrameBarWidth
                                  bottomFrameBarWidth:outerFrameBarWidth/2
                                              Context:ctx];
        
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    CGPoint touch_point = [gr locationInView:self];
    
    if ( gr.state == UIGestureRecognizerStateEnded
         || gr.state == UIGestureRecognizerStateCancelled
         || gr.state == UIGestureRecognizerStateFailed ) {
    
        if ( delegate != nil )
            [delegate roofWindowClosingPercentageChanged:self percent:_closingPercentageWhileMoving];
        
        _closingPercentageWhileMoving = -1;
        
    } else {
        if ( _closingPercentageWhileMoving < 0 ) {
            if ( gr.state == UIGestureRecognizerStateBegan  ) {
                _closingPercentageWhileMoving = _closingPercentage;
            }
        } else {
            CGFloat delta = touch_point.y - lastY;
            
            if ( fabs(touch_point.x-lastX) < fabs(delta)  ) {
                
                float p = fabs(delta) * 100.00 / (self.bounds.size.height * WINDOW_HEIGHT_MULTIPLIER / 2);
                
                _closingPercentageWhileMoving += p * (delta > 0 ? 1 : -1);
                
                if ( _closingPercentageWhileMoving < 0 ) {
                    _closingPercentageWhileMoving = 0;
                } else if ( _closingPercentageWhileMoving > 100 ) {
                    _closingPercentageWhileMoving = 100;
                }
                
                if ( delegate != nil ) {
                    [delegate roofWindowClosingPercentageChangeing:self percent:_closingPercentageWhileMoving];
                }
            }
        }
    }
    
    lastX = touch_point.x;
    lastY = touch_point.y;
    
    [self setNeedsDisplay];
    
}

-(float)closingPercentage {
    return _closingPercentage;
}

-(void)setClosingPercentage:(float)closingPercentage {
    if (closingPercentage > 100) {
        closingPercentage = 100;
    } else if (closingPercentage < 0) {
        closingPercentage = 0;
    }
    
    if (closingPercentage != _closingPercentage) {
        _closingPercentage = closingPercentage;
        [self setNeedsDisplay];
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    if (lineColor!=nil) {
        _lineColor = [lineColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)lineColor {
    return _lineColor;
}

- (void)setFrameColor:(UIColor *)frameColor {
    if (frameColor!=nil) {
        _frameColor = [frameColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)frameColor {
    return _frameColor;
}

- (void)setGlassColor:(UIColor *)glassColor {
    if (glassColor!=nil) {
        _glassColor = [glassColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)glassColor {
    return _glassColor;
}

- (void)setMarkerColor:(UIColor *)markerColor {
    if (markerColor!=nil) {
        _markerColor = [markerColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)markerColor {
    return _markerColor;
}

-(NSArray*)markers {
    return _markers;
}

-(void)setMarkers:(NSArray *)markers {
    if (markers == nil || markers.count == 0) {
        _markers = nil;
    } else {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int a=0;a<markers.count;a++) {
            id element = [markers objectAtIndex:a];
            if (element && [element isKindOfClass:[NSNumber class]]) {
                float value = [element floatValue];
                if (value > 100) {
                    value = 100;
                } else if (value < 0) {
                    value = 0;
                }
                [arr addObject:[NSNumber numberWithFloat:value]];
            }
        }
        
        if (arr.count > 0) {
            _markers = arr;
        } else {
            _markers = nil;
        }
    }
    [self setNeedsDisplay];
}

@end
