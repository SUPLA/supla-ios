#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class SharedCoreValveValueCompanion, SharedCoreValveValue, SharedCoreValveIssuesProvider, SharedCoreUShort, SharedCoreULong, SharedCoreUInt, SharedCoreUByte, SharedCoreThermostatValueCompanion, SharedCoreThermostatValue, SharedCoreThermostatSubfunctionCompanion, SharedCoreThermostatSubfunction, SharedCoreThermostatState, SharedCoreThermostatIssuesProvider, SharedCoreSuplaValveFlagCompanion, SharedCoreSuplaValveFlag, SharedCoreSuplaThermostatFlagCompanion, SharedCoreSuplaThermostatFlag, SharedCoreSuplaShadingSystemFlagCompanion, SharedCoreSuplaShadingSystemFlag, SharedCoreSuplaHvacModeCompanion, SharedCoreSuplaHvacMode, SharedCoreSuplaFunctionKt, SharedCoreSuplaFunctionCompanion, SharedCoreSuplaFunction, SharedCoreStringExtensionsKt, SharedCoreStoreFileInDirectoryUseCase, SharedCoreStoreChannelOcrPhotoUseCase, SharedCoreShortExtensionsKt, SharedCoreShort, SharedCoreShadingSystemValueCompanion, SharedCoreShadingSystemValue, SharedCoreShadingSystemIssuesProvider, SharedCoreScene, SharedCoreRollerShutterValueCompanion, SharedCoreRollerShutterValue, SharedCoreOcrImageNamingProvider, SharedCoreNumber, SharedCoreMutableSet<ObjectType>, SharedCoreMutableDictionary<KeyType, ObjectType>, SharedCoreLong, SharedCoreLocalizedStringWithIdIntStringInt, SharedCoreLocalizedStringWithId, SharedCoreLocalizedStringKt, SharedCoreLocalizedStringId, SharedCoreLocalizedStringEmpty, SharedCoreLocalizedStringConstant, SharedCoreListItemIssuesCompanion, SharedCoreListItemIssues, SharedCoreKotlinThrowable, SharedCoreKotlinException, SharedCoreKotlinEnumCompanion, SharedCoreKotlinEnum<E>, SharedCoreKotlinByteIterator, SharedCoreKotlinByteArray, SharedCoreKotlinArray<T>, SharedCoreIssueIconWarning, SharedCoreIssueIconError, SharedCoreIssueIconBatteryNotUsed, SharedCoreIssueIconBattery75, SharedCoreIssueIconBattery50, SharedCoreIssueIconBattery25, SharedCoreIssueIconBattery100, SharedCoreIssueIconBattery0, SharedCoreIssueIconBattery, SharedCoreIssueIcon, SharedCoreInt, SharedCoreImpulseCounterPhotoDto, SharedCoreGroup, SharedCoreGetChannelLowBatteryIssueUseCase, SharedCoreGetChannelIssuesForSlavesUseCase, SharedCoreGetChannelIssuesForListUseCaseKt, SharedCoreGetChannelIssuesForListUseCase, SharedCoreGetChannelDefaultCaptionUseCase, SharedCoreGetChannelBatteryIconUseCase, SharedCoreGetChannelActionStringUseCase, SharedCoreGetCaptionUseCase, SharedCoreFloat, SharedCoreFacadeBlindValueCompanion, SharedCoreFacadeBlindValue, SharedCoreElectricityMeterConfigDto, SharedCoreElectricityChannelDto, SharedCoreDouble, SharedCoreDefaultChannelDto, SharedCoreContainerValueCompanion, SharedCoreContainerValue, SharedCoreContainerIssuesProvider, SharedCoreContainerFlagCompanion, SharedCoreContainerFlag, SharedCoreCheckOcrPhotoExistsUseCase, SharedCoreChannelWithChildren, SharedCoreChannelRelationTypeCompanion, SharedCoreChannelRelationType, SharedCoreChannelRelation, SharedCoreChannelIssueItemWarningCompanion, SharedCoreChannelIssueItemWarning, SharedCoreChannelIssueItemLowBattery, SharedCoreChannelIssueItemErrorCompanion, SharedCoreChannelIssueItemError, SharedCoreChannelIssueItemCompanion, SharedCoreChannelIssueItem, SharedCoreChannelChild, SharedCoreChannel, SharedCoreCacheFileAccessFile, SharedCoreByte, SharedCoreBooleanExtensionsKt, SharedCoreBoolean, SharedCoreBatteryInfo, SharedCoreBase64Helper, SharedCoreBase, NSString, NSSet<ObjectType>, NSObject, NSNumber, NSMutableSet<ObjectType>, NSMutableDictionary<KeyType, ObjectType>, NSMutableArray<ObjectType>, NSError, NSDictionary<KeyType, ObjectType>, NSArray<ObjectType>;

@protocol SharedCoreLocalizedString, SharedCoreKotlinIterator, SharedCoreKotlinComparable, SharedCoreChannelIssuesProvider, SharedCoreChannelDto, SharedCoreCacheFileAccess, SharedCoreBaseData, SharedCoreApplicationPreferences, NSCopying;

// Due to an Obj-C/Swift interop limitation, SKIE cannot generate Swift types with a lambda type argument.
// Example of such type is: A<() -> Unit> where A<T> is a generic class.
// To avoid compilation errors SKIE replaces these type arguments with __SkieLambdaErrorType, resulting in A<__SkieLambdaErrorType>.
// Generated declarations that reference __SkieLambdaErrorType cannot be called in any way and the __SkieLambdaErrorType class cannot be used.
// The original declarations can still be used in the same way as other declarations hidden by SKIE (and with the same limitations as without SKIE).
@interface __SkieLambdaErrorType : NSObject
- (instancetype _Nonnull)init __attribute__((unavailable));
+ (instancetype _Nonnull)new __attribute__((unavailable));
@end

// Due to an Obj-C/Swift interop limitation, SKIE cannot generate Swift code that uses external Obj-C types for which SKIE doesn't know a fully qualified name.
// This problem occurs when custom Cinterop bindings are used because those do not contain the name of the Framework that provides implementation for those binding.
// The name can be configured manually using the SKIE Gradle configuration key 'ClassInterop.CInteropFrameworkName' in the same way as other SKIE features.
// To avoid compilation errors SKIE replaces types with unknown Framework name with __SkieUnknownCInteropFrameworkErrorType.
// Generated declarations that reference __SkieUnknownCInteropFrameworkErrorType cannot be called in any way and the __SkieUnknownCInteropFrameworkErrorType class cannot be used.
@interface __SkieUnknownCInteropFrameworkErrorType : NSObject
- (instancetype _Nonnull)init __attribute__((unavailable));
+ (instancetype _Nonnull)new __attribute__((unavailable));
@end

