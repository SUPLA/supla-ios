//
//  SAAccessID+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "SAAccessID+CoreDataProperties.h"

@implementation SAAccessID (CoreDataProperties)

+ (NSFetchRequest<SAAccessID *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SAAccessID"];
}

@dynamic access_id;
@dynamic server_name;

@end
