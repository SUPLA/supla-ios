//
//  SAChannel+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemysław Zygmunt on 12.10.2015.
//  Copyright © 2015 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAChannel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSNumber *channel_id;
@property (nullable, nonatomic, retain) NSNumber *func;
@property (nullable, nonatomic, retain) NSNumber *online;
@property (nullable, nonatomic, retain) id sub_value;
@property (nullable, nonatomic, retain) id value;
@property (nullable, nonatomic, retain) NSNumber *visible;
@property (nullable, nonatomic, retain) SALocation *location;

@end

NS_ASSUME_NONNULL_END
