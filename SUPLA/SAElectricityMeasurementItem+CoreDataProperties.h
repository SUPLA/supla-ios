//
//  SAElectricityMeasurementItem+CoreDataProperties.h
//  
//
//  Created by Przemek Zygmunt on 19/05/2020.
//
//

#import "SAElectricityMeasurementItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SAElectricityMeasurementItem (CoreDataProperties)

+ (NSFetchRequest<SAElectricityMeasurementItem *> *)fetchRequest;

@property (nonatomic) double phase1_fae;
@property (nonatomic) double phase1_fre;
@property (nonatomic) double phase1_rae;
@property (nonatomic) double phase1_rre;
@property (nonatomic) double phase2_fae;
@property (nonatomic) double phase2_fre;
@property (nonatomic) double phase2_rae;
@property (nonatomic) double phase2_rre;
@property (nonatomic) double phase3_fae;
@property (nonatomic) double phase3_fre;
@property (nonatomic) double phase3_rae;
@property (nonatomic) double phase3_rre;
@property (nonatomic) double fae_balanced;
@property (nonatomic) double rae_balanced;

@end

NS_ASSUME_NONNULL_END
