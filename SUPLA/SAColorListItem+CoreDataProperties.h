//
//  SAColorListItem+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemysław Zygmunt on 03.11.2017.
//  Copyright © 2017 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//

#import "SAColorListItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SAColorListItem (CoreDataProperties)

+ (NSFetchRequest<SAColorListItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *brightness;
@property (nullable, nonatomic, retain) NSObject *color;
@property (nullable, nonatomic, copy) NSNumber *idx;
@property (nullable, nonatomic, retain) SAChannel *channel;

@end

NS_ASSUME_NONNULL_END
