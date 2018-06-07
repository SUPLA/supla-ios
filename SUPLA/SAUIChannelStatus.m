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

#import "SAUIChannelStatus.h"

@implementation SAUIChannelStatus {
    BOOL _singleColor;
    channelStatusShapeType _shapeType;
    double _percent;
    UIColor *_offlineColor;
    UIColor *_onlineColor;
    UIColor *_borderColor;
}

- (BOOL) singleColor {
    return _singleColor;
}

- (void) setSingleColor:(BOOL)singleColor {
    _singleColor = singleColor;
    [self setNeedsDisplay];
}

- (channelStatusShapeType) shapeType {
    return _shapeType;
}

- (void)setShapeType:(channelStatusShapeType)shapeType {
    _shapeType = shapeType;
    [self setNeedsDisplay];
}

- (double)percent {
    return _percent;
}

- (void)setPercent:(double)percent {
    _percent = percent;
    [self setNeedsDisplay];
}

- (UIColor*) offlineColor {
    if (_offlineColor == nil) {
        return [UIColor redColor];
    }
    return _offlineColor;
}

- (void) setOfflineColor:(UIColor *)offlineColor {
    _offlineColor = offlineColor;
    [self setNeedsDisplay];
}

- (UIColor*) onlineColor {
    if (_onlineColor == nil) {
        return [UIColor greenColor];
    }
    return _onlineColor;
}

- (void) setOnlineColor:(UIColor *)onlineColor {
    _onlineColor = onlineColor;
    [self setNeedsDisplay];
}

- (UIColor*) borderColor {
    if (_borderColor == nil) {
        return [UIColor blackColor];
    }
    return _borderColor;
}

- (void) setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

-(void)assignColors:(SAUIChannelStatus*)status {
    self.onlineColor = status.onlineColor;
    self.offlineColor = status.offlineColor;
    self.borderColor = status.borderColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    
    CGColorRef color = [self.offlineColor CGColor];
    
    if ( self.shapeType == stRing || self.shapeType == stDot ) {
        if (self.percent > 0) {
            color = [self.onlineColor CGColor];
        }
        
        CGFloat n = rect.size.height;
        
        if (rect.size.height > rect.size.width) {
            n = rect.size.width;
        }
        
        rect.origin.x = rect.size.width / 2 - n / 2;
        rect.origin.y = rect.size.height / 2 - n / 2;
        
        rect.size.height = n;
        rect.size.width = n;
    } else {
        CGContextSetFillColor(ctx, CGColorGetComponents(color));
    }
    
    if (self.shapeType == stLinearVertical) {
        
        CGRect r = rect;
        double percentPoint = r.size.height * (100 - self.percent) / 100;
        r.size.height = percentPoint;
    
        if (!self.singleColor) {
            CGContextFillRect(ctx, r);
        }
        
        CGContextSetFillColor(ctx, CGColorGetComponents([self.onlineColor CGColor]));
        r.size.height = rect.size.height - r.size.height;
        r.origin.y += percentPoint;
        CGContextFillRect(ctx, r);
        
    } else if (self.shapeType == stLinearHorizontal) {
        
        CGRect r = rect;
        double percentPoint = r.size.width * (100 - self.percent) / 100;
        r.size.width = percentPoint;
        
        if (!self.singleColor) {
            CGContextFillRect(ctx, r);
        }
        
        CGContextSetFillColor(ctx, CGColorGetComponents([self.onlineColor CGColor]));
        r.size.width = rect.size.width - r.size.width;
        r.origin.x += percentPoint;
        CGContextFillRect(ctx, r);
        
    } else if (self.shapeType == stRing) {
        float width = 1 / [[UIScreen mainScreen] scale];
        CGContextSetLineWidth(ctx, width);
        rect.origin.x+=width;
        rect.origin.y+=width;
        rect.size.height-=width*2;
        rect.size.width-=width*2;
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetStrokeColor(ctx, CGColorGetComponents(color));
        CGContextStrokePath(ctx);
    } else if (self.shapeType == stDot) {
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents(color));
        CGContextFillPath(ctx);
    }
    
    if (self.shapeType == stLinearVertical || self.shapeType == stLinearHorizontal) {
        CGContextSetFillColor(ctx, CGColorGetComponents([self.borderColor CGColor]));
        CGContextStrokeRect(ctx, rect);
    }
    
}

@end
