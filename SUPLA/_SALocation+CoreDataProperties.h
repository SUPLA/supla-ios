//
//  _SALocation+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "_SALocation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface _SALocation (CoreDataProperties)

+ (NSFetchRequest<_SALocation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *caption;
@property (nullable, nonatomic, copy) NSNumber *location_id;
@property (nullable, nonatomic, copy) NSNumber *visible;
@property (nullable, nonatomic, retain) SAAccessID *accessid;

@end

NS_ASSUME_NONNULL_END
