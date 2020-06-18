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

#import "SAVLCalibrationTool.h"

@implementation SAVLCalibrationTool {
    SADetailView *_detailView;
}

-(void)startConfiguration:(SADetailView*)detailView {
    if (detailView == nil) {
        return;
    }
    
    [self removeFromSuperview];
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.frame = CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height);
    [detailView addSubview:self];
    [detailView bringSubviewToFront:self];
    _detailView = detailView;
}

-(void)dismiss {
    [self removeFromSuperview];
    _detailView = nil;
}

+(SAVLCalibrationTool*)newInstance {
    return [[[NSBundle mainBundle] loadNibNamed:@"SAVLCalibrationTool" owner:nil options:nil] objectAtIndex:0];
}

@end
