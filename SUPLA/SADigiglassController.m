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

#import "SADigiglassController.h"
#import <math.h>

#define BTN_PICTOGRAM_MAX_WIDTH 50
#define SECTION_BUTTON_MAX_SIZE 50

@implementation SADigiglassController {
    BOOL initialized;
    BOOL _horizontal;
    int _sectionCount;
    int _transparentSections;
    CGFloat _lineWidth;
    UIColor *_barColor;
    UIColor *_lineColor;
    UIColor *_glassColor;
    UIColor *_dotColor;
    UIColor *_btnBackgroundColor;
    UIColor *_btnDotColor;
}

@synthesize delegate;

-(void)dcInit {
    if ( initialized )
        return;
    _horizontal = NO;
    _lineWidth = 2;
    _sectionCount = 7;
    _barColor = [UIColor whiteColor];
    _lineColor = [UIColor blackColor];
    _glassColor = [UIColor colorWithRed: 0.74 green: 0.85 blue: 0.95 alpha: 1.00];
    _dotColor = [UIColor blackColor];
    _btnBackgroundColor = [UIColor whiteColor];
    _btnDotColor = [UIColor blackColor];
    
    initialized = YES;
}

-(id)init {
    self = [super init];
    
    if ( self != nil ) {
        [self dcInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self dcInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if ( self != nil ) {
        [self dcInit];
    }
    
    return self;
}

-(void)setVertical:(BOOL)horizontal {
    _horizontal = horizontal;
    [self setNeedsDisplay];
}

-(BOOL)vertical {
    return _horizontal;
}

-(void)setSectionCount:(int)sectionCount {
    if (sectionCount < 1) {
        sectionCount = 1;
    } else if (sectionCount > 7) {
        sectionCount = 7;
    }
    _sectionCount = sectionCount;
    _transparentSections &= (int)(pow(2, _sectionCount) - 1);
    [self setNeedsDisplay];
}

-(int)sectionCount {
    return _sectionCount;
}

-(void)setTransparentSections:(int)transparentSections {
    _transparentSections = transparentSections & (int) (pow(2, _sectionCount) - 1);
    [self setNeedsDisplay];
}

-(int)transparentSections {
    return _transparentSections;
}

-(void)setLineWidth:(CGFloat)lineWidth {
    if (lineWidth < 0.1) {
        lineWidth = 0.1;
    } else if (lineWidth > 20) {
        lineWidth = 20;
    }
    
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

-(CGFloat)lineWidth {
    return _lineWidth;
}

- (void)setBarColor:(UIColor *)barColor {
    if (barColor!=nil) {
        _barColor = [barColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)barColor {
    return _barColor;
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

- (void)setGlassColor:(UIColor *)glassColor {
    if (glassColor!=nil) {
        _glassColor = [glassColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)glassColor {
    return _glassColor;
}

- (void)setDotColor:(UIColor *)dotColor {
    if (dotColor!=nil) {
        _dotColor = [dotColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)dotColor {
    return _dotColor;
}

- (void)setBtnBackgroundColor:(UIColor *)btnBackgroundColor {
    if (btnBackgroundColor!=nil) {
        _btnBackgroundColor = [btnBackgroundColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)btnBackgroundColor {
    return _btnBackgroundColor;
}

- (void)setBtnDotColor:(UIColor *)btnDotColor {
    if (btnDotColor!=nil) {
        _btnDotColor = [btnDotColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor*)btnDotColor {
    return _btnDotColor;
}

-(CGFloat)barHeight {
    return self.bounds.size.height * 0.05;
}

-(void)drawCircle:(CGContextRef)ctx x:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius {
    CGContextAddEllipseInRect(ctx, CGRectMake(x-radius, y-radius, radius*2, radius*2));
    CGContextFillPath(ctx);
}

-(void)drawDots:(CGContextRef)ctx inRect:(CGRect)rect {
    [_glassColor setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: rect];
    [path fill];
    
    [_dotColor setFill];
    
    CGFloat fieldRadius = 1.0f;
    CGFloat pointRadius = 0.5f;
    CGFloat diameter = fieldRadius * 2;
    int cw = rect.size.width / diameter;
    int ch = rect.size.height / diameter;
    
    CGFloat wmargin = (rect.size.width - cw*diameter) / 2;
    CGFloat hmargin = (rect.size.height - ch*diameter) / 2;
    
    for(int a=0;a<ch;a++) {
        for(int b=0;b<cw;b++) {
            if (b%2 != a%2) {
                [self drawCircle:ctx
                               x:rect.origin.x+wmargin+fieldRadius+b*diameter
                               y:rect.origin.y+hmargin+fieldRadius+a*diameter
                          radius:pointRadius];
            }
        }
    }
}

-(CGRect)rectForSectionNumber:(int)number {
    CGFloat barHeight = [self barHeight];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;

    float sectionSize = (_horizontal ? width : (height - 2 * barHeight))
            / _sectionCount;
    if (_horizontal) {
        return CGRectMake(sectionSize * number,
                          barHeight,
                          sectionSize + 1,
                          height - barHeight * 2);
    } else {
        return CGRectMake(_lineWidth,
                          barHeight + sectionSize * number,
                          width - _lineWidth * 2,
                          sectionSize + 1);
    }
}

-(CGRect)btnRectInSectionRect:(CGRect)sectionRect {
    CGFloat width = sectionRect.size.width;
    if (sectionRect.size.height < width) {
        width = sectionRect.size.height;
    }

    width*=0.6;

    if (width > SECTION_BUTTON_MAX_SIZE) {
        width = SECTION_BUTTON_MAX_SIZE;
    }
    if (_horizontal) {
        return CGRectMake(sectionRect.origin.x+sectionRect.size.width/2-width/2,
                          sectionRect.origin.y + sectionRect.size.height - width - sectionRect.size.height * 0.05,
                          width, width);
    } else {
        
        return CGRectMake(sectionRect.origin.x+sectionRect.size.width - width - sectionRect.size.width * 0.05,
                          sectionRect.origin.y+sectionRect.size.height/2-width/2,
                          width,
                          width);
    }

}

-(void)drawButton:(CGContextRef)ctx inRect:(CGRect)rect lines:(BOOL)lines {
    CGFloat radius = rect.size.width;
    if (rect.size.height < radius) {
        radius = rect.size.height;
    }
    
    radius /=2;
    
    [_btnBackgroundColor setFill];
    
    CGFloat centerx = rect.origin.x+rect.size.width/2;
    CGFloat centery = rect.origin.y+rect.size.height/2;
    
    [self drawCircle:ctx x:centerx y:centery radius:radius];
    
    [_btnDotColor setFill];
    
    CGFloat p = radius * 1.2;
    
    if (p > BTN_PICTOGRAM_MAX_WIDTH) {
         p = BTN_PICTOGRAM_MAX_WIDTH;
    }
    
    CGFloat distance = p / 5.0;
    CGFloat r = distance * 0.35;
    CGFloat m, cx;
    int a;
    
    if (lines) {
        r*=0.8;
        
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, centerx, centery);
        CGContextRotateCTM(ctx, -45 * M_PI/180);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:
                              CGRectMake(p/-2.0,
                                         r/-2.0,
                                         p,
                                         r)];
        
        [path fill];
        
        p *= 0.6;
        path = [UIBezierPath bezierPathWithRect:
                              CGRectMake(p/-2.0,
                                         (distance + r/2.0)*-1,
                                         p,
                                         r)];
        
        [path fill];
        
        path = [UIBezierPath bezierPathWithRect:
                              CGRectMake(p/-2.0,
                                         distance - r/2.0,
                                         p,
                                         r)];
        
        [path fill];
     
        CGContextRestoreGState(ctx);
        return;
    }
    
    for(a=0;a<6;a++) {
        m = r;
        if (a == 0 || a == 5) {
            m *= 0.5f;
        } else if (a == 1 || a == 4) {
            m *= 0.8f;
        }

        cx = centerx + p/2.0 - a*distance;

        [self drawCircle:ctx x:cx y:centery-distance/2.0 radius:m];
        [self drawCircle:ctx x:cx y:centery+distance/2.0 radius:m];
    }
    
    m = r * 0.8f;

    for(a=1;a<5;a++) {
        cx = centerx + p/2.0 - a*distance;

        [self drawCircle:ctx x:cx y:centery-(distance/2.0+distance) radius:m];
        [self drawCircle:ctx x:cx y:centery+(distance/2.0+distance) radius:m];
    }
    
    m = r * 0.5f;

    for(a=2;a<4;a++) {
        cx = centerx + p/2.0 - a*distance;

        [self drawCircle:ctx x:cx y:centery-(distance/2.0+distance*2) radius:m];
        [self drawCircle:ctx x:cx y:centery+(distance/2.0+distance*2) radius:m];
    }
}

-(BOOL)isSectionTransparent:(int)number {
    return (_transparentSections & (1 << number)) > 0;
}

- (void)setAllTransparent {
    _transparentSections = (int) (pow(2, _sectionCount) - 1);
    [self setNeedsDisplay];
}

- (void)setAllOpaque {
    _transparentSections = 0;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetLineWidth(ctx, _lineWidth);
    
    CGFloat lineHalfWidth = _lineWidth / 2.0;
    CGFloat barHeight = [self barHeight];
    
    [self drawDots:ctx inRect:
     CGRectMake(_lineWidth,
                barHeight,
                self.bounds.size.width - _lineWidth*2,
                self.bounds.size.height - barHeight)];
    
    
    for(int a=0;a<_sectionCount;a++) {
        CGRect rect = [self rectForSectionNumber:a];

        BOOL transparent = [self isSectionTransparent:a];

        if (transparent) {
            [_glassColor setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithRect: rect];
            
            [path fill];
        }

        rect = [self btnRectInSectionRect:rect];
        [self drawButton:ctx inRect:rect lines:transparent];
    }
    
    [_barColor setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:
                          CGRectMake(0,
                                     0,
                                     self.bounds.size.width,
                                     barHeight)];
   
 
    [path fill];
    
    path = [UIBezierPath bezierPathWithRect:
                          CGRectMake(0,
                                     self.bounds.size.height-barHeight,
                                     self.bounds.size.width,
                                     self.bounds.size.height)];
   
    [path fill];
    
    [_lineColor setStroke];

    CGContextMoveToPoint(ctx, 0, lineHalfWidth);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, lineHalfWidth);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height-lineHalfWidth);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height-lineHalfWidth);
    CGContextStrokePath(ctx);
    
    path = [UIBezierPath bezierPathWithRect:
                          CGRectMake(lineHalfWidth, barHeight-lineHalfWidth,
                                     self.bounds.size.width-_lineWidth,
                                     self.bounds.size.height-barHeight*2)];
    [path setLineWidth:_lineWidth];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    for(int a=0;a<_sectionCount;a++) {
        CGRect rect = [self rectForSectionNumber:a];
          if (CGRectContainsPoint(rect, point)) {
              int transparentSections = _transparentSections;
              transparentSections ^= 1<<a;
              [self setTransparentSections:transparentSections];
              
              if ( delegate != nil )
                  [delegate digiglassSectionTouched:self
                                      sectionNumber:a
                                      isTransparent:[self isSectionTransparent:a]];
              break;
          }
      }
}

@end
