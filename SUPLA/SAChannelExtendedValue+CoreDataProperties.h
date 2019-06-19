//
//  SAChannelExtendedValue+CoreDataProperties.h
//  SUPLA
//
//  Created by Przemek Zygmunt on 19/06/2019.
//  Copyright © 2019 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//

#import "SAChannelExtendedValue+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SAChannelExtendedValue (CoreDataProperties)

+ (NSFetchRequest<SAChannelExtendedValue *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *content;
@property (nonatomic) int32_t type;
@property (nonatomic) int32_t channel_id;

@end

NS_ASSUME_NONNULL_END
