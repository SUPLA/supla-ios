//
//  SAAccessID+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemysław Zygmunt on 12.10.2015.
//  Copyright © 2015 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAAccessID.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAAccessID (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *access_id;
@property (nullable, nonatomic, retain) NSString *server_name;

@end

NS_ASSUME_NONNULL_END
