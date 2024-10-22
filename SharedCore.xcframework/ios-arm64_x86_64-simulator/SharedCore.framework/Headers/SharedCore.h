#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class SharedCoreKotlinEnumCompanion, SharedCoreKotlinEnum<E>, SharedCoreSuplaChannelFunctionCompanion, SharedCoreSuplaChannelFunction, SharedCoreKotlinArray<T>, SharedCoreLocalizedString;

@protocol SharedCoreKotlinComparable, SharedCoreKotlinIterator;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface SharedCoreBase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface SharedCoreBase (SharedCoreBaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface SharedCoreMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface SharedCoreMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorSharedCoreKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface SharedCoreNumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface SharedCoreByte : SharedCoreNumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface SharedCoreUByte : SharedCoreNumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface SharedCoreShort : SharedCoreNumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface SharedCoreUShort : SharedCoreNumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface SharedCoreInt : SharedCoreNumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface SharedCoreUInt : SharedCoreNumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface SharedCoreLong : SharedCoreNumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface SharedCoreULong : SharedCoreNumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface SharedCoreFloat : SharedCoreNumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface SharedCoreDouble : SharedCoreNumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface SharedCoreBoolean : SharedCoreNumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((swift_name("KotlinComparable")))
@protocol SharedCoreKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface SharedCoreKotlinEnum<E> : SharedCoreBase <SharedCoreKotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedCoreKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunction")))
@interface SharedCoreSuplaChannelFunction : SharedCoreKotlinEnum<SharedCoreSuplaChannelFunction *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) SharedCoreSuplaChannelFunctionCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaChannelFunction *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) SharedCoreSuplaChannelFunction *none __attribute__((swift_name("none")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheGatewayLock __attribute__((swift_name("controllingTheGatewayLock")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheGate __attribute__((swift_name("controllingTheGate")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheGarageDoor __attribute__((swift_name("controllingTheGarageDoor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *thermometer __attribute__((swift_name("thermometer")));
@property (class, readonly) SharedCoreSuplaChannelFunction *humidity __attribute__((swift_name("humidity")));
@property (class, readonly) SharedCoreSuplaChannelFunction *humidityAndTemperature __attribute__((swift_name("humidityAndTemperature")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorGateway __attribute__((swift_name("openSensorGateway")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorGate __attribute__((swift_name("openSensorGate")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorGarageDoor __attribute__((swift_name("openSensorGarageDoor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *noLiquidSensor __attribute__((swift_name("noLiquidSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheDoorLock __attribute__((swift_name("controllingTheDoorLock")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorDoor __attribute__((swift_name("openSensorDoor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheRollerShutter __attribute__((swift_name("controllingTheRollerShutter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheRoofWindow __attribute__((swift_name("controllingTheRoofWindow")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorRollerShutter __attribute__((swift_name("openSensorRollerShutter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openSensorRoofWindow __attribute__((swift_name("openSensorRoofWindow")));
@property (class, readonly) SharedCoreSuplaChannelFunction *powerSwitch __attribute__((swift_name("powerSwitch")));
@property (class, readonly) SharedCoreSuplaChannelFunction *lightswitch __attribute__((swift_name("lightswitch")));
@property (class, readonly) SharedCoreSuplaChannelFunction *ring __attribute__((swift_name("ring")));
@property (class, readonly) SharedCoreSuplaChannelFunction *alarm __attribute__((swift_name("alarm")));
@property (class, readonly) SharedCoreSuplaChannelFunction *notification __attribute__((swift_name("notification")));
@property (class, readonly) SharedCoreSuplaChannelFunction *dimmer __attribute__((swift_name("dimmer")));
@property (class, readonly) SharedCoreSuplaChannelFunction *rgbLighting __attribute__((swift_name("rgbLighting")));
@property (class, readonly) SharedCoreSuplaChannelFunction *dimmerAndRgbLighting __attribute__((swift_name("dimmerAndRgbLighting")));
@property (class, readonly) SharedCoreSuplaChannelFunction *depthSensor __attribute__((swift_name("depthSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *distanceSensor __attribute__((swift_name("distanceSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *openingSensorWindow __attribute__((swift_name("openingSensorWindow")));
@property (class, readonly) SharedCoreSuplaChannelFunction *hotelCardSensor __attribute__((swift_name("hotelCardSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *alarmArmamentSensor __attribute__((swift_name("alarmArmamentSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *mailSensor __attribute__((swift_name("mailSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *windSensor __attribute__((swift_name("windSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *pressureSensor __attribute__((swift_name("pressureSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *rainSensor __attribute__((swift_name("rainSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *weightSensor __attribute__((swift_name("weightSensor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *weatherStation __attribute__((swift_name("weatherStation")));
@property (class, readonly) SharedCoreSuplaChannelFunction *staircaseTimer __attribute__((swift_name("staircaseTimer")));
@property (class, readonly) SharedCoreSuplaChannelFunction *electricityMeter __attribute__((swift_name("electricityMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *icElectricityMeter __attribute__((swift_name("icElectricityMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *icGasMeter __attribute__((swift_name("icGasMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *icWaterMeter __attribute__((swift_name("icWaterMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *icHeatMeter __attribute__((swift_name("icHeatMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *thermostatHeatpolHomeplus __attribute__((swift_name("thermostatHeatpolHomeplus")));
@property (class, readonly) SharedCoreSuplaChannelFunction *hvacThermostat __attribute__((swift_name("hvacThermostat")));
@property (class, readonly) SharedCoreSuplaChannelFunction *hvacThermostatHeatCool __attribute__((swift_name("hvacThermostatHeatCool")));
@property (class, readonly) SharedCoreSuplaChannelFunction *hvacDomesticHotWater __attribute__((swift_name("hvacDomesticHotWater")));
@property (class, readonly) SharedCoreSuplaChannelFunction *valveOpenClose __attribute__((swift_name("valveOpenClose")));
@property (class, readonly) SharedCoreSuplaChannelFunction *valvePercentage __attribute__((swift_name("valvePercentage")));
@property (class, readonly) SharedCoreSuplaChannelFunction *generalPurposeMeasurement __attribute__((swift_name("generalPurposeMeasurement")));
@property (class, readonly) SharedCoreSuplaChannelFunction *generalPurposeMeter __attribute__((swift_name("generalPurposeMeter")));
@property (class, readonly) SharedCoreSuplaChannelFunction *digiglassHorizontal __attribute__((swift_name("digiglassHorizontal")));
@property (class, readonly) SharedCoreSuplaChannelFunction *digiglassVertical __attribute__((swift_name("digiglassVertical")));
@property (class, readonly) SharedCoreSuplaChannelFunction *controllingTheFacadeBlind __attribute__((swift_name("controllingTheFacadeBlind")));
@property (class, readonly) SharedCoreSuplaChannelFunction *terraceAwning __attribute__((swift_name("terraceAwning")));
@property (class, readonly) SharedCoreSuplaChannelFunction *projectorScreen __attribute__((swift_name("projectorScreen")));
@property (class, readonly) SharedCoreSuplaChannelFunction *curtain __attribute__((swift_name("curtain")));
@property (class, readonly) SharedCoreSuplaChannelFunction *verticalBlind __attribute__((swift_name("verticalBlind")));
@property (class, readonly) SharedCoreSuplaChannelFunction *rollerGarageDoor __attribute__((swift_name("rollerGarageDoor")));
@property (class, readonly) SharedCoreSuplaChannelFunction *pumpSwitch __attribute__((swift_name("pumpSwitch")));
@property (class, readonly) SharedCoreSuplaChannelFunction *heatOrColdSourceSwitch __attribute__((swift_name("heatOrColdSourceSwitch")));
+ (SharedCoreKotlinArray<SharedCoreSuplaChannelFunction *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<SharedCoreSuplaChannelFunction *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunction.Companion")))
@interface SharedCoreSuplaChannelFunctionCompanion : SharedCoreBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedCoreSuplaChannelFunctionCompanion *shared __attribute__((swift_name("shared")));
- (SharedCoreSuplaChannelFunction *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedString")))
@interface SharedCoreLocalizedString : SharedCoreKotlinEnum<SharedCoreLocalizedString *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) SharedCoreLocalizedString *generalTurnOn __attribute__((swift_name("generalTurnOn")));
@property (class, readonly) SharedCoreLocalizedString *generalTurnOff __attribute__((swift_name("generalTurnOff")));
@property (class, readonly) SharedCoreLocalizedString *generalOpen __attribute__((swift_name("generalOpen")));
@property (class, readonly) SharedCoreLocalizedString *generalClose __attribute__((swift_name("generalClose")));
@property (class, readonly) SharedCoreLocalizedString *generalShut __attribute__((swift_name("generalShut")));
@property (class, readonly) SharedCoreLocalizedString *generalReveal __attribute__((swift_name("generalReveal")));
@property (class, readonly) SharedCoreLocalizedString *generalCollapse __attribute__((swift_name("generalCollapse")));
@property (class, readonly) SharedCoreLocalizedString *generalExpand __attribute__((swift_name("generalExpand")));
+ (SharedCoreKotlinArray<SharedCoreLocalizedString *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<SharedCoreLocalizedString *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelActionStringUseCase")))
@interface SharedCoreGetChannelActionStringUseCase : SharedCoreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreLocalizedString * _Nullable)leftButtonFunction:(SharedCoreSuplaChannelFunction *)function __attribute__((swift_name("leftButton(function:)")));
- (SharedCoreLocalizedString * _Nullable)rightButtonFunction:(SharedCoreSuplaChannelFunction *)function __attribute__((swift_name("rightButton(function:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunctionKt")))
@interface SharedCoreSuplaChannelFunctionKt : SharedCoreBase
+ (SharedCoreSuplaChannelFunction *)suplaFunction:(int32_t)receiver __attribute__((swift_name("suplaFunction(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface SharedCoreKotlinEnumCompanion : SharedCoreBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedCoreKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface SharedCoreKotlinArray<T> : SharedCoreBase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(SharedCoreInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<SharedCoreKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol SharedCoreKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
