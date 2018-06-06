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
    channelStatusShapeType _shapeType;
    double _percent;
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

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorRef color = _percent > 0 ? [[UIColor onLine] CGColor] : [[UIColor offLine] CGColor];
    
    if ( _shapeType == stRing || _shapeType == stDot ) {
        
        CGFloat n = rect.size.height;
        
        if (rect.size.height > rect.size.width) {
            n = rect.size.width;
        }
        
        rect.origin.x = rect.size.width / 2 - n / 2;
        rect.origin.y = rect.size.height / 2 - n / 2;
        
        rect.size.height = n;
        rect.size.width = n;
    };
    
    if ( _shapeType == stRing ) {
        float width = 1 / [[UIScreen mainScreen] scale];
        CGContextSetLineWidth(ctx, width);
        rect.origin.x+=width;
        rect.origin.y+=width;
        rect.size.height-=width*2;
        rect.size.width-=width*2;
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetStrokeColor(ctx, CGColorGetComponents(color));
        CGContextStrokePath(ctx);
    } else if ( _shapeType == stDot ) {
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents(color));
        CGContextFillPath(ctx);
    }
    
    
    
}

@end
