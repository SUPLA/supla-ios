//
//  SAChannel+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "SAChannel+CoreDataProperties.h"

@implementation SAChannel (CoreDataProperties)

+ (NSFetchRequest<SAChannel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SAChannel"];
}

@dynamic caption;
@dynamic channel_id;
@dynamic func;
@dynamic online;
@dynamic sub_value;
@dynamic value;
@dynamic visible;
@dynamic location;

@end