typedef id<SharedCoreLocalizedString> _Nonnull Skie__TypeDef__0__id_SharedCoreLocalizedString_ __attribute__((__swift_private__));

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
@property (class, readonly, getter=companion) SharedCoreKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaHvacMode")))
@interface SharedCoreSuplaHvacMode : SharedCoreKotlinEnum<SharedCoreSuplaHvacMode *>
@property (class, readonly, getter=companion) SharedCoreSuplaHvacModeCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaHvacMode *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) SharedCoreSuplaHvacMode *notSet __attribute__((swift_name("notSet")));
@property (class, readonly) SharedCoreSuplaHvacMode *off __attribute__((swift_name("off")));
@property (class, readonly) SharedCoreSuplaHvacMode *heat __attribute__((swift_name("heat")));
@property (class, readonly) SharedCoreSuplaHvacMode *cool __attribute__((swift_name("cool")));
@property (class, readonly) SharedCoreSuplaHvacMode *heatCool __attribute__((swift_name("heatCool")));
@property (class, readonly) SharedCoreSuplaHvacMode *fanOnly __attribute__((swift_name("fanOnly")));
@property (class, readonly) SharedCoreSuplaHvacMode *dry __attribute__((swift_name("dry")));
@property (class, readonly) SharedCoreSuplaHvacMode *cmdTurnOn __attribute__((swift_name("cmdTurnOn")));
@property (class, readonly) SharedCoreSuplaHvacMode *cmdWeeklySchedule __attribute__((swift_name("cmdWeeklySchedule")));
@property (class, readonly) SharedCoreSuplaHvacMode *cmdSwitchToManual __attribute__((swift_name("cmdSwitchToManual")));
@property (class, readonly) NSArray<SharedCoreSuplaHvacMode *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreSuplaHvacMode *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaHvacMode.Companion")))
@interface SharedCoreSuplaHvacModeCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreSuplaHvacModeCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreSuplaHvacMode *)fromByte:(int32_t)byte __attribute__((swift_name("from(byte:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatSubfunction")))
@interface SharedCoreThermostatSubfunction : SharedCoreKotlinEnum<SharedCoreThermostatSubfunction *>
@property (class, readonly, getter=companion) SharedCoreThermostatSubfunctionCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreThermostatSubfunction *notSet __attribute__((swift_name("notSet")));
@property (class, readonly) SharedCoreThermostatSubfunction *heat __attribute__((swift_name("heat")));
@property (class, readonly) SharedCoreThermostatSubfunction *cool __attribute__((swift_name("cool")));
@property (class, readonly) NSArray<SharedCoreThermostatSubfunction *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreThermostatSubfunction *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatSubfunction.Companion")))
@interface SharedCoreThermostatSubfunctionCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreThermostatSubfunctionCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreThermostatSubfunction *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BatteryInfo")))
@interface SharedCoreBatteryInfo : SharedCoreBase
@property (readonly) SharedCoreBoolean * _Nullable batteryPowered __attribute__((swift_name("batteryPowered")));
@property (readonly) SharedCoreInt * _Nullable health __attribute__((swift_name("health")));
@property (readonly) SharedCoreInt * _Nullable level __attribute__((swift_name("level")));
- (instancetype)initWithBatteryPowered:(SharedCoreBoolean * _Nullable)batteryPowered level:(SharedCoreInt * _Nullable)level health:(SharedCoreInt * _Nullable)health __attribute__((swift_name("init(batteryPowered:level:health:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreBatteryInfo *)doCopyBatteryPowered:(SharedCoreBoolean * _Nullable)batteryPowered level:(SharedCoreInt * _Nullable)level health:(SharedCoreInt * _Nullable)health __attribute__((swift_name("doCopy(batteryPowered:level:health:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelChild")))
@interface SharedCoreChannelChild : SharedCoreBase
@property (readonly) SharedCoreChannel *channel __attribute__((swift_name("channel")));
@property (readonly) NSArray<SharedCoreChannelChild *> *children __attribute__((swift_name("children")));
@property (readonly) SharedCoreChannelRelation *relation __attribute__((swift_name("relation")));
- (instancetype)initWithChannel:(SharedCoreChannel *)channel relation:(SharedCoreChannelRelation *)relation children:(NSArray<SharedCoreChannelChild *> *)children __attribute__((swift_name("init(channel:relation:children:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelChild *)doCopyChannel:(SharedCoreChannel *)channel relation:(SharedCoreChannelRelation *)relation children:(NSArray<SharedCoreChannelChild *> *)children __attribute__((swift_name("doCopy(channel:relation:children:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelRelation")))
@interface SharedCoreChannelRelation : SharedCoreBase
@property (readonly) int32_t channelId __attribute__((swift_name("channelId")));
@property (readonly) int32_t parentId __attribute__((swift_name("parentId")));
@property (readonly) SharedCoreChannelRelationType *relationType __attribute__((swift_name("relationType")));
- (instancetype)initWithChannelId:(int32_t)channelId parentId:(int32_t)parentId relationType:(SharedCoreChannelRelationType *)relationType __attribute__((swift_name("init(channelId:parentId:relationType:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelRelation *)doCopyChannelId:(int32_t)channelId parentId:(int32_t)parentId relationType:(SharedCoreChannelRelationType *)relationType __attribute__((swift_name("doCopy(channelId:parentId:relationType:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelRelationType")))
@interface SharedCoreChannelRelationType : SharedCoreKotlinEnum<SharedCoreChannelRelationType *>
@property (class, readonly, getter=companion) SharedCoreChannelRelationTypeCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreChannelRelationType *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) SharedCoreChannelRelationType *default_ __attribute__((swift_name("default_")));
@property (class, readonly) SharedCoreChannelRelationType *openingSensor __attribute__((swift_name("openingSensor")));
@property (class, readonly) SharedCoreChannelRelationType *partialOpeningSensor __attribute__((swift_name("partialOpeningSensor")));
@property (class, readonly) SharedCoreChannelRelationType *meter __attribute__((swift_name("meter")));
@property (class, readonly) SharedCoreChannelRelationType *mainThermometer __attribute__((swift_name("mainThermometer")));
@property (class, readonly) SharedCoreChannelRelationType *auxThermometerFloor __attribute__((swift_name("auxThermometerFloor")));
@property (class, readonly) SharedCoreChannelRelationType *auxThermometerWater __attribute__((swift_name("auxThermometerWater")));
@property (class, readonly) SharedCoreChannelRelationType *auxThermometerGenericHeater __attribute__((swift_name("auxThermometerGenericHeater")));
@property (class, readonly) SharedCoreChannelRelationType *auxThermometerGenericCooler __attribute__((swift_name("auxThermometerGenericCooler")));
@property (class, readonly) SharedCoreChannelRelationType *masterThermostat __attribute__((swift_name("masterThermostat")));
@property (class, readonly) SharedCoreChannelRelationType *heatOrColdSourceSwitch __attribute__((swift_name("heatOrColdSourceSwitch")));
@property (class, readonly) SharedCoreChannelRelationType *pumpSwitch __attribute__((swift_name("pumpSwitch")));
@property (class, readonly) NSArray<SharedCoreChannelRelationType *> *entries __attribute__((swift_name("entries")));
@property (readonly) int16_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreChannelRelationType *> *)values __attribute__((swift_name("values()")));
- (BOOL)isAuxThermometer __attribute__((swift_name("isAuxThermometer()")));
- (BOOL)isMainThermometer __attribute__((swift_name("isMainThermometer()")));
- (BOOL)isThermometer __attribute__((swift_name("isThermometer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelRelationType.Companion")))
@interface SharedCoreChannelRelationTypeCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreChannelRelationTypeCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreChannelRelationType *)fromValue:(int16_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelWithChildren")))
@interface SharedCoreChannelWithChildren : SharedCoreBase
@property (readonly) SharedCoreChannel *channel __attribute__((swift_name("channel")));
@property (readonly) NSArray<SharedCoreChannelChild *> *children __attribute__((swift_name("children")));
- (instancetype)initWithChannel:(SharedCoreChannel *)channel children:(NSArray<SharedCoreChannelChild *> *)children __attribute__((swift_name("init(channel:children:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelWithChildren *)doCopyChannel:(SharedCoreChannel *)channel children:(NSArray<SharedCoreChannelChild *> *)children __attribute__((swift_name("doCopy(channel:children:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContainerFlag")))
@interface SharedCoreContainerFlag : SharedCoreKotlinEnum<SharedCoreContainerFlag *>
@property (class, readonly, getter=companion) SharedCoreContainerFlagCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreContainerFlag *warningLevel __attribute__((swift_name("warningLevel")));
@property (class, readonly) SharedCoreContainerFlag *alarmLevel __attribute__((swift_name("alarmLevel")));
@property (class, readonly) SharedCoreContainerFlag *invalidSensorState __attribute__((swift_name("invalidSensorState")));
@property (class, readonly) SharedCoreContainerFlag *soundAlarmOn __attribute__((swift_name("soundAlarmOn")));
@property (class, readonly) NSArray<SharedCoreContainerFlag *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreContainerFlag *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContainerFlag.Companion")))
@interface SharedCoreContainerFlagCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreContainerFlagCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (NSArray<SharedCoreContainerFlag *> *)fromShort:(int16_t)short_ __attribute__((swift_name("from(short:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContainerValue")))
@interface SharedCoreContainerValue : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreContainerValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<SharedCoreContainerFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) int32_t level __attribute__((swift_name("level")));
@property (readonly) BOOL levelKnown __attribute__((swift_name("levelKnown")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
- (instancetype)initWithOnline:(BOOL)online flags:(NSArray<SharedCoreContainerFlag *> *)flags rawLevel:(int32_t)rawLevel __attribute__((swift_name("init(online:flags:rawLevel:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreContainerValue *)doCopyOnline:(BOOL)online flags:(NSArray<SharedCoreContainerFlag *> *)flags rawLevel:(int32_t)rawLevel __attribute__((swift_name("doCopy(online:flags:rawLevel:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContainerValue.Companion")))
@interface SharedCoreContainerValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreContainerValueCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreContainerValue *)fromOnline:(BOOL)online bytes:(SharedCoreKotlinByteArray *)bytes __attribute__((swift_name("from(online:bytes:)")));
@end

__attribute__((swift_name("ShadingSystemValue")))
@interface SharedCoreShadingSystemValue : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreShadingSystemValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t alwaysValidPosition __attribute__((swift_name("alwaysValidPosition")));
@property (readonly) NSArray<SharedCoreSuplaShadingSystemFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
@property (readonly) int32_t position __attribute__((swift_name("position")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreChannelIssueItem * _Nullable)getChannelIssue __attribute__((swift_name("getChannelIssue()")));
- (BOOL)hasValidPosition __attribute__((swift_name("hasValidPosition()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FacadeBlindValue")))
@interface SharedCoreFacadeBlindValue : SharedCoreShadingSystemValue
@property (class, readonly, getter=companion) SharedCoreFacadeBlindValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t alwaysValidTilt __attribute__((swift_name("alwaysValidTilt")));
@property (readonly) NSArray<SharedCoreSuplaShadingSystemFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
@property (readonly) int32_t position __attribute__((swift_name("position")));
@property (readonly) int32_t tilt __attribute__((swift_name("tilt")));
- (instancetype)initWithOnline:(BOOL)online position:(int32_t)position tilt:(int32_t)tilt flags:(NSArray<SharedCoreSuplaShadingSystemFlag *> *)flags __attribute__((swift_name("init(online:position:tilt:flags:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (SharedCoreFacadeBlindValue *)doCopyOnline:(BOOL)online position:(int32_t)position tilt:(int32_t)tilt flags:(NSArray<SharedCoreSuplaShadingSystemFlag *> *)flags __attribute__((swift_name("doCopy(online:position:tilt:flags:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (BOOL)hasValidTilt __attribute__((swift_name("hasValidTilt()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FacadeBlindValue.Companion")))
@interface SharedCoreFacadeBlindValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreFacadeBlindValueCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreFacadeBlindValue *)fromOnline:(BOOL)online bytes:(SharedCoreKotlinByteArray *)bytes __attribute__((swift_name("from(online:bytes:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RollerShutterValue")))
@interface SharedCoreRollerShutterValue : SharedCoreShadingSystemValue
@property (class, readonly, getter=companion) SharedCoreRollerShutterValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t bottomPosition __attribute__((swift_name("bottomPosition")));
@property (readonly) NSArray<SharedCoreSuplaShadingSystemFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
@property (readonly) int32_t position __attribute__((swift_name("position")));
- (instancetype)initWithOnline:(BOOL)online position:(int32_t)position bottomPosition:(int32_t)bottomPosition flags:(NSArray<SharedCoreSuplaShadingSystemFlag *> *)flags __attribute__((swift_name("init(online:position:bottomPosition:flags:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (SharedCoreRollerShutterValue *)doCopyOnline:(BOOL)online position:(int32_t)position bottomPosition:(int32_t)bottomPosition flags:(NSArray<SharedCoreSuplaShadingSystemFlag *> *)flags __attribute__((swift_name("doCopy(online:position:bottomPosition:flags:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RollerShutterValue.Companion")))
@interface SharedCoreRollerShutterValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreRollerShutterValueCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreRollerShutterValue *)fromOnline:(BOOL)online bytes:(SharedCoreKotlinByteArray *)bytes __attribute__((swift_name("from(online:bytes:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaThermostatFlag")))
@interface SharedCoreSuplaThermostatFlag : SharedCoreKotlinEnum<SharedCoreSuplaThermostatFlag *>
@property (class, readonly, getter=companion) SharedCoreSuplaThermostatFlagCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *setpointTempMinSet __attribute__((swift_name("setpointTempMinSet")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *setpointTempMaxSet __attribute__((swift_name("setpointTempMaxSet")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *heating __attribute__((swift_name("heating")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *cooling __attribute__((swift_name("cooling")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *weeklySchedule __attribute__((swift_name("weeklySchedule")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *countdownTimer __attribute__((swift_name("countdownTimer")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *fanEnabled __attribute__((swift_name("fanEnabled")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *thermometerError __attribute__((swift_name("thermometerError")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *clockError __attribute__((swift_name("clockError")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *forcedOffBySensor __attribute__((swift_name("forcedOffBySensor")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *heatOrCool __attribute__((swift_name("heatOrCool")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *weeklyScheduleTemporalOverride __attribute__((swift_name("weeklyScheduleTemporalOverride")));
@property (class, readonly) SharedCoreSuplaThermostatFlag *batteryCoverOpen __attribute__((swift_name("batteryCoverOpen")));
@property (class, readonly) NSArray<SharedCoreSuplaThermostatFlag *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreSuplaThermostatFlag *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaThermostatFlag.Companion")))
@interface SharedCoreSuplaThermostatFlagCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreSuplaThermostatFlagCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (NSArray<SharedCoreSuplaThermostatFlag *> *)fromShort:(int16_t)short_ __attribute__((swift_name("from(short:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatState")))
@interface SharedCoreThermostatState : SharedCoreBase
@property (readonly) SharedCoreFloat * _Nullable power __attribute__((swift_name("power")));
@property (readonly) int16_t value __attribute__((swift_name("value")));
- (instancetype)initWithValue:(int16_t)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreThermostatState *)doCopyValue:(int16_t)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isOff __attribute__((swift_name("isOff()")));
- (BOOL)isOn __attribute__((swift_name("isOn()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatValue")))
@interface SharedCoreThermostatValue : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreThermostatValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<SharedCoreSuplaThermostatFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) SharedCoreSuplaHvacMode *mode __attribute__((swift_name("mode")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
@property (readonly) float setpointTemperatureCool __attribute__((swift_name("setpointTemperatureCool")));
@property (readonly) float setpointTemperatureHeat __attribute__((swift_name("setpointTemperatureHeat")));
@property (readonly) SharedCoreThermostatState *state __attribute__((swift_name("state")));
@property (readonly) SharedCoreThermostatSubfunction *subfunction __attribute__((swift_name("subfunction")));
- (SharedCoreThermostatValue *)doCopyOnline:(BOOL)online state:(SharedCoreThermostatState *)state mode:(SharedCoreSuplaHvacMode *)mode setpointTemperatureHeat:(float)setpointTemperatureHeat setpointTemperatureCool:(float)setpointTemperatureCool flags:(NSArray<SharedCoreSuplaThermostatFlag *> *)flags __attribute__((swift_name("doCopy(online:state:mode:setpointTemperatureHeat:setpointTemperatureCool:flags:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatValue.Companion")))
@interface SharedCoreThermostatValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreThermostatValueCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreThermostatValue *)fromOnline:(BOOL)online bytes:(SharedCoreKotlinByteArray *)bytes __attribute__((swift_name("from(online:bytes:)")));
@end

__attribute__((swift_name("BaseData")))
@protocol SharedCoreBaseData
@required
@property (readonly) NSString *caption __attribute__((swift_name("caption")));
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Channel")))
@interface SharedCoreChannel : SharedCoreBase <SharedCoreBaseData>
@property (readonly) SharedCoreBatteryInfo * _Nullable batteryInfo __attribute__((swift_name("batteryInfo")));
@property (readonly) NSString *caption __attribute__((swift_name("caption")));
@property (readonly) SharedCoreSuplaFunction *function __attribute__((swift_name("function")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
@property (readonly) SharedCoreKotlinByteArray * _Nullable value __attribute__((swift_name("value")));
- (instancetype)initWithRemoteId:(int32_t)remoteId caption:(NSString *)caption online:(BOOL)online function:(SharedCoreSuplaFunction *)function batteryInfo:(SharedCoreBatteryInfo * _Nullable)batteryInfo value:(SharedCoreKotlinByteArray * _Nullable)value __attribute__((swift_name("init(remoteId:caption:online:function:batteryInfo:value:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannel *)doCopyRemoteId:(int32_t)remoteId caption:(NSString *)caption online:(BOOL)online function:(SharedCoreSuplaFunction *)function batteryInfo:(SharedCoreBatteryInfo * _Nullable)batteryInfo value:(SharedCoreKotlinByteArray * _Nullable)value __attribute__((swift_name("doCopy(remoteId:caption:online:function:batteryInfo:value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Group")))
@interface SharedCoreGroup : SharedCoreBase <SharedCoreBaseData>
@property (readonly) NSString *caption __attribute__((swift_name("caption")));
@property (readonly) SharedCoreSuplaFunction *function __attribute__((swift_name("function")));
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
- (instancetype)initWithRemoteId:(int32_t)remoteId caption:(NSString *)caption function:(SharedCoreSuplaFunction *)function __attribute__((swift_name("init(remoteId:caption:function:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreGroup *)doCopyRemoteId:(int32_t)remoteId caption:(NSString *)caption function:(SharedCoreSuplaFunction *)function __attribute__((swift_name("doCopy(remoteId:caption:function:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Scene")))
@interface SharedCoreScene : SharedCoreBase <SharedCoreBaseData>
@property (readonly) NSString *caption __attribute__((swift_name("caption")));
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
- (instancetype)initWithRemoteId:(int32_t)remoteId caption:(NSString *)caption __attribute__((swift_name("init(remoteId:caption:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreScene *)doCopyRemoteId:(int32_t)remoteId caption:(NSString *)caption __attribute__((swift_name("doCopy(remoteId:caption:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaFunction")))
@interface SharedCoreSuplaFunction : SharedCoreKotlinEnum<SharedCoreSuplaFunction *>
@property (class, readonly, getter=companion) SharedCoreSuplaFunctionCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaFunction *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) SharedCoreSuplaFunction *none __attribute__((swift_name("none")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheGatewayLock __attribute__((swift_name("controllingTheGatewayLock")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheGate __attribute__((swift_name("controllingTheGate")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheGarageDoor __attribute__((swift_name("controllingTheGarageDoor")));
@property (class, readonly) SharedCoreSuplaFunction *thermometer __attribute__((swift_name("thermometer")));
@property (class, readonly) SharedCoreSuplaFunction *humidity __attribute__((swift_name("humidity")));
@property (class, readonly) SharedCoreSuplaFunction *humidityAndTemperature __attribute__((swift_name("humidityAndTemperature")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorGateway __attribute__((swift_name("openSensorGateway")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorGate __attribute__((swift_name("openSensorGate")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorGarageDoor __attribute__((swift_name("openSensorGarageDoor")));
@property (class, readonly) SharedCoreSuplaFunction *noLiquidSensor __attribute__((swift_name("noLiquidSensor")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheDoorLock __attribute__((swift_name("controllingTheDoorLock")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorDoor __attribute__((swift_name("openSensorDoor")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheRollerShutter __attribute__((swift_name("controllingTheRollerShutter")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheRoofWindow __attribute__((swift_name("controllingTheRoofWindow")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorRollerShutter __attribute__((swift_name("openSensorRollerShutter")));
@property (class, readonly) SharedCoreSuplaFunction *openSensorRoofWindow __attribute__((swift_name("openSensorRoofWindow")));
@property (class, readonly) SharedCoreSuplaFunction *powerSwitch __attribute__((swift_name("powerSwitch")));
@property (class, readonly) SharedCoreSuplaFunction *lightswitch __attribute__((swift_name("lightswitch")));
@property (class, readonly) SharedCoreSuplaFunction *ring __attribute__((swift_name("ring")));
@property (class, readonly) SharedCoreSuplaFunction *alarm __attribute__((swift_name("alarm")));
@property (class, readonly) SharedCoreSuplaFunction *notification __attribute__((swift_name("notification")));
@property (class, readonly) SharedCoreSuplaFunction *dimmer __attribute__((swift_name("dimmer")));
@property (class, readonly) SharedCoreSuplaFunction *rgbLighting __attribute__((swift_name("rgbLighting")));
@property (class, readonly) SharedCoreSuplaFunction *dimmerAndRgbLighting __attribute__((swift_name("dimmerAndRgbLighting")));
@property (class, readonly) SharedCoreSuplaFunction *depthSensor __attribute__((swift_name("depthSensor")));
@property (class, readonly) SharedCoreSuplaFunction *distanceSensor __attribute__((swift_name("distanceSensor")));
@property (class, readonly) SharedCoreSuplaFunction *openingSensorWindow __attribute__((swift_name("openingSensorWindow")));
@property (class, readonly) SharedCoreSuplaFunction *hotelCardSensor __attribute__((swift_name("hotelCardSensor")));
@property (class, readonly) SharedCoreSuplaFunction *alarmArmamentSensor __attribute__((swift_name("alarmArmamentSensor")));
@property (class, readonly) SharedCoreSuplaFunction *mailSensor __attribute__((swift_name("mailSensor")));
@property (class, readonly) SharedCoreSuplaFunction *windSensor __attribute__((swift_name("windSensor")));
@property (class, readonly) SharedCoreSuplaFunction *pressureSensor __attribute__((swift_name("pressureSensor")));
@property (class, readonly) SharedCoreSuplaFunction *rainSensor __attribute__((swift_name("rainSensor")));
@property (class, readonly) SharedCoreSuplaFunction *weightSensor __attribute__((swift_name("weightSensor")));
@property (class, readonly) SharedCoreSuplaFunction *weatherStation __attribute__((swift_name("weatherStation")));
@property (class, readonly) SharedCoreSuplaFunction *staircaseTimer __attribute__((swift_name("staircaseTimer")));
@property (class, readonly) SharedCoreSuplaFunction *electricityMeter __attribute__((swift_name("electricityMeter")));
@property (class, readonly) SharedCoreSuplaFunction *icElectricityMeter __attribute__((swift_name("icElectricityMeter")));
@property (class, readonly) SharedCoreSuplaFunction *icGasMeter __attribute__((swift_name("icGasMeter")));
@property (class, readonly) SharedCoreSuplaFunction *icWaterMeter __attribute__((swift_name("icWaterMeter")));
@property (class, readonly) SharedCoreSuplaFunction *icHeatMeter __attribute__((swift_name("icHeatMeter")));
@property (class, readonly) SharedCoreSuplaFunction *thermostatHeatpolHomeplus __attribute__((swift_name("thermostatHeatpolHomeplus")));
@property (class, readonly) SharedCoreSuplaFunction *hvacThermostat __attribute__((swift_name("hvacThermostat")));
@property (class, readonly) SharedCoreSuplaFunction *hvacThermostatHeatCool __attribute__((swift_name("hvacThermostatHeatCool")));
@property (class, readonly) SharedCoreSuplaFunction *hvacDomesticHotWater __attribute__((swift_name("hvacDomesticHotWater")));
@property (class, readonly) SharedCoreSuplaFunction *valveOpenClose __attribute__((swift_name("valveOpenClose")));
@property (class, readonly) SharedCoreSuplaFunction *valvePercentage __attribute__((swift_name("valvePercentage")));
@property (class, readonly) SharedCoreSuplaFunction *generalPurposeMeasurement __attribute__((swift_name("generalPurposeMeasurement")));
@property (class, readonly) SharedCoreSuplaFunction *generalPurposeMeter __attribute__((swift_name("generalPurposeMeter")));
@property (class, readonly) SharedCoreSuplaFunction *digiglassHorizontal __attribute__((swift_name("digiglassHorizontal")));
@property (class, readonly) SharedCoreSuplaFunction *digiglassVertical __attribute__((swift_name("digiglassVertical")));
@property (class, readonly) SharedCoreSuplaFunction *controllingTheFacadeBlind __attribute__((swift_name("controllingTheFacadeBlind")));
@property (class, readonly) SharedCoreSuplaFunction *terraceAwning __attribute__((swift_name("terraceAwning")));
@property (class, readonly) SharedCoreSuplaFunction *projectorScreen __attribute__((swift_name("projectorScreen")));
@property (class, readonly) SharedCoreSuplaFunction *curtain __attribute__((swift_name("curtain")));
@property (class, readonly) SharedCoreSuplaFunction *verticalBlind __attribute__((swift_name("verticalBlind")));
@property (class, readonly) SharedCoreSuplaFunction *rollerGarageDoor __attribute__((swift_name("rollerGarageDoor")));
@property (class, readonly) SharedCoreSuplaFunction *pumpSwitch __attribute__((swift_name("pumpSwitch")));
@property (class, readonly) SharedCoreSuplaFunction *heatOrColdSourceSwitch __attribute__((swift_name("heatOrColdSourceSwitch")));
@property (class, readonly) SharedCoreSuplaFunction *container __attribute__((swift_name("container")));
@property (class, readonly) SharedCoreSuplaFunction *septicTank __attribute__((swift_name("septicTank")));
@property (class, readonly) SharedCoreSuplaFunction *waterTank __attribute__((swift_name("waterTank")));
@property (class, readonly) SharedCoreSuplaFunction *containerLevelSensor __attribute__((swift_name("containerLevelSensor")));
@property (class, readonly) SharedCoreSuplaFunction *floodSensor __attribute__((swift_name("floodSensor")));
@property (class, readonly) NSArray<SharedCoreSuplaFunction *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreSuplaFunction *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaFunction.Companion")))
@interface SharedCoreSuplaFunctionCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreSuplaFunctionCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreSuplaFunction *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((swift_name("ChannelIssueItem")))
@interface SharedCoreChannelIssueItem : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreChannelIssueItemCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) SharedCoreIssueIcon *icon __attribute__((swift_name("icon")));
@property (readonly) id<SharedCoreLocalizedString> message __attribute__((swift_name("message")));
@property (readonly) NSArray<id<SharedCoreLocalizedString>> *messages __attribute__((swift_name("messages")));
@property (readonly) int32_t priority __attribute__((swift_name("priority")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.Companion")))
@interface SharedCoreChannelIssueItemCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreChannelIssueItemCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.Error")))
@interface SharedCoreChannelIssueItemError : SharedCoreChannelIssueItem
@property (class, readonly, getter=companion) SharedCoreChannelIssueItemErrorCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<id<SharedCoreLocalizedString>> *messages __attribute__((swift_name("messages")));
@property (readonly) int32_t priority __attribute__((swift_name("priority")));
- (instancetype)initWithString:(id<SharedCoreLocalizedString> _Nullable)string __attribute__((swift_name("init(string:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelIssueItemError *)doCopyString:(id<SharedCoreLocalizedString> _Nullable)string __attribute__((swift_name("doCopy(string:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.ErrorCompanion")))
@interface SharedCoreChannelIssueItemErrorCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreChannelIssueItemErrorCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreChannelIssueItemError *)invokeStringId:(SharedCoreLocalizedStringId *)stringId __attribute__((swift_name("invoke(stringId:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.LowBattery")))
@interface SharedCoreChannelIssueItemLowBattery : SharedCoreChannelIssueItem
@property (readonly) NSArray<id<SharedCoreLocalizedString>> *messages __attribute__((swift_name("messages")));
@property (readonly) int32_t priority __attribute__((swift_name("priority")));
- (instancetype)initWithMessages:(NSArray<id<SharedCoreLocalizedString>> *)messages __attribute__((swift_name("init(messages:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelIssueItemLowBattery *)doCopyMessages:(NSArray<id<SharedCoreLocalizedString>> *)messages __attribute__((swift_name("doCopy(messages:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.Warning")))
@interface SharedCoreChannelIssueItemWarning : SharedCoreChannelIssueItem
@property (class, readonly, getter=companion) SharedCoreChannelIssueItemWarningCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<id<SharedCoreLocalizedString>> *messages __attribute__((swift_name("messages")));
@property (readonly) int32_t priority __attribute__((swift_name("priority")));
- (instancetype)initWithString:(id<SharedCoreLocalizedString> _Nullable)string __attribute__((swift_name("init(string:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelIssueItemWarning *)doCopyString:(id<SharedCoreLocalizedString> _Nullable)string __attribute__((swift_name("doCopy(string:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ChannelIssueItem.WarningCompanion")))
@interface SharedCoreChannelIssueItemWarningCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreChannelIssueItemWarningCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreChannelIssueItemWarning *)invokeStringId:(SharedCoreLocalizedStringId *)stringId __attribute__((swift_name("invoke(stringId:)")));
@end

__attribute__((swift_name("IssueIcon")))
@interface SharedCoreIssueIcon : SharedCoreBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery")))
@interface SharedCoreIssueIconBattery : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery0")))
@interface SharedCoreIssueIconBattery0 : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery0 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery0 __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery100")))
@interface SharedCoreIssueIconBattery100 : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery100 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery100 __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery25")))
@interface SharedCoreIssueIconBattery25 : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery25 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery25 __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery50")))
@interface SharedCoreIssueIconBattery50 : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery50 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery50 __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Battery75")))
@interface SharedCoreIssueIconBattery75 : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBattery75 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)battery75 __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.BatteryNotUsed")))
@interface SharedCoreIssueIconBatteryNotUsed : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconBatteryNotUsed *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)batteryNotUsed __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Error")))
@interface SharedCoreIssueIconError : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconError *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)error __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IssueIcon.Warning")))
@interface SharedCoreIssueIconWarning : SharedCoreIssueIcon
@property (class, readonly, getter=shared) SharedCoreIssueIconWarning *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)warning __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListItemIssues")))
@interface SharedCoreListItemIssues : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreListItemIssuesCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<SharedCoreIssueIcon *> *icons __attribute__((swift_name("icons")));
@property (readonly) NSArray<id<SharedCoreLocalizedString>> *issuesStrings __attribute__((swift_name("issuesStrings")));
- (instancetype)initWithIcons:(NSArray<SharedCoreIssueIcon *> *)icons issuesStrings:(NSArray<id<SharedCoreLocalizedString>> *)issuesStrings __attribute__((swift_name("init(icons:issuesStrings:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreListItemIssues *)doCopyIcons:(NSArray<SharedCoreIssueIcon *> *)icons issuesStrings:(NSArray<id<SharedCoreLocalizedString>> *)issuesStrings __attribute__((swift_name("doCopy(icons:issuesStrings:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (BOOL)hasMessage __attribute__((swift_name("hasMessage()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListItemIssues.Companion")))
@interface SharedCoreListItemIssuesCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreListItemIssuesCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) SharedCoreListItemIssues *empty __attribute__((swift_name("empty")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreListItemIssues *)invokeIssueIcon:(SharedCoreIssueIcon *)issueIcon __attribute__((swift_name("invoke(issueIcon:)")));
- (SharedCoreListItemIssues *)invokeFirst:(SharedCoreIssueIcon *)first second:(SharedCoreIssueIcon *)second __attribute__((swift_name("invoke(first:second:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImpulseCounterPhotoDto")))
@interface SharedCoreImpulseCounterPhotoDto : SharedCoreBase
@property (readonly) int32_t channelNo __attribute__((swift_name("channelNo")));
@property (readonly) NSString *createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *deviceGuid __attribute__((swift_name("deviceGuid")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString * _Nullable image __attribute__((swift_name("image")));
@property (readonly) NSString * _Nullable imageCropped __attribute__((swift_name("imageCropped")));
@property (readonly) BOOL measurementValid __attribute__((swift_name("measurementValid")));
@property (readonly) NSString * _Nullable processedAt __attribute__((swift_name("processedAt")));
@property (readonly) SharedCoreInt * _Nullable processingTimeMs __attribute__((swift_name("processingTimeMs")));
@property (readonly) SharedCoreInt * _Nullable processingTimeMs2 __attribute__((swift_name("processingTimeMs2")));
@property (readonly) NSString * _Nullable replacedAt __attribute__((swift_name("replacedAt")));
@property (readonly) int32_t resultCode __attribute__((swift_name("resultCode")));
@property (readonly) SharedCoreInt * _Nullable resultMeasurement __attribute__((swift_name("resultMeasurement")));
@property (readonly) SharedCoreInt * _Nullable resultMeasurement2 __attribute__((swift_name("resultMeasurement2")));
@property (readonly) NSString * _Nullable resultMessage __attribute__((swift_name("resultMessage")));
- (instancetype)initWithId:(NSString *)id deviceGuid:(NSString *)deviceGuid channelNo:(int32_t)channelNo createdAt:(NSString *)createdAt replacedAt:(NSString * _Nullable)replacedAt processedAt:(NSString * _Nullable)processedAt resultMeasurement:(SharedCoreInt * _Nullable)resultMeasurement processingTimeMs:(SharedCoreInt * _Nullable)processingTimeMs resultMeasurement2:(SharedCoreInt * _Nullable)resultMeasurement2 processingTimeMs2:(SharedCoreInt * _Nullable)processingTimeMs2 resultCode:(int32_t)resultCode resultMessage:(NSString * _Nullable)resultMessage measurementValid:(BOOL)measurementValid image:(NSString * _Nullable)image imageCropped:(NSString * _Nullable)imageCropped __attribute__((swift_name("init(id:deviceGuid:channelNo:createdAt:replacedAt:processedAt:resultMeasurement:processingTimeMs:resultMeasurement2:processingTimeMs2:resultCode:resultMessage:measurementValid:image:imageCropped:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreImpulseCounterPhotoDto *)doCopyId:(NSString *)id deviceGuid:(NSString *)deviceGuid channelNo:(int32_t)channelNo createdAt:(NSString *)createdAt replacedAt:(NSString * _Nullable)replacedAt processedAt:(NSString * _Nullable)processedAt resultMeasurement:(SharedCoreInt * _Nullable)resultMeasurement processingTimeMs:(SharedCoreInt * _Nullable)processingTimeMs resultMeasurement2:(SharedCoreInt * _Nullable)resultMeasurement2 processingTimeMs2:(SharedCoreInt * _Nullable)processingTimeMs2 resultCode:(int32_t)resultCode resultMessage:(NSString * _Nullable)resultMessage measurementValid:(BOOL)measurementValid image:(NSString * _Nullable)image imageCropped:(NSString * _Nullable)imageCropped __attribute__((swift_name("doCopy(id:deviceGuid:channelNo:createdAt:replacedAt:processedAt:resultMeasurement:processingTimeMs:resultMeasurement2:processingTimeMs2:resultCode:resultMessage:measurementValid:image:imageCropped:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ChannelDto")))
@protocol SharedCoreChannelDto
@required
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DefaultChannelDto")))
@interface SharedCoreDefaultChannelDto : SharedCoreBase <SharedCoreChannelDto>
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
- (instancetype)initWithRemoteId:(int32_t)remoteId __attribute__((swift_name("init(remoteId:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreDefaultChannelDto *)doCopyRemoteId:(int32_t)remoteId __attribute__((swift_name("doCopy(remoteId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ElectricityChannelDto")))
@interface SharedCoreElectricityChannelDto : SharedCoreBase <SharedCoreChannelDto>
@property (readonly) SharedCoreElectricityMeterConfigDto *config __attribute__((swift_name("config")));
@property (readonly) int32_t remoteId __attribute__((swift_name("remoteId")));
- (instancetype)initWithRemoteId:(int32_t)remoteId config:(SharedCoreElectricityMeterConfigDto *)config __attribute__((swift_name("init(remoteId:config:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreElectricityChannelDto *)doCopyRemoteId:(int32_t)remoteId config:(SharedCoreElectricityMeterConfigDto *)config __attribute__((swift_name("doCopy(remoteId:config:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ElectricityMeterConfigDto")))
@interface SharedCoreElectricityMeterConfigDto : SharedCoreBase
@property (readonly) NSString *currency __attribute__((swift_name("currency")));
@property (readonly) BOOL currentLoggerEnabled __attribute__((swift_name("currentLoggerEnabled")));
@property (readonly) BOOL powerActiveLoggerEnabled __attribute__((swift_name("powerActiveLoggerEnabled")));
@property (readonly) float pricePerUnit __attribute__((swift_name("pricePerUnit")));
@property (readonly) BOOL voltageLoggerEnabled __attribute__((swift_name("voltageLoggerEnabled")));
- (instancetype)initWithPricePerUnit:(float)pricePerUnit currency:(NSString *)currency voltageLoggerEnabled:(BOOL)voltageLoggerEnabled currentLoggerEnabled:(BOOL)currentLoggerEnabled powerActiveLoggerEnabled:(BOOL)powerActiveLoggerEnabled __attribute__((swift_name("init(pricePerUnit:currency:voltageLoggerEnabled:currentLoggerEnabled:powerActiveLoggerEnabled:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreElectricityMeterConfigDto *)doCopyPricePerUnit:(float)pricePerUnit currency:(NSString *)currency voltageLoggerEnabled:(BOOL)voltageLoggerEnabled currentLoggerEnabled:(BOOL)currentLoggerEnabled powerActiveLoggerEnabled:(BOOL)powerActiveLoggerEnabled __attribute__((swift_name("doCopy(pricePerUnit:currency:voltageLoggerEnabled:currentLoggerEnabled:powerActiveLoggerEnabled:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ShadingSystemValue.Companion")))
@interface SharedCoreShadingSystemValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreShadingSystemValueCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) int32_t INVALID_VALUE __attribute__((swift_name("INVALID_VALUE")));
@property (readonly) int32_t MAX_VALUE __attribute__((swift_name("MAX_VALUE")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaShadingSystemFlag")))
@interface SharedCoreSuplaShadingSystemFlag : SharedCoreKotlinEnum<SharedCoreSuplaShadingSystemFlag *>
@property (class, readonly, getter=companion) SharedCoreSuplaShadingSystemFlagCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaShadingSystemFlag *tiltIsSet __attribute__((swift_name("tiltIsSet")));
@property (class, readonly) SharedCoreSuplaShadingSystemFlag *calibrationFailed __attribute__((swift_name("calibrationFailed")));
@property (class, readonly) SharedCoreSuplaShadingSystemFlag *calibrationLost __attribute__((swift_name("calibrationLost")));
@property (class, readonly) SharedCoreSuplaShadingSystemFlag *motorProblem __attribute__((swift_name("motorProblem")));
@property (class, readonly) SharedCoreSuplaShadingSystemFlag *calibrationInProgress __attribute__((swift_name("calibrationInProgress")));
@property (class, readonly) NSArray<SharedCoreSuplaShadingSystemFlag *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreSuplaShadingSystemFlag *> *)values __attribute__((swift_name("values()")));
- (SharedCoreChannelIssueItem * _Nullable)asChannelIssues __attribute__((swift_name("asChannelIssues()")));
- (BOOL)isIssueFlag __attribute__((swift_name("isIssueFlag()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaShadingSystemFlag.Companion")))
@interface SharedCoreSuplaShadingSystemFlagCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreSuplaShadingSystemFlagCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (NSArray<SharedCoreSuplaShadingSystemFlag *> *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaValveFlag")))
@interface SharedCoreSuplaValveFlag : SharedCoreKotlinEnum<SharedCoreSuplaValveFlag *>
@property (class, readonly, getter=companion) SharedCoreSuplaValveFlagCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) SharedCoreSuplaValveFlag *flooding __attribute__((swift_name("flooding")));
@property (class, readonly) SharedCoreSuplaValveFlag *manuallyClosed __attribute__((swift_name("manuallyClosed")));
@property (class, readonly) NSArray<SharedCoreSuplaValveFlag *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreSuplaValveFlag *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaValveFlag.Companion")))
@interface SharedCoreSuplaValveFlagCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreSuplaValveFlagCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (NSArray<SharedCoreSuplaValveFlag *> *)fromValue:(int32_t)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ValveValue")))
@interface SharedCoreValveValue : SharedCoreBase
@property (class, readonly, getter=companion) SharedCoreValveValueCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t closed __attribute__((swift_name("closed")));
@property (readonly) NSArray<SharedCoreSuplaValveFlag *> *flags __attribute__((swift_name("flags")));
@property (readonly) BOOL online __attribute__((swift_name("online")));
- (instancetype)initWithOnline:(BOOL)online closed:(int32_t)closed flags:(NSArray<SharedCoreSuplaValveFlag *> *)flags __attribute__((swift_name("init(online:closed:flags:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreValveValue *)doCopyOnline:(BOOL)online closed:(int32_t)closed flags:(NSArray<SharedCoreSuplaValveFlag *> *)flags __attribute__((swift_name("doCopy(online:closed:flags:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isClosed __attribute__((swift_name("isClosed()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ValveValue.Companion")))
@interface SharedCoreValveValueCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreValveValueCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (SharedCoreValveValue *)fromOnline:(BOOL)online bytes:(SharedCoreKotlinByteArray *)bytes __attribute__((swift_name("from(online:bytes:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Base64Helper")))
@interface SharedCoreBase64Helper : SharedCoreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreKotlinByteArray *)decodeData:(NSString *)data __attribute__((swift_name("decode(data:)")));
- (NSString *)encodeData:(SharedCoreKotlinByteArray *)data __attribute__((swift_name("encode(data:)")));
@end

__attribute__((swift_name("LocalizedString")))
@protocol SharedCoreLocalizedString
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringConstant")))
@interface SharedCoreLocalizedStringConstant : SharedCoreBase <SharedCoreLocalizedString>
@property (readonly) NSString *text __attribute__((swift_name("text")));
- (instancetype)initWithText:(NSString *)text __attribute__((swift_name("init(text:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreLocalizedStringConstant *)doCopyText:(NSString *)text __attribute__((swift_name("doCopy(text:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringEmpty")))
@interface SharedCoreLocalizedStringEmpty : SharedCoreBase <SharedCoreLocalizedString>
@property (class, readonly, getter=shared) SharedCoreLocalizedStringEmpty *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)empty __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringWithId")))
@interface SharedCoreLocalizedStringWithId : SharedCoreBase <SharedCoreLocalizedString>
@property (readonly) SharedCoreLocalizedStringId *id __attribute__((swift_name("id")));
- (instancetype)initWithId:(SharedCoreLocalizedStringId *)id __attribute__((swift_name("init(id:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreLocalizedStringWithId *)doCopyId:(SharedCoreLocalizedStringId *)id __attribute__((swift_name("doCopy(id:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringWithIdIntStringInt")))
@interface SharedCoreLocalizedStringWithIdIntStringInt : SharedCoreBase <SharedCoreLocalizedString>
@property (readonly) int32_t arg1 __attribute__((swift_name("arg1")));
@property (readonly) id<SharedCoreLocalizedString> arg2 __attribute__((swift_name("arg2")));
@property (readonly) int32_t arg3 __attribute__((swift_name("arg3")));
@property (readonly) SharedCoreLocalizedStringId *id __attribute__((swift_name("id")));
- (instancetype)initWithId:(SharedCoreLocalizedStringId *)id arg1:(int32_t)arg1 arg2:(id<SharedCoreLocalizedString>)arg2 arg3:(int32_t)arg3 __attribute__((swift_name("init(id:arg1:arg2:arg3:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreLocalizedStringWithIdIntStringInt *)doCopyId:(SharedCoreLocalizedStringId *)id arg1:(int32_t)arg1 arg2:(id<SharedCoreLocalizedString>)arg2 arg3:(int32_t)arg3 __attribute__((swift_name("doCopy(id:arg1:arg2:arg3:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringId")))
@interface SharedCoreLocalizedStringId : SharedCoreKotlinEnum<SharedCoreLocalizedStringId *>
@property (class, readonly) SharedCoreLocalizedStringId *generalTurnOn __attribute__((swift_name("generalTurnOn")));
@property (class, readonly) SharedCoreLocalizedStringId *generalTurnOff __attribute__((swift_name("generalTurnOff")));
@property (class, readonly) SharedCoreLocalizedStringId *generalOpen __attribute__((swift_name("generalOpen")));
@property (class, readonly) SharedCoreLocalizedStringId *generalClose __attribute__((swift_name("generalClose")));
@property (class, readonly) SharedCoreLocalizedStringId *generalOpenClose __attribute__((swift_name("generalOpenClose")));
@property (class, readonly) SharedCoreLocalizedStringId *generalShut __attribute__((swift_name("generalShut")));
@property (class, readonly) SharedCoreLocalizedStringId *generalReveal __attribute__((swift_name("generalReveal")));
@property (class, readonly) SharedCoreLocalizedStringId *generalCollapse __attribute__((swift_name("generalCollapse")));
@property (class, readonly) SharedCoreLocalizedStringId *generalExpand __attribute__((swift_name("generalExpand")));
@property (class, readonly) SharedCoreLocalizedStringId *generalYes __attribute__((swift_name("generalYes")));
@property (class, readonly) SharedCoreLocalizedStringId *generalNo __attribute__((swift_name("generalNo")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorGateway __attribute__((swift_name("channelCaptionOpenSensorGateway")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheGatewayLock __attribute__((swift_name("channelCaptionControllingTheGatewayLock")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorGate __attribute__((swift_name("channelCaptionOpenSensorGate")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheGate __attribute__((swift_name("channelCaptionControllingTheGate")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorGarageDoor __attribute__((swift_name("channelCaptionOpenSensorGarageDoor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheGarageDoor __attribute__((swift_name("channelCaptionControllingTheGarageDoor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorDoor __attribute__((swift_name("channelCaptionOpenSensorDoor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheDoorLock __attribute__((swift_name("channelCaptionControllingTheDoorLock")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorRollerShutter __attribute__((swift_name("channelCaptionOpenSensorRollerShutter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpenSensorRoofWindow __attribute__((swift_name("channelCaptionOpenSensorRoofWindow")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheRollerShutter __attribute__((swift_name("channelCaptionControllingTheRollerShutter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheRoofWindow __attribute__((swift_name("channelCaptionControllingTheRoofWindow")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionControllingTheFacadeBlind __attribute__((swift_name("channelCaptionControllingTheFacadeBlind")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionPowerSwitch __attribute__((swift_name("channelCaptionPowerSwitch")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionLightswitch __attribute__((swift_name("channelCaptionLightswitch")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionThermometer __attribute__((swift_name("channelCaptionThermometer")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionHumidity __attribute__((swift_name("channelCaptionHumidity")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionHumidityAndTemperature __attribute__((swift_name("channelCaptionHumidityAndTemperature")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionWindSensor __attribute__((swift_name("channelCaptionWindSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionPressureSensor __attribute__((swift_name("channelCaptionPressureSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionRainSensor __attribute__((swift_name("channelCaptionRainSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionWeightSensor __attribute__((swift_name("channelCaptionWeightSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionNoLiquidSensor __attribute__((swift_name("channelCaptionNoLiquidSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionDimmer __attribute__((swift_name("channelCaptionDimmer")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionRgbLighting __attribute__((swift_name("channelCaptionRgbLighting")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionDimmerAndRgbLighting __attribute__((swift_name("channelCaptionDimmerAndRgbLighting")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionDepthSensor __attribute__((swift_name("channelCaptionDepthSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionDistanceSensor __attribute__((swift_name("channelCaptionDistanceSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionOpeningSensorWindow __attribute__((swift_name("channelCaptionOpeningSensorWindow")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionHotelCardSensor __attribute__((swift_name("channelCaptionHotelCardSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionAlarmArmamentSensor __attribute__((swift_name("channelCaptionAlarmArmamentSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionMailSensor __attribute__((swift_name("channelCaptionMailSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionStaircaseTimer __attribute__((swift_name("channelCaptionStaircaseTimer")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionIcGasMeter __attribute__((swift_name("channelCaptionIcGasMeter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionIcWaterMeter __attribute__((swift_name("channelCaptionIcWaterMeter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionIcHeatMeter __attribute__((swift_name("channelCaptionIcHeatMeter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionThermostatHeatpolHomeplus __attribute__((swift_name("channelCaptionThermostatHeatpolHomeplus")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionValve __attribute__((swift_name("channelCaptionValve")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionGeneralPurposeMeasurement __attribute__((swift_name("channelCaptionGeneralPurposeMeasurement")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionGeneralPurposeMeter __attribute__((swift_name("channelCaptionGeneralPurposeMeter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionThermostat __attribute__((swift_name("channelCaptionThermostat")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionElectricityMeter __attribute__((swift_name("channelCaptionElectricityMeter")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionDigiglass __attribute__((swift_name("channelCaptionDigiglass")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionTerraceAwning __attribute__((swift_name("channelCaptionTerraceAwning")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionProjectorScreen __attribute__((swift_name("channelCaptionProjectorScreen")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionCurtain __attribute__((swift_name("channelCaptionCurtain")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionVerticalBlind __attribute__((swift_name("channelCaptionVerticalBlind")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionRollerGarageDoor __attribute__((swift_name("channelCaptionRollerGarageDoor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionPumpSwitch __attribute__((swift_name("channelCaptionPumpSwitch")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionHeatOrColdSourceSwitch __attribute__((swift_name("channelCaptionHeatOrColdSourceSwitch")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionUnknown __attribute__((swift_name("channelCaptionUnknown")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionContainer __attribute__((swift_name("channelCaptionContainer")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionSepticTank __attribute__((swift_name("channelCaptionSepticTank")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionWaterTank __attribute__((swift_name("channelCaptionWaterTank")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionContainerLevelSensor __attribute__((swift_name("channelCaptionContainerLevelSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelCaptionFloodSensor __attribute__((swift_name("channelCaptionFloodSensor")));
@property (class, readonly) SharedCoreLocalizedStringId *channelBatteryLevel __attribute__((swift_name("channelBatteryLevel")));
@property (class, readonly) SharedCoreLocalizedStringId *motorProblem __attribute__((swift_name("motorProblem")));
@property (class, readonly) SharedCoreLocalizedStringId *calibrationLost __attribute__((swift_name("calibrationLost")));
@property (class, readonly) SharedCoreLocalizedStringId *calibrationFailed __attribute__((swift_name("calibrationFailed")));
@property (class, readonly) SharedCoreLocalizedStringId *thermostatThermometerError __attribute__((swift_name("thermostatThermometerError")));
@property (class, readonly) SharedCoreLocalizedStringId *thermostatBatterCoverOpen __attribute__((swift_name("thermostatBatterCoverOpen")));
@property (class, readonly) SharedCoreLocalizedStringId *thermostatClockError __attribute__((swift_name("thermostatClockError")));
@property (class, readonly) SharedCoreLocalizedStringId *floodSensorActive __attribute__((swift_name("floodSensorActive")));
@property (class, readonly) SharedCoreLocalizedStringId *valveManuallyClosed __attribute__((swift_name("valveManuallyClosed")));
@property (class, readonly) SharedCoreLocalizedStringId *valveFlooding __attribute__((swift_name("valveFlooding")));
@property (class, readonly) NSArray<SharedCoreLocalizedStringId *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (SharedCoreKotlinArray<SharedCoreLocalizedStringId *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((swift_name("ApplicationPreferences")))
@protocol SharedCoreApplicationPreferences
@required
@property int32_t batteryWarningLevel __attribute__((swift_name("batteryWarningLevel")));
@end

__attribute__((swift_name("CacheFileAccess")))
@protocol SharedCoreCacheFileAccess
@required
- (BOOL)deleteFile:(SharedCoreCacheFileAccessFile *)file __attribute__((swift_name("delete(file:)")));
- (BOOL)dirExistsName:(NSString *)name __attribute__((swift_name("dirExists(name:)")));
- (BOOL)fileExistsFile:(SharedCoreCacheFileAccessFile *)file __attribute__((swift_name("fileExists(file:)")));
- (BOOL)mkdirName:(NSString *)name __attribute__((swift_name("mkdir(name:)")));

/**
 * @note This method converts instances of Exception to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (SharedCoreKotlinByteArray * _Nullable)readBytesFile:(SharedCoreCacheFileAccessFile *)file error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("readBytes(file:)")));

/**
 * @note This method converts instances of Exception to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)writeBytesFile:(SharedCoreCacheFileAccessFile *)file bytes:(SharedCoreKotlinByteArray *)bytes error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("writeBytes(file:bytes:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CacheFileAccessFile")))
@interface SharedCoreCacheFileAccessFile : SharedCoreBase
@property (readonly) NSString * _Nullable directory __attribute__((swift_name("directory")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
- (instancetype)initWithName:(NSString *)name directory:(NSString * _Nullable)directory __attribute__((swift_name("init(name:directory:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreCacheFileAccessFile *)doCopyName:(NSString *)name directory:(NSString * _Nullable)directory __attribute__((swift_name("doCopy(name:directory:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetCaptionUseCase")))
@interface SharedCoreGetCaptionUseCase : SharedCoreBase
- (instancetype)initWithGetChannelDefaultCaptionUseCase:(SharedCoreGetChannelDefaultCaptionUseCase *)getChannelDefaultCaptionUseCase __attribute__((swift_name("init(getChannelDefaultCaptionUseCase:)"))) __attribute__((objc_designated_initializer));
- (id<SharedCoreLocalizedString>)invokeData:(id<SharedCoreBaseData>)data __attribute__((swift_name("invoke(data:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelActionStringUseCase")))
@interface SharedCoreGetChannelActionStringUseCase : SharedCoreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreLocalizedStringId * _Nullable)leftButtonFunction:(SharedCoreSuplaFunction *)function __attribute__((swift_name("leftButton(function:)")));
- (SharedCoreLocalizedStringId * _Nullable)rightButtonFunction:(SharedCoreSuplaFunction *)function __attribute__((swift_name("rightButton(function:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CheckOcrPhotoExistsUseCase")))
@interface SharedCoreCheckOcrPhotoExistsUseCase : SharedCoreBase
- (instancetype)initWithOcrImageNamingProvider:(SharedCoreOcrImageNamingProvider *)ocrImageNamingProvider cacheFileAccess:(id<SharedCoreCacheFileAccess>)cacheFileAccess __attribute__((swift_name("init(ocrImageNamingProvider:cacheFileAccess:)"))) __attribute__((objc_designated_initializer));
- (BOOL)invokeProfileId:(int64_t)profileId remoteId:(int32_t)remoteId __attribute__((swift_name("invoke(profileId:remoteId:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelBatteryIconUseCase")))
@interface SharedCoreGetChannelBatteryIconUseCase : SharedCoreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreIssueIcon * _Nullable)invokeChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("invoke(channelWithChildren:)")));
- (SharedCoreIssueIcon * _Nullable)invokeChannel:(SharedCoreChannel *)channel __attribute__((swift_name("invoke(channel:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelDefaultCaptionUseCase")))
@interface SharedCoreGetChannelDefaultCaptionUseCase : SharedCoreBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (id<SharedCoreLocalizedString>)invokeFunction:(SharedCoreSuplaFunction *)function __attribute__((swift_name("invoke(function:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelIssuesForListUseCase")))
@interface SharedCoreGetChannelIssuesForListUseCase : SharedCoreBase
- (instancetype)initWithGetChannelLowBatteryIssueUseCase:(SharedCoreGetChannelLowBatteryIssueUseCase *)getChannelLowBatteryIssueUseCase getChannelBatteryIconUseCase:(SharedCoreGetChannelBatteryIconUseCase *)getChannelBatteryIconUseCase __attribute__((swift_name("init(getChannelLowBatteryIssueUseCase:getChannelBatteryIconUseCase:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreListItemIssues *)invokeChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("invoke(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelIssuesForSlavesUseCase")))
@interface SharedCoreGetChannelIssuesForSlavesUseCase : SharedCoreBase
- (instancetype)initWithGetChannelLowBatteryIssueUseCase:(SharedCoreGetChannelLowBatteryIssueUseCase *)getChannelLowBatteryIssueUseCase getChannelBatteryIconUseCase:(SharedCoreGetChannelBatteryIconUseCase *)getChannelBatteryIconUseCase __attribute__((swift_name("init(getChannelLowBatteryIssueUseCase:getChannelBatteryIconUseCase:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreListItemIssues *)invokeChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("invoke(channelWithChildren:)")));
- (SharedCoreListItemIssues *)invokeChannel:(SharedCoreChannel *)channel __attribute__((swift_name("invoke(channel:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelLowBatteryIssueUseCase")))
@interface SharedCoreGetChannelLowBatteryIssueUseCase : SharedCoreBase
- (instancetype)initWithGetCaptionUseCase:(SharedCoreGetCaptionUseCase *)getCaptionUseCase applicationPreferences:(id<SharedCoreApplicationPreferences>)applicationPreferences __attribute__((swift_name("init(getCaptionUseCase:applicationPreferences:)"))) __attribute__((objc_designated_initializer));
- (SharedCoreChannelIssueItem * _Nullable)invokeChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("invoke(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StoreChannelOcrPhotoUseCase")))
@interface SharedCoreStoreChannelOcrPhotoUseCase : SharedCoreBase
- (instancetype)initWithStoreFileInDirectoryUseCase:(SharedCoreStoreFileInDirectoryUseCase *)storeFileInDirectoryUseCase ocrImageNamingProvider:(SharedCoreOcrImageNamingProvider *)ocrImageNamingProvider base64Helper:(SharedCoreBase64Helper *)base64Helper __attribute__((swift_name("init(storeFileInDirectoryUseCase:ocrImageNamingProvider:base64Helper:)"))) __attribute__((objc_designated_initializer));
- (void)invokeRemoteId:(int32_t)remoteId profileId:(int64_t)profileId photo:(SharedCoreImpulseCounterPhotoDto *)photo __attribute__((swift_name("invoke(remoteId:profileId:photo:)")));
@end

__attribute__((swift_name("ChannelIssuesProvider")))
@protocol SharedCoreChannelIssuesProvider
@required
- (NSArray<SharedCoreChannelIssueItem *> *)provideChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("provide(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContainerIssuesProvider")))
@interface SharedCoreContainerIssuesProvider : SharedCoreBase <SharedCoreChannelIssuesProvider>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSArray<SharedCoreChannelIssueItem *> *)provideChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("provide(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ShadingSystemIssuesProvider")))
@interface SharedCoreShadingSystemIssuesProvider : SharedCoreBase <SharedCoreChannelIssuesProvider>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSArray<SharedCoreChannelIssueItem *> *)provideChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("provide(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ThermostatIssuesProvider")))
@interface SharedCoreThermostatIssuesProvider : SharedCoreBase <SharedCoreChannelIssuesProvider>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSArray<SharedCoreChannelIssueItem *> *)provideChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("provide(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ValveIssuesProvider")))
@interface SharedCoreValveIssuesProvider : SharedCoreBase <SharedCoreChannelIssuesProvider>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSArray<SharedCoreChannelIssueItem *> *)provideChannelWithChildren:(SharedCoreChannelWithChildren *)channelWithChildren __attribute__((swift_name("provide(channelWithChildren:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OcrImageNamingProvider")))
@interface SharedCoreOcrImageNamingProvider : SharedCoreBase
@property (readonly) NSString *directory __attribute__((swift_name("directory")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSString *)imageCroppedNameProfileId:(int64_t)profileId remoteId:(int32_t)remoteId __attribute__((swift_name("imageCroppedName(profileId:remoteId:)")));
- (NSString *)imageNameProfileId:(int64_t)profileId remoteId:(int32_t)remoteId __attribute__((swift_name("imageName(profileId:remoteId:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StoreFileInDirectoryUseCase")))
@interface SharedCoreStoreFileInDirectoryUseCase : SharedCoreBase
- (instancetype)initWithCacheFileAccess:(id<SharedCoreCacheFileAccess>)cacheFileAccess __attribute__((swift_name("init(cacheFileAccess:)"))) __attribute__((objc_designated_initializer));
- (void)invokeDirectoryName:(NSString *)directoryName fileName:(NSString *)fileName fileData:(SharedCoreKotlinByteArray *)fileData __attribute__((swift_name("invoke(directoryName:fileName:fileData:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinByteArray")))
@interface SharedCoreKotlinByteArray : SharedCoreBase
@property (readonly) int32_t size __attribute__((swift_name("size")));
+ (instancetype)arrayWithSize:(int32_t)size __attribute__((swift_name("init(size:)")));
+ (instancetype)arrayWithSize:(int32_t)size init:(SharedCoreByte *(^)(SharedCoreInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (int8_t)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (SharedCoreKotlinByteIterator *)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(int8_t)value __attribute__((swift_name("set(index:value:)")));
@end

@interface SharedCoreKotlinByteArray (Extensions)
- (NSString *)toHexSeparator:(NSString *)separator __attribute__((swift_name("toHex(separator:)")));
- (int16_t)toShortFirst:(int32_t)first second:(int32_t)second __attribute__((swift_name("toShort(first:second:)")));
- (float)toTemperatureFirst:(int32_t)first second:(int32_t)second __attribute__((swift_name("toTemperature(first:second:)")));
@end

@interface SharedCoreChannel (Extensions)
@property (readonly) SharedCoreContainerValue * _Nullable containerValue __attribute__((swift_name("containerValue")));
@property (readonly) SharedCoreFacadeBlindValue * _Nullable facadeBlindValue __attribute__((swift_name("facadeBlindValue")));
@property (readonly) BOOL isFacadeBlind __attribute__((swift_name("isFacadeBlind")));
@property (readonly) BOOL isGarageDoorRoller __attribute__((swift_name("isGarageDoorRoller")));
@property (readonly) BOOL isHvacThermostat __attribute__((swift_name("isHvacThermostat")));
@property (readonly) BOOL isProjectorScreen __attribute__((swift_name("isProjectorScreen")));
@property (readonly) BOOL isShadingSystem __attribute__((swift_name("isShadingSystem")));
@property (readonly) BOOL isThermostat __attribute__((swift_name("isThermostat")));
@property (readonly) BOOL isVerticalBlind __attribute__((swift_name("isVerticalBlind")));
@property (readonly) SharedCoreRollerShutterValue * _Nullable rollerShutterValue __attribute__((swift_name("rollerShutterValue")));
@property (readonly) SharedCoreThermostatValue * _Nullable thermostatValue __attribute__((swift_name("thermostatValue")));
@property (readonly) SharedCoreValveValue * _Nullable valveValue __attribute__((swift_name("valveValue")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BooleanExtensionsKt")))
@interface SharedCoreBooleanExtensionsKt : SharedCoreBase
+ (id<SharedCoreLocalizedString>)localizedString:(BOOL)receiver __attribute__((swift_name("localizedString(_:)")));
+ (id _Nullable)ifFalse:(BOOL)receiver value:(id _Nullable)value __attribute__((swift_name("ifFalse(_:value:)")));
+ (id _Nullable)ifTrue:(BOOL)receiver value:(id _Nullable)value __attribute__((swift_name("ifTrue(_:value:)")));
+ (id _Nullable)ifTrue:(BOOL)receiver valueProvider:(id _Nullable (^)(void))valueProvider __attribute__((swift_name("ifTrue(_:valueProvider:)")));
+ (void)ifTrueValue:(BOOL)value callback:(void (^)(void))callback __attribute__((swift_name("ifTrue(value:callback:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetChannelIssuesForListUseCaseKt")))
@interface SharedCoreGetChannelIssuesForListUseCaseKt : SharedCoreBase
+ (BOOL)isNull:(id _Nullable)receiver __attribute__((swift_name("isNull(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LocalizedStringKt")))
@interface SharedCoreLocalizedStringKt : SharedCoreBase
+ (id<SharedCoreLocalizedString>)localizedStringId:(SharedCoreLocalizedStringId * _Nullable)id __attribute__((swift_name("localizedString(id:)")));
+ (id<SharedCoreLocalizedString>)localizedStringId:(SharedCoreLocalizedStringId *)id arg1:(int32_t)arg1 arg2:(id<SharedCoreLocalizedString>)arg2 arg3:(int32_t)arg3 __attribute__((swift_name("localizedString(id:arg1:arg2:arg3:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ShortExtensionsKt")))
@interface SharedCoreShortExtensionsKt : SharedCoreBase
+ (float)fromSuplaTemperature:(int16_t)receiver __attribute__((swift_name("fromSuplaTemperature(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringExtensionsKt")))
@interface SharedCoreStringExtensionsKt : SharedCoreBase
+ (id<SharedCoreLocalizedString>)localized:(NSString *)receiver __attribute__((swift_name("localized(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SuplaFunctionKt")))
@interface SharedCoreSuplaFunctionKt : SharedCoreBase
+ (SharedCoreSuplaFunction *)suplaFunction:(int32_t)receiver __attribute__((swift_name("suplaFunction(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface SharedCoreKotlinEnumCompanion : SharedCoreBase
@property (class, readonly, getter=shared) SharedCoreKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface SharedCoreKotlinArray<T> : SharedCoreBase
@property (readonly) int32_t size __attribute__((swift_name("size")));
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(SharedCoreInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<SharedCoreKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@end

__attribute__((swift_name("KotlinThrowable")))
@interface SharedCoreKotlinThrowable : SharedCoreBase
@property (readonly) SharedCoreKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedCoreKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedCoreKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));

/**
 * @note annotations
 *   kotlin.experimental.ExperimentalNativeApi
*/
- (SharedCoreKotlinArray<NSString *> *)getStackTrace __attribute__((swift_name("getStackTrace()")));
- (void)printStackTrace __attribute__((swift_name("printStackTrace()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSError *)asError __attribute__((swift_name("asError()")));
@end

__attribute__((swift_name("KotlinException")))
@interface SharedCoreKotlinException : SharedCoreKotlinThrowable
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedCoreKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedCoreKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol SharedCoreKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((swift_name("KotlinByteIterator")))
@interface SharedCoreKotlinByteIterator : SharedCoreBase <SharedCoreKotlinIterator>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedCoreByte *)next __attribute__((swift_name("next()")));
- (int8_t)nextByte __attribute__((swift_name("nextByte()")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
