//
//  SAColorListItem+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 03.11.2017.
//  Copyright © 2017 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//

#import "SAColorListItem+CoreDataProperties.h"

@implementation SAColorListItem (CoreDataProperties)

+ (NSFetchRequest<SAColorListItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SAColorListItem"];
}

@dynamic brightness;
@dynamic color;
@dynamic idx;
@dynamic channel;

@end
