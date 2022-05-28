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

#import "SADialog.h"
#import "SUPLA-Swift.h"

@interface SADialog ()
- (IBAction)closeButtonTouch:(id)sender;
@end

@implementation SADialog {
    UITapGestureRecognizer *_tapGr;
}

@synthesize cancelByTouchOutside;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.cancelByTouchOutside = YES;
        _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTouch:)];
        [self.view addGestureRecognizer:_tapGr];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.alpha = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    } completion:nil];
     
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView*)rootView {
    return self.view;
}

-(void)closeWithAnimation:(BOOL)animation completion:(void (^ __nullable)(void))completion {
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished){
            [self dismissViewControllerAnimated:NO completion:^() {
                if (completion) {
                    completion();
                }
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:^() {
            if (completion) {
                completion();
            }
        }];
    }
}

- (IBAction)closeButtonTouch:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.cancelByTouchOutside == NO) {
            return;
        }
        
        UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
        
        if ([self.rootView hitTest:[gr locationInView:self.rootView] withEvent:nil] != self.rootView) {
          return;
        }
    }
    
    [self closeWithAnimation:YES completion:nil];
    
}

- (void)close {
    [self closeWithAnimation:YES completion:nil];
}

+ (BOOL)viewControllerIsPresented:(UIViewController*)vc {
    UIViewController *rootVC = [SAApp currentNavigationCoordinator].viewController;
    return vc != nil && rootVC != nil && rootVC.presentedViewController == vc;
}

+ (void)showModal:(SADialog*)dialogVC {
    UIViewController *rootVC = [SAApp currentNavigationCoordinator].viewController;
    dialogVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (@available(iOS 13.0, *)) {
        dialogVC.modalInPresentation = YES;
        [rootVC presentViewController:dialogVC animated:NO completion:nil];
    } else {
        [rootVC presentModalViewController:dialogVC animated:NO];
    }
}

- (void)keyboardDidShow:(NSNotification*)notification {
    if (self.vMain == nil) {
        return;
    }
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (self.vMain.frame.origin.y+self.vMain.frame.size.height > self.view.frame.size.height - keyboardSize.height) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.vMain.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - keyboardSize.height - (self.vMain.frame.origin.y+self.vMain.frame.size.height+50) );
        }];
    }
}

- (void)keyboardDidHide:(NSNotification*)notification {
    if (self.vMain != nil) {
        [UIView animateWithDuration:0.2 animations:^{
            self.vMain.transform = CGAffineTransformIdentity;
        }];
    }
}

@end
