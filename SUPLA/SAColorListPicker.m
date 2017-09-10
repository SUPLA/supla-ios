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

#import "SAColorListPicker.h"

@implementation SAColorListPickerItem

@synthesize color;
@synthesize percent;
@synthesize extraParam1;
@synthesize extraParam2;
@synthesize rect;

@end

@implementation SAColorListPicker {
    BOOL initialized;
    NSMutableArray *items;
    
    CGFloat _space;
    CGFloat _borderWidth;
    UIColor *_borderColor;
    UIColor *_borderColorSelected;
    SAColorListPickerItem *_touchedItem;
    UIPanGestureRecognizer *_gr;
}

@synthesize delegate;

-(void)pickerInit {
    
    if ( initialized )
        return;
    
    _space = 10;
    _borderWidth = 1;
    _borderColor = [UIColor blackColor];
    _borderColorSelected = [UIColor yellowColor];
    _touchedItem = nil;
    
    items = [[NSMutableArray alloc] init];
    
    
   // _gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
   // [self addGestureRecognizer:_gr];
    
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

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ( items.count == 0 || initialized == NO )
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, _borderWidth);

    CGFloat bw05 = _borderWidth/2;
    CGFloat width = (self.bounds.size.width-_space * (items.count-1) - bw05 * items.count) / items.count;
    UIBezierPath *path;
    CGFloat x=bw05;
    
    CGFloat rl_margin = width * 0.05;
    CGFloat b_margin = width * 0.1;
    CGFloat p1_width,p2_width, p_x;
    
    for(int a=0;a<items.count;a++) {
        
        SAColorListPickerItem *item = [items objectAtIndex:a];
 
        [item.color setFill];
        
        [(_touchedItem == item ? _borderColorSelected : _borderColor) setStroke];
        
        item.rect = CGRectMake(x, bw05, width-bw05, self.bounds.size.height-_borderWidth);
        
        path = [UIBezierPath bezierPathWithRoundedRect:item.rect cornerRadius:7];
        path.lineWidth = _borderWidth;
        [path fill];
        [path stroke];
        
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        
        if ( item.percent > 0 ) {
            
            p1_width = width-rl_margin-_borderWidth;
            p2_width = p1_width * item.percent / 100;
            
            p_x=x+(p1_width-p2_width)/2 + rl_margin/2;
            
            CGContextMoveToPoint(context, p_x, _borderWidth * 1.5 + b_margin);
            CGContextAddLineToPoint(context, p_x+p2_width, _borderWidth * 1.5 + b_margin);
            CGContextStrokePath(context);
        }
        
        x+=width+_space+bw05;
        
    }
    

    
}

-(int)addItemWithColor:(UIColor *)color andPercent:(float)percent {
    
    _touchedItem = nil;
    SAColorListPickerItem *item = [[SAColorListPickerItem alloc] init];
    item.color = color;
    item.percent = percent;
    
    [items addObject:item];
    
    if ( initialized )
        [self setNeedsDisplay];

    return (int)items.count-1;
    
}

-(int)addItem {
    
    return [self addItemWithColor:[UIColor clearColor] andPercent:0];

}


-(void)removeItemAtIndex:(int)idx {
    
    if ( idx >= 0 && idx < items.count ) {
        _touchedItem = nil;
        [items removeObjectAtIndex:idx];
        
        if ( initialized )
            [self setNeedsDisplay];
    }
    
}

-(int)count {
    return (int)items.count;
}

-(UIColor*)itemColorAtIndex:(int) idx {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        return item.color;
    }
    
    return [UIColor clearColor];
};

-(void)itemAtIndex:(int) idx setColor:(UIColor*) color {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        item.color = color;
        
        if ( initialized )
            [self setNeedsDisplay];
    }
    
};

-(float)itemPercentAtIndex:(int) idx {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        return item.percent;
    }
    
    return 0;
};

-(void)itemAtIndex:(int) idx setPercent:(float) percent {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        item.percent = percent;
        
        if ( initialized )
            [self setNeedsDisplay];
    }
    
};

-(id)itemExtraParam1AtIndex:(int) idx {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        return item.extraParam1;
    }
    
    return nil;
}

-(void)itemAtIndex:(int) idx setExtraParam1:(id) param1 {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        item.extraParam1 = param1;
        
        if ( initialized )
            [self setNeedsDisplay];
    }
    
};

-(id)itemExtraParam2AtIndex:(int) idx {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        return item.extraParam2;
    }
    
    return nil;
}

-(void)itemAtIndex:(int) idx setExtraParam2:(id) param2 {
    
    if ( idx >= 0 && idx < items.count ) {
        SAColorListPickerItem *item = [items objectAtIndex:idx];
        item.extraParam2 = param2;
        
        if ( initialized )
            [self setNeedsDisplay];
    }
    
};


-(CGFloat)space {
    return _space;
}

-(void)setSpace:(CGFloat)space {
    _space = space;
    
    if ( initialized )
        [self setNeedsDisplay];
}

-(CGFloat)borderWidth {
    return _borderWidth;
}

-(void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    
    if ( initialized )
        [self setNeedsDisplay];
}

-(UIColor*)borderColor {
    return _borderColor;
}

-(void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    
    if ( initialized )
        [self setNeedsDisplay];
}

-(UIColor*)borderColorSelected {
    return _borderColorSelected;
}

-(void)setBorderColorSelected:(UIColor *)borderColorSelected {
    _borderColorSelected = borderColorSelected;
    
    if ( initialized )
        [self setNeedsDisplay];
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    
    switch(gr.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:

            if ( _touchedItem != nil && delegate != nil ) {
                
                
            }
            
            _touchedItem = nil;
            [self setNeedsDisplay];
            break;
            
        case UIGestureRecognizerStateBegan:
        {
            CGPoint touchPoint = [gr locationInView:self];
            for(int a=0;a<items.count;a++) {
                SAColorListPickerItem *item = [items objectAtIndex:a];
                
                if ( CGRectContainsPoint(item.rect, touchPoint) ) {
                    _touchedItem = item;
                    break;
                }
            }
            
            [self setNeedsDisplay];
        }
            
            break;
            default:
            break;
    }
    
}

-(void)longTouch:(id)_id {
    
    if ( _touchedItem != nil && delegate != nil ) {
        [delegate itemEditAtIndex:(int)[items indexOfObject:_touchedItem]];
    }
    
    _touchedItem = nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    for(int a=0;a<items.count;a++) {
        SAColorListPickerItem *item = [items objectAtIndex:a];
        
        if ( CGRectContainsPoint(item.rect, touchPoint) ) {
            _touchedItem = item;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longTouch:) object:nil];
            [self performSelector:@selector(longTouch:) withObject:nil afterDelay:1.5];
            break;
        }
    }
    
    [self setNeedsDisplay];
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ( _touchedItem != nil && delegate != nil ) {
        [delegate itemTouchedWithColor:_touchedItem.color andPercent:_touchedItem.percent];
    }
    
    _touchedItem = nil;
    [self setNeedsDisplay];
    
}

@end
