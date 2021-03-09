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
    NSTimer *_animDotsTimer;
    int pos;
}

+(SAPreloaderPopup*)globalInstance {
    if (_prograssPopupGlobalRef == nil) {
        _prograssPopupGlobalRef =
        [[SAPreloaderPopup alloc]
         initWithNibName:@"SAPreloaderPopup" bundle:nil];
    }
    
    return _prograssPopupGlobalRef;
}

- (IBAction)closeButtonTouch:(id)sender {
}

- (void)show {
    [SADialog showModal:self];
    pos = 4;
    [self enableAnimDotsTimer:YES];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self updateText];
}

-(void)updateText {
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
      initWithAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ....", _text]]];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:self.vMain.backgroundColor
                 range:NSMakeRange(_text.length+1+pos, 4-pos)];
    [self.lText setAttributedText: text];
}

-(void)enableAnimDotsTimer:(BOOL)enable {
    if (![SADialog viewControllerIsPresented:self]) {
        enable = NO;
    }
    
    if (_animDotsTimer) {
        [_animDotsTimer invalidate];
        _animDotsTimer = nil;
    }
    
    if (enable) {
        _animDotsTimer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                        target:self
                                                        selector:@selector(onTimer:)
                                                        userInfo:nil
                                                        repeats:YES];
    }
}

- (void)closeWithAnimation:(BOOL)animation completion:(void (^ __nullable)(void))completion {
    [self enableAnimDotsTimer:NO];
    [super closeWithAnimation:animation completion:completion];
}

-(void)onTimer:(NSTimer *)timer {
    [self updateText];
    
    pos++;
    if (pos > 4) {
        pos = 0;
    }
}

@end
