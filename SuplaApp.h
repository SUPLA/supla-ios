/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SAOAuthToken.h"
#import "SARestApiClientTask.h"
#import "SuplaClient.h"
#import "proto.h"
#import "SAChannelStateExtendedValue.h"

#define ABSTRACT_METHOD_EXCEPTION [SAApp abstractMethodException:NSStringFromSelector(_cmd)]
 
@class SADatabase;
@class SASettingsVC;
@class SACreateAccountVC;
@protocol ProfileManager;

@protocol SuplaAppApi <NSObject>

-(void) cancelAllRestApiClientTasks;
-(BOOL) isClientRegistered;
-(BOOL) isClientWorking;
-(BOOL) isClientAuthorized;

@end

NS_ASSUME_NONNULL_BEGIN
@interface SAApp : NSObject <SASuplaClientDelegate, SuplaAppApi>

+(SAApp*)instance;
+(BOOL) getClientGUID:(char[_Nullable SUPLA_GUID_SIZE])guid DEPRECATED_ATTRIBUTE;
+(BOOL) getAuthKey:(char[_Nullable SUPLA_AUTHKEY_SIZE])auth_key DEPRECATED_ATTRIBUTE;
+(void) abstractMethodException:(NSString *)methodName;
+(NSURL *)applicationDocumentsDirectory;
+(void) setBrightnessPickerTypeToSlider:(BOOL)slider;
+(BOOL) isBrightnessPickerTypeSet;
+(BOOL) isBrightnessPickerTypeSlider;

+(SASuplaClient *) SuplaClient;
+(SASuplaClient *) SuplaClientWithOneTimePassword:(NSString*)password;
+(BOOL) isClientRegistered;
+(SADatabase *) DB;
+(nonnull id<ProfileManager>)profileManager;


+(void) SuplaClientTerminate;
+(void) SuplaClientWaitForTerminate;
+(BOOL) SuplaClientConnected;
+(void) revokeOAuthToken;

-(SAOAuthToken*) registerRestApiClientTask:(SARestApiClientTask *)client;
-(void) unregisterRestApiClientTask:(SARestApiClientTask *)task;
-(void) cancelAllRestApiClientTasks;
-(bool) isClientWorking;
-(SASuplaClient *) optionalSuplaClient;
@end

extern NSString *kSADataChangedNotification;
extern NSString *kSAConnectingNotification;
extern NSString *kSARegisteredNotification;
extern NSString *kSARegisteringNotification;
extern NSString *kSARegisterErrorNotification;
extern NSString *kSADisconnectedNotification;
extern NSString *kSAConnectedNotification;
extern NSString *kSAVersionErrorNotification;
extern NSString *kSAEventNotification;
extern NSString *kSAConnErrorNotification;
extern NSString *kSAChannelValueChangedNotification;
extern NSString *kSARegistrationEnabledNotification;
extern NSString *kSASuperuserAuthorizationNotification;

extern NSString *kSAOAuthTokenRequestResult;
extern NSString *kSASuperuserAuthorizationResult;
extern NSString *kSACalCfgResult;
extern NSString *kSAMenubarBackButtonPressed;
extern NSString *kSAOnChannelState;
extern NSString *kSAOnSetRegistrationEnableResult;
extern NSString *kSAOnChannelBasicCfg;
extern NSString *kSAOnChannelCaptionSetResult;
extern NSString *kSAOnChannelFunctionSetResult;
extern NSString *kSAOnZWaveAssignedNodeIdResult;
extern NSString *kSAOnZWaveNodeListResult;
extern NSString *kSAOnCalCfgProgressReport;
extern NSString *kSAOnZWaveResetAndClearResult;
extern NSString *kSAOnZWaveAddNodeResult;
extern NSString *kSAOnZWaveRemoveNodeResult;
extern NSString *kSAOnZWaveAssignNodeIdResult;
extern NSString *kSAOnZWaveWakeupSettingsReport;
extern NSString *kSAOnZWaveSetWakeUpTimeResult;
extern NSString *kSAOnChannelGroupCaptionSetResult;
NS_ASSUME_NONNULL_END
