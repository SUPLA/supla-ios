//
//  SARollerShutter.h
//  RSTest
//
//  Created by Przemysław Zygmunt on 26.07.2017.
//  Copyright © 2017 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SARollerShutterDelegate <NSObject>

@required
-(void) rsChangeing:(id)rs withPercent:(float)percent;
-(void) rsChanged:(id)rs withPercent:(float)percent;

@end

@interface SARollerShutter : UIView


@property(weak, nonatomic) UIColor *windowColor;
@property(weak, nonatomic) UIColor *sunColor;
@property(nonatomic, assign) CGFloat frameLineWidth;
@property(nonatomic, assign) CGFloat spaceing;
@property(nonatomic, assign) CGFloat louverSpaceing;
@property(nonatomic, assign) short louverCount;
@property(nonatomic, assign) float percent;
@property(nonatomic, assign) BOOL gestureEnabled;

@property(weak, nonatomic) id<SARollerShutterDelegate> delegate;

@end
