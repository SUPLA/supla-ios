//
//  SAChannelExtendedValue+CoreDataProperties.m
//  SUPLA
//
//  Created by Przemek Zygmunt on 19/06/2019.
//  Copyright © 2019 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//

#import "SAChannelExtendedValue+CoreDataProperties.h"

@implementation SAChannelExtendedValue (CoreDataProperties)

+ (NSFetchRequest<SAChannelExtendedValue *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SAChannelExtendedValue"];
}

@dynamic content;
@dynamic type;
@dynamic channel_id;

@end
