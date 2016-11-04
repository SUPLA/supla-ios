//
//  _SALocation+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemysław Zygmunt on 02.11.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "_SALocation+CoreDataProperties.h"

@implementation _SALocation (CoreDataProperties)

+ (NSFetchRequest<_SALocation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SALocation"];
}

@dynamic caption;
@dynamic location_id;
@dynamic visible;
@dynamic accessid;

@end
