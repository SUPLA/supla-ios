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
#import "UIHelper.h"
#import "SuplaClient.h"
#include "proto.h"
#include "SAChannelStateExtendedValue.h"

#define ABSTRACT_METHOD_EXCEPTION [SAApp abstractMethodException:NSStringFromSelector(_cmd)]

@class SADatabase;
@class SASettingsVC;
@class SAStatusVC;
@class SAMainVC;
@class SACreateAccountVC;
@interface SAApp : NSObject <SASuplaClientDelegate>

+(SAApp*)instance;
+(BOOL) getClientGUID:(char[SUPLA_GUID_SIZE])guid;
+(BOOL) getAuthKey:(char[SUPLA_AUTHKEY_SIZE])auth_key;
+(int) getAccessID;
+(void) setAccessID:(int)aid;
+(NSString*) getAccessIDpwd;
+(void) setAccessIDpwd:(NSString *)pwd;
+(NSString*) getServerHostName;
+(NSString*) getEmailAddress;
+(BOOL) isAdvancedConfig;
+(void) setServerHostName:(NSString *)hostname;
+(void) setEmailAddress:(NSString *)email;
+(void) setAdvancedConfig:(BOOL)adv_cfg;
+(void) abstractMethodException:(NSString *)methodName;
+(NSURL *)applicationDocumentsDirectory;
+(BOOL) configIsSet;
+(void) setBrightnessPickerTypeToSlider:(BOOL)slider;
+(BOOL) isBrightnessPickerTypeSet;
+(BOOL) isBrightnessPickerTypeSlider;

+(void)initClientDelayed:(double)time;
+(SASuplaClient *) SuplaClient;
+(SASuplaClient *) SuplaClientWithOneTimePassword:(NSString*)password;
+(BOOL) isClientRegistered;
+(SADatabase *) DB;
+(SAUIHelper *)UI;


+(void) SuplaClientTerminate;
+(void) SuplaClientWaitForTerminate;
+(BOOL) SuplaClientConnected;
+(void) revokeOAuthToken;

+(void) setPreferedProtocolVersion:(int)version;
+(int) getPreferedProtocolVersion;

-(SAOAuthToken*) registerRestApiClientTask:(SARestApiClientTask *)client;
-(void) unregisterRestApiClientTask:(SARestApiClientTask *)task;
-(void) cancelAllRestApiClientTasks;
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
