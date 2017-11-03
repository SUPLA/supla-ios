//
//  SAChannel+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 03.11.2017.
//  Copyright © 2017 AC SOFTWARE SP. Z O.O. All rights reserved.
//
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
@dynamic alticon;
@dynamic flags;
@dynamic protocolversion;
@dynamic location;

@end
