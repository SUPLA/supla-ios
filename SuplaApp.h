/*
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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIHelper.h"
#import "SuplaClient.h"
#include "proto.h"

@class SADatabase;
@class SASettingsVC;
@class SAStatusVC;
@class SAMainVC;
@interface SAApp : NSObject

+(SAApp*)instance;
+(void) getClientGUID:(char[SUPLA_GUID_SIZE])guid;
+(int) getAccessID;
+(void) setAccessID:(int)aid;
+(NSString*) getAccessIDpwd;
+(void) setAccessIDpwd:(NSString *)pwd;
+(NSString*) getServerHostName;
+(void) setServerHostName:(NSString *)hostname;
+(NSURL *)applicationDocumentsDirectory;

+(void)initClientDelayed:(double)time;
+(SASuplaClient *) SuplaClient;
+(SADatabase *) DB;
+(SAUIHelper *)UI;


+(void) SuplaClientTerminate;
+(void) SuplaClientWaitForTerminate;
+(BOOL) SuplaClientConnected;

-(void)onDataChanged;
-(void)onConnecting;
-(void)onRegistered:(SARegResult*)result;
-(void)onRegistering;
-(void)onRegisterError:(NSNumber*)code;
-(void)onDisconnected;
-(void)onConnected;
-(void)onVersionError:(SAVersionError*)ve;
-(void)onEvent:(SAEvent*)event;
-(void)onTerminated:(SASuplaClient*)sender;

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