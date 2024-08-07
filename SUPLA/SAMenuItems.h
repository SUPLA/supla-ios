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


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SAMenuItemIds) {
    SAMenuItemIdSettings  = 1 << 0,
    SAMenuItemIdAddDevice  = 1 << 1,
    SAMenuItemIdZWave  = 1 << 2,
    SAMenuItemIdAbout  = 1 << 3,
    SAMenuItemIdHelp  = 1 << 5,
    SAMenuItemIdCloud  = 1 << 6,
    SAMenuItemIdHomepage  = 1 << 7,
    SAMenuItemIdNotifications  = 1 << 8,
    SAMenuItemIdDeviceCatalog  = 1 << 9,
    SAMenuItemIdProfile = 0x1000,
    SAMenuItemIdAll = 0xFFFF
};

@protocol SAMenuItemsDelegate <NSObject>
@required
-(void) menuItemTouched:(SAMenuItemIds)btnId;
@end

@interface SAMenuItems : UIView

- (void) slideDown:(BOOL)show withAction:(void (^)(void))action;
@property (weak, nonatomic) NSLayoutConstraint *menuBarHeight;
@property (nonatomic) SAMenuItemIds buttonsAvailable;
@property (readonly) NSString *homepageUrl;
@property(weak, nonatomic) id<SAMenuItemsDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
