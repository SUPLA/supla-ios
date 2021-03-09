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

#import "SectionCell.h"
#import "SALocationCaptionEditor.h"

@implementation SASectionCell {
    UITapGestureRecognizer *_tap;
    UILongPressGestureRecognizer *_longPressGr;
}

@synthesize locationId;
@synthesize captionEditable;

- (void)initialize {
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        _tap.delegate = self;
        [self addGestureRecognizer:_tap];
        
        _longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        _longPressGr.allowableMovement = 5;

        _longPressGr.minimumPressDuration = 0.8;
        self.label.userInteractionEnabled = YES;
        [self.label addGestureRecognizer:_longPressGr];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)tapped:(UITapGestureRecognizer *)gr {
    if (self.delegate) {
        [self.delegate sectionCellTouch:self];
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)longPressGR {
    if (self.captionEditable && self.locationId && longPressGR.state == UIGestureRecognizerStateBegan) {
        [[SALocationCaptionEditor globalInstance] editCaptionWithRecordId:self.locationId];
    }
}
@end
