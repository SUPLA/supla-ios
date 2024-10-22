#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class Shared_coreKotlinEnumCompanion, Shared_coreKotlinEnum<E>, Shared_coreSuplaChannelFunctionCompanion, Shared_coreSuplaChannelFunction, Shared_coreKotlinArray<T>, Shared_coreLocalizedString;

@protocol Shared_coreKotlinComparable, Shared_coreKotlinIterator;

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
@interface Shared_coreBase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface Shared_coreBase (Shared_coreBaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface Shared_coreMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface Shared_coreMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorShared_coreKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface Shared_coreNumber : NSNumber
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
@interface Shared_coreByte : Shared_coreNumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface Shared_coreUByte : Shared_coreNumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface Shared_coreShort : Shared_coreNumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface Shared_coreUShort : Shared_coreNumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface Shared_coreInt : Shared_coreNumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface Shared_coreUInt : Shared_coreNumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface Shared_coreLong : Shared_coreNumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface Shared_coreULong : Shared_coreNumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface Shared_coreFloat : Shared_coreNumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface Shared_coreDouble : Shared_coreNumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface Shared_coreBoolean : Shared_coreNumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((swift_name("KotlinComparable")))
@protocol Shared_coreKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface Shared_coreKotlinEnum<E> : Shared_coreBase <Shared_coreKotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) Shared_coreKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunction")))
@interface Shared_coreSuplaChannelFunction : Shared_coreKotlinEnum<Shared_coreSuplaChannelFunction *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) Shared_coreSuplaChannelFunctionCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) Shared_coreSuplaChannelFunction *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) Shared_coreSuplaChannelFunction *none __attribute__((swift_name("none")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheGatewayLock __attribute__((swift_name("controllingTheGatewayLock")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheGate __attribute__((swift_name("controllingTheGate")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheGarageDoor __attribute__((swift_name("controllingTheGarageDoor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *thermometer __attribute__((swift_name("thermometer")));
@property (class, readonly) Shared_coreSuplaChannelFunction *humidity __attribute__((swift_name("humidity")));
@property (class, readonly) Shared_coreSuplaChannelFunction *humidityAndTemperature __attribute__((swift_name("humidityAndTemperature")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorGateway __attribute__((swift_name("openSensorGateway")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorGate __attribute__((swift_name("openSensorGate")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorGarageDoor __attribute__((swift_name("openSensorGarageDoor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *noLiquidSensor __attribute__((swift_name("noLiquidSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheDoorLock __attribute__((swift_name("controllingTheDoorLock")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorDoor __attribute__((swift_name("openSensorDoor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheRollerShutter __attribute__((swift_name("controllingTheRollerShutter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheRoofWindow __attribute__((swift_name("controllingTheRoofWindow")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorRollerShutter __attribute__((swift_name("openSensorRollerShutter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openSensorRoofWindow __attribute__((swift_name("openSensorRoofWindow")));
@property (class, readonly) Shared_coreSuplaChannelFunction *powerSwitch __attribute__((swift_name("powerSwitch")));
@property (class, readonly) Shared_coreSuplaChannelFunction *lightswitch __attribute__((swift_name("lightswitch")));
@property (class, readonly) Shared_coreSuplaChannelFunction *ring __attribute__((swift_name("ring")));
@property (class, readonly) Shared_coreSuplaChannelFunction *alarm __attribute__((swift_name("alarm")));
@property (class, readonly) Shared_coreSuplaChannelFunction *notification __attribute__((swift_name("notification")));
@property (class, readonly) Shared_coreSuplaChannelFunction *dimmer __attribute__((swift_name("dimmer")));
@property (class, readonly) Shared_coreSuplaChannelFunction *rgbLighting __attribute__((swift_name("rgbLighting")));
@property (class, readonly) Shared_coreSuplaChannelFunction *dimmerAndRgbLighting __attribute__((swift_name("dimmerAndRgbLighting")));
@property (class, readonly) Shared_coreSuplaChannelFunction *depthSensor __attribute__((swift_name("depthSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *distanceSensor __attribute__((swift_name("distanceSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *openingSensorWindow __attribute__((swift_name("openingSensorWindow")));
@property (class, readonly) Shared_coreSuplaChannelFunction *hotelCardSensor __attribute__((swift_name("hotelCardSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *alarmArmamentSensor __attribute__((swift_name("alarmArmamentSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *mailSensor __attribute__((swift_name("mailSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *windSensor __attribute__((swift_name("windSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *pressureSensor __attribute__((swift_name("pressureSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *rainSensor __attribute__((swift_name("rainSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *weightSensor __attribute__((swift_name("weightSensor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *weatherStation __attribute__((swift_name("weatherStation")));
@property (class, readonly) Shared_coreSuplaChannelFunction *staircaseTimer __attribute__((swift_name("staircaseTimer")));
@property (class, readonly) Shared_coreSuplaChannelFunction *electricityMeter __attribute__((swift_name("electricityMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *icElectricityMeter __attribute__((swift_name("icElectricityMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *icGasMeter __attribute__((swift_name("icGasMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *icWaterMeter __attribute__((swift_name("icWaterMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *icHeatMeter __attribute__((swift_name("icHeatMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *thermostatHeatpolHomeplus __attribute__((swift_name("thermostatHeatpolHomeplus")));
@property (class, readonly) Shared_coreSuplaChannelFunction *hvacThermostat __attribute__((swift_name("hvacThermostat")));
@property (class, readonly) Shared_coreSuplaChannelFunction *hvacThermostatHeatCool __attribute__((swift_name("hvacThermostatHeatCool")));
@property (class, readonly) Shared_coreSuplaChannelFunction *hvacDomesticHotWater __attribute__((swift_name("hvacDomesticHotWater")));
@property (class, readonly) Shared_coreSuplaChannelFunction *valveOpenClose __attribute__((swift_name("valveOpenClose")));
@property (class, readonly) Shared_coreSuplaChannelFunction *valvePercentage __attribute__((swift_name("valvePercentage")));
@property (class, readonly) Shared_coreSuplaChannelFunction *generalPurposeMeasurement __attribute__((swift_name("generalPurposeMeasurement")));
@property (class, readonly) Shared_coreSuplaChannelFunction *generalPurposeMeter __attribute__((swift_name("generalPurposeMeter")));
@property (class, readonly) Shared_coreSuplaChannelFunction *digiglassHorizontal __attribute__((swift_name("digiglassHorizontal")));
@property (class, readonly) Shared_coreSuplaChannelFunction *digiglassVertical __attribute__((swift_name("digiglassVertical")));
@property (class, readonly) Shared_coreSuplaChannelFunction *controllingTheFacadeBlind __attribute__((swift_name("controllingTheFacadeBlind")));
@property (class, readonly) Shared_coreSuplaChannelFunction *terraceAwning __attribute__((swift_name("terraceAwning")));
@property (class, readonly) Shared_coreSuplaChannelFunction *projectorScreen __attribute__((swift_name("projectorScreen")));
@property (class, readonly) Shared_coreSuplaChannelFunction *curtain __attribute__((swift_name("curtain")));
@property (class, readonly) Shared_coreSuplaChannelFunction *verticalBlind __attribute__((swift_name("verticalBlind")));
@property (class, readonly) Shared_coreSuplaChannelFunction *rollerGarageDoor __attribute__((swift_name("rollerGarageDoor")));
@property (class, readonly) Shared_coreSuplaChannelFunction *pumpSwitch __attribute__((swift_name("pumpSwitch")));
@property (class, readonly) Shared_coreSuplaChannelFunction *heatOrColdSourceSwitch __attribute__((swift_name("heatOrColdSourceSwitch")));
+ (Shared_coreKotlinArray<Shared_coreSuplaChannelFunction *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<Shared_coreSuplaChannelFunction *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunction.Companion")))
@interface Shared_coreSuplaChannelFunctionCompanion : Shared_coreBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) Shared_coreSuplaChannelFunctionCompanion *shared __attribute__((swift_name("shared")));
- (Shared_coreSuplaChannelFunction *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedString")))
@interface Shared_coreLocalizedString : Shared_coreKotlinEnum<Shared_coreLocalizedString *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) Shared_coreLocalizedString *generalTurnOn __attribute__((swift_name("generalTurnOn")));
@property (class, readonly) Shared_coreLocalizedString *generalTurnOff __attribute__((swift_name("generalTurnOff")));
@property (class, readonly) Shared_coreLocalizedString *generalOpen __attribute__((swift_name("generalOpen")));
@property (class, readonly) Shared_coreLocalizedString *generalClose __attribute__((swift_name("generalClose")));
@property (class, readonly) Shared_coreLocalizedString *generalShut __attribute__((swift_name("generalShut")));
@property (class, readonly) Shared_coreLocalizedString *generalReveal __attribute__((swift_name("generalReveal")));
@property (class, readonly) Shared_coreLocalizedString *generalCollapse __attribute__((swift_name("generalCollapse")));
@property (class, readonly) Shared_coreLocalizedString *generalExpand __attribute__((swift_name("generalExpand")));
+ (Shared_coreKotlinArray<Shared_coreLocalizedString *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<Shared_coreLocalizedString *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelActionStringUseCase")))
@interface Shared_coreGetChannelActionStringUseCase : Shared_coreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (Shared_coreLocalizedString * _Nullable)leftButtonFunction:(Shared_coreSuplaChannelFunction *)function __attribute__((swift_name("leftButton(function:)")));
- (Shared_coreLocalizedString * _Nullable)rightButtonFunction:(Shared_coreSuplaChannelFunction *)function __attribute__((swift_name("rightButton(function:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaChannelFunctionKt")))
@interface Shared_coreSuplaChannelFunctionKt : Shared_coreBase
+ (Shared_coreSuplaChannelFunction *)suplaFunction:(int32_t)receiver __attribute__((swift_name("suplaFunction(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface Shared_coreKotlinEnumCompanion : Shared_coreBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) Shared_coreKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface Shared_coreKotlinArray<T> : Shared_coreBase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(Shared_coreInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<Shared_coreKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol Shared_coreKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
