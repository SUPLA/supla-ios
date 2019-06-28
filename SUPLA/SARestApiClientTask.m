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

#import "SARestApiClientTask.h"
#import "SuplaApp.h"

@implementation SARestApiClientTask {
    int _activityTime;
    NSCondition *thread_cnd;
    SAOAuthToken *_token;
}

@synthesize delegate;
@synthesize channelId;

- (void)setToken:(SAOAuthToken *)token {
    @synchronized(self) {
        _token = token;
        [thread_cnd signal];
    }
}

- (SAOAuthToken*) token {
    SAOAuthToken *token = nil;
    @synchronized(self) {
        token = _token;
    }
    return token;
}

- (id) init {
    if (self = [super init]) {
        thread_cnd = [[NSCondition alloc] init];
    }
    return self;
}

- (SAOAuthToken *) getTokenWhenIsAlive {
    SAOAuthToken *token = self.token;
    return token != nil && [token isAlive] ? token : nil;
}

-(void) _onStarted {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(onRestApiTaskStarted:)]) {
        [self.delegate onRestApiTaskStarted:self];
    }
}

-(void) _onFinished {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(onRestApiTaskFinished:)]) {
        [self.delegate onRestApiTaskFinished:self];
    }
}

-(void) _onProgressUpdate:(NSNumber *)progress {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(onRestApiTask:progressUpdate:)] ) {
        [self.delegate onRestApiTask:self progressUpdate:[progress floatValue]];
    }
}

-(void) onStarted {
    [self performSelectorOnMainThread:@selector(_onStarted) withObject:nil waitUntilDone:NO];
}

-(void) onFinished {
    [self performSelectorOnMainThread:@selector(_onFinished) withObject:nil waitUntilDone:NO];
}

-(void) onProgressUpdate:(float)progress {
    [self performSelectorOnMainThread:@selector(_onProgressUpdate:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:NO];
}

- (BOOL) isTaskIsAliveWithTimeout:(int)timeout {
    BOOL result = false;
    @synchronized (self) {
        result = !self.isCancelled
        && (_activityTime - [[NSDate date] timeIntervalSince1970]) < timeout;
    }
    
    return result;
}

- (void) keepTaskAlive {
    _activityTime = [[NSDate date] timeIntervalSince1970];
}

- (void)performTokenRequest {
    SAOAuthToken *token = self.token;
    if (token && [token isAlive]) {
        return;
    }
    
    [SAApp.SuplaClient OAuthTokenRequest];
    [thread_cnd waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];

}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

- (void)apiRequestForEndpoint:(NSString *)endpoint retry:(BOOL)retry {
    [self performTokenRequest];
    SAOAuthToken *token = self.token;
    
    if (token == nil || !token.isAlive) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/2.2.0/%@", token.url, endpoint]];
    if (url == nil) {
        return;
    }
    
    NSURLSession *session = nil;
    
    if ([[url host] containsString:@".supla.org"]) {
         session = [NSURLSession sharedSession];
    } else {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    NSCondition *cond = [[NSCondition alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token.tokenString] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@ %@", response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [cond signal];
    }];
    [dataTask resume];
    
    [cond waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:120]];
    NSLog(@"bbb");
  
}

- (void)apiRequestForEndpoint:(NSString *)endpoint {
    [self apiRequestForEndpoint:endpoint retry:YES];
}

- (void)task {}

- (void)main {
    self.token = [SAApp.instance registerRestApiClientTask:self];

    [self keepTaskAlive];
    [self onStarted];

    [self task];

    [SAApp.instance unregisterRestApiClientTask:self];
    [self onFinished];
}



@end
