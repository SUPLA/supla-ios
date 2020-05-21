//
//  SAElectricityMeasurementItem+CoreDataProperties.m
//  
//
//  Created by Przemek Zygmunt on 19/05/2020.
//
//

#import "SAElectricityMeasurementItem+CoreDataProperties.h"

@implementation SAElectricityMeasurementItem (CoreDataProperties)

+ (NSFetchRequest<SAElectricityMeasurementItem *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"SAElectricityMeasurementItem"];
}

@dynamic phase1_fae;
@dynamic phase1_fre;
@dynamic phase1_rae;
@dynamic phase1_rre;
@dynamic phase2_fae;
@dynamic phase2_fre;
@dynamic phase2_rae;
@dynamic phase2_rre;
@dynamic phase3_fae;
@dynamic phase3_fre;
@dynamic phase3_rae;
@dynamic phase3_rre;
@dynamic fae_balanced;
@dynamic rae_balanced;

@end
