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

#import "SAPreloaderPopup.h"

@interface SAPreloaderPopup ()
@property (weak, nonatomic) IBOutlet UILabel *lText;

@end

static SAPreloaderPopup *_prograssPopupGlobalRef = nil;

@implementation SAPreloaderPopup {
    NSString *_text;
    BOOL _animatedDots;
    NSTimer *_animDotsTimer;
}

+(SAPreloaderPopup*)globalInstance {
    if (_prograssPopupGlobalRef == nil) {
        _prograssPopupGlobalRef =
        [[SAPreloaderPopup alloc]
         initWithNibName:@"SAProgressPopup" bundle:nil];
    }
    
    return _prograssPopupGlobalRef;
}

- (IBAction)closeButtonTouch:(id)sender {
}

- (void)show {
    [SADialog showModal:self];
    [self enableAnimDotsTimer:_animatedDots];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self textUpdate];
}

-(BOOL)animatedDots {
    return _animatedDots;
}

-(void)textUpdate {
   _lText.text = _text;
}

-(void)enableAnimDotsTimer:(BOOL)enable {
    if (![SADialog viewControllerIsPresented:self]) {
        enable = NO;
    }
}

- (void)closeWithAnimation:(BOOL)animation completion:(void (^ __nullable)(void))completion {
    [self enableAnimDotsTimer:NO];
    [super closeWithAnimation:animation completion:completion];
}

-(void)setAnimatedDots:(BOOL)animatedDots {
    _animatedDots = animatedDots;
    [self enableAnimDotsTimer:_animatedDots];
    [self textUpdate];
}

@end
