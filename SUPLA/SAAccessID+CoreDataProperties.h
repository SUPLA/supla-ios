//
//  SAAccessID+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "SAAccessID+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SAAccessID (CoreDataProperties)

+ (NSFetchRequest<SAAccessID *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *access_id;
@property (nullable, nonatomic, copy) NSString *server_name;

@end

NS_ASSUME_NONNULL_END
