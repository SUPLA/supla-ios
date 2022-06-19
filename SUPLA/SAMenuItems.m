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

#import "SAMenuItems.h"
#import "SUPLA-Swift.h"
#import "UIColor+SUPLA.h"

#define SEPARATOR_HEIGHT 1
#define SHORT_SEPARATOR_LEFT_MARGIN 70
#define MENUITEM_HEIGHT 50
#define FOOTER_HEIGHT 45
#define IMAGE_SIZE 28
#define MENUITEM_TEXT_SIZE 16
#define HOMEPAGE_TEXT_SIZE 13
#define HOMEPAGE @"www.supla.org"

@implementation SAMenuItems {
    short _btnCount;
    SAMenuItemIds _buttonsAvailable;
    BOOL _buttonsAdded;
}

@synthesize menuBarHeight;
@synthesize delegate;

- (void)menuItemsInit {
    _btnCount = 0;
    self.backgroundColor = [UIColor mainMenuColor];
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (id)init {
    self = [super init];
    if (self) {
        [self menuItemsInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self menuItemsInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self menuItemsInit];
    }
    return self;
}

- (SAMenuItemIds)buttonsAvailable {
    return _buttonsAvailable;
}


-(void)addBtnWithId:(int)btnId imageNamed:(NSString *)imgName text:(NSString *)text {
    
    if (!(_buttonsAvailable & btnId)) {
        return;
    }
    
    CGFloat top = _btnCount * (MENUITEM_HEIGHT+SEPARATOR_HEIGHT);
    
    CGFloat separatorMargin = _btnCount ? SHORT_SEPARATOR_LEFT_MARGIN : 0;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(separatorMargin,
                                                                 top,
                                                                 self.frame.size.width-separatorMargin,
                                                                 SEPARATOR_HEIGHT)];
    separator.backgroundColor = [UIColor menuSeparatorColor];
    [self addSubview:separator];
    UIButton *btn = [[UIButton alloc] initWithFrame:
                         CGRectMake(SHORT_SEPARATOR_LEFT_MARGIN / 2 - IMAGE_SIZE / 2,
                                    top+SEPARATOR_HEIGHT+MENUITEM_HEIGHT/2-IMAGE_SIZE/2,
                                    IMAGE_SIZE,
                                    IMAGE_SIZE)];
    UIImage *image = [UIImage imageNamed:imgName];
    btn.tag = btnId;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onButtonTouch:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:
                         CGRectMake(SHORT_SEPARATOR_LEFT_MARGIN,
                                    top+SEPARATOR_HEIGHT,
                                    self.frame.size.width-SHORT_SEPARATOR_LEFT_MARGIN,
                                    MENUITEM_HEIGHT)];
    btn.tag = btnId;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitle:[NSLocalizedString(text, nil) uppercaseString] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"OpenSans" size: MENUITEM_TEXT_SIZE];
    [btn addTarget:self action:@selector(onButtonTouch:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
    _btnCount++;
}

-(CGFloat)recreateButtons {
    
    while(self.subviews.count) {
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    }
        
    _btnCount = 0;

    id<ProfileManager> pm = [SAApp profileManager];
    NSString *accountLabel;
    if([[pm getAllProfiles] count] > 1) {
        accountLabel = @"Your accounts";
    } else {
        accountLabel = @"Your account";
    }
    
    [self addBtnWithId:SAMenuItemIdProfile imageNamed:@"profile" text:accountLabel];
    [self addBtnWithId:SAMenuItemIdSettings imageNamed:@"settings" text:@"Settings"];
    [self addBtnWithId:SAMenuItemIdAddDevice imageNamed:@"add_device" text:@"Add I/O device"];
    [self addBtnWithId:SAMenuItemIdZWave imageNamed:@"z_wave_btn" text:@"Z-Wave bridge"];
    [self addBtnWithId:SAMenuItemIdAbout imageNamed:@"info" text:@"About"];
    // Apple Play Policy
    // [self addBtnWithId:SAMenuItemIdDonate imageNamed:@"donate" text:@"Donate"];
    [self addBtnWithId:SAMenuItemIdHelp imageNamed:@"help" text:@"Help"];
    [self addBtnWithId:SAMenuItemIdCloud imageNamed:@"menu_cloud" text:@"Supla Cloud"];
  
    CGFloat top = _btnCount * (MENUITEM_HEIGHT+SEPARATOR_HEIGHT);
    CGFloat height = top;

    if (_buttonsAvailable & SAMenuItemIdHomepage) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     top,
                                                                     self.frame.size.width,
                                                                     SEPARATOR_HEIGHT)];
        separator.backgroundColor = [UIColor menuSeparatorColor];
        [self addSubview:separator];
        
        
        UIButton *btn = [[UIButton alloc] initWithFrame:
                             CGRectMake(0,
                                        top+SEPARATOR_HEIGHT,
                                        self.frame.size.width,
                                        FOOTER_HEIGHT)];
        btn.tag = SAMenuItemIdHomepage;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn setTitle:HOMEPAGE forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size: HOMEPAGE_TEXT_SIZE];
        [btn addTarget:self action:@selector(onButtonTouch:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:btn];
        
        height+=SEPARATOR_HEIGHT+FOOTER_HEIGHT;
    }
    
    _buttonsAdded = YES;
    return height;
}

-(void)setButtonsAvailable:(SAMenuItemIds)buttonsAvailable {
    if (_buttonsAvailable != buttonsAvailable) {
        _buttonsAvailable = buttonsAvailable;
        _buttonsAdded = NO;
    }
}

- (void) slideDown:(BOOL)show withAction:(void (^)(void))action {
    
    if (!self.superview) {
        return;
    }
    
    self.hidden = NO;
    CGFloat height = self.frame.size.height;
    CGFloat top = self.menuBarHeight ? self.menuBarHeight.constant : 0;
   
    self.frame = CGRectMake(0,
                            show ? top * -1 : top,
                            self.superview.frame.size.width, height);
    if (!_buttonsAdded) {
        height = [self recreateButtons];
    }
    
    if (height != self.frame.size.height) {
        self.frame = CGRectMake(0,
                                show ? top * -1 : top,
                                self.superview.frame.size.width, height);
    }
       
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0,
                                show ? top : top * -1,
                                self.superview.frame.size.width, height);
    } completion:^(BOOL finished) {
        if ( show ) {
            [self.superview bringSubviewToFront:self];
        } else {
            self.hidden = YES;
        }
        
        if ( action != nil ) {
            action();
        }
    }];
}

-(NSString*)homepageUrl {
    return [NSString stringWithFormat:@"https://%@", HOMEPAGE];
}

-(void)onButtonTouch:(id)sender {
    if ([sender isKindOfClass:[UIButton class]] && delegate) {
        [delegate menuItemTouched:((UIButton*)sender).tag];
    }
}

@end
