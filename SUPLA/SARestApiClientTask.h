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
#import "SAOAuthToken.h"
#import "Database.h"

NS_ASSUME_NONNULL_BEGIN


@class SARestApiClientTask;
@protocol SARestApiClientTaskDelegate <NSObject>

@optional
-(void) onRestApiTaskStarted: (SARestApiClientTask*)task;
-(void) onRestApiTaskFinished: (SARestApiClientTask*)task;
-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress;

@end

@interface SAApiRequestResult : NSObject
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) int totalCount;
@property (nonatomic, strong) _Nullable id jsonObject;
@property (nonatomic, strong) NSError *error;
@end

@interface SARestApiClientTask : NSThread <NSURLSessionDelegate>
- (SADatabase*) DB;
- (SAOAuthToken *) getTokenWhenIsAlive;
- (BOOL) isTaskIsAliveWithTimeout:(int)timeout;
- (void) keepTaskAlive;
- (void) onProgressUpdate:(float)progress;
- (SAApiRequestResult *) apiRequestForEndpoint:(NSString *)endpoint;

@property (atomic, strong) SAOAuthToken *token;
@property (weak, nonatomic) id<SARestApiClientTaskDelegate> delegate;
@property (atomic) int channelId;
@end

NS_ASSUME_NONNULL_END
