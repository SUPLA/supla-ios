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
#import "SADownloadUserIcons.h"
#import "SectionCell.h"
#import "BaseViewController.h"

@class SADetailView;

@interface SAMainVC : BaseViewController <UITableViewDataSource, UITableViewDelegate, SARestApiClientTaskDelegate, SASectionCellDelegate, UITableViewDragDelegate, UITableViewDropDelegate>


- (IBAction)settingsTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *cTableView;
@property (weak, nonatomic) IBOutlet UITableView *gTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationBottom;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIImageView *notificationImage;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (readonly,nonatomic) id<UIViewControllerInteractiveTransitioning> interactionController;

- (void)detailHide;
- (void)groupTableHidden:(BOOL)hidden;
- (void)reloadTables;
@end


@interface SAMainView : UIView 
@property (weak, nonatomic) SAMainVC *viewController;
@property (weak, nonatomic) IBOutlet UITableView *cTableView;
@property (weak, nonatomic) IBOutlet UITableView *gTableView;
@property (weak, nonatomic, readonly) SADetailView *detailView;
@property (readonly,nonatomic) id<UIViewControllerInteractiveTransitioning> panController;

- (void)detailDidHide;
- (void)moveCenter:(float)x_offset;

@end
