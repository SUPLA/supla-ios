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

#import "SAWizardVC.h"
#import "SAClassHelper.h"
#import "SuplaApp.h"

@interface SAWizardVC ()

@end

@implementation SAWizardVC {
    NSTimer *_preloaderTimer;
    int _preloaderPos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showPageView:(UIView*)pageView {
    for(UIView *subview in self.vPageContent.subviews) {
        [subview removeFromSuperview];
    }
    
    pageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    pageView.frame =  self.vPageContent.frame;
    
    [self.vPageContent addSubview: pageView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SAApp UI] showMenuBtn:NO];
}

-(void)viewDidDisappear:(BOOL)animated  {
    [super viewDidDisappear:animated];
    [self preloaderVisible:NO];
}

-(void)btnNextEnabled:(BOOL)enabled {
    self.btnNext1.enabled = enabled;
    self.btnNext2.enabled = enabled;
    self.btnNext3.enabled = enabled;
}

- (void)preloaderTimerFireMethod:(NSTimer *)timer {
    
    if ( _preloaderPos == -1 ) {
        return;
    }
    
    NSString *str = @"";
    
    for(int a=0;a<10;a++) {
        str = [NSString stringWithFormat:@"%@%@", str, _preloaderPos == a ? @"|" : @"."];
    }
    
    _preloaderPos++;
    if ( _preloaderPos > 9 ) {
        _preloaderPos = 0;
    }
    
    [self.btnNext2 setAttributedTitle:str];
    
}

-(void)preloaderVisible:(BOOL)visible {
    
    if ( _preloaderTimer ) {
        _preloaderPos = -1;
        [_preloaderTimer invalidate];
        _preloaderTimer = nil;
    }
    
    if ( visible ) {
        
        _preloaderPos = 0;
        
        _btnNext3_width.constant = 17;
        [self.btnNext3 setBackgroundImage:[UIImage imageNamed:@"btnnextr2.png"]];
        
         _preloaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(preloaderTimerFireMethod:) userInfo:nil repeats:YES];
        
    } else {
        
        _btnNext3_width.constant = 40;
        [self.btnNext3 setBackgroundImage:[UIImage imageNamed:@"btnnextr.png"]];
        [self.btnNext2 setAttributedTitle:NSLocalizedString(@"Next", NULL)];
        
    }
    
}

- (IBAction)nextTouch:(nullable id)sender {}

- (IBAction)cancelTouch:(nullable id)sender {}


@end
