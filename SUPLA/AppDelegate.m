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

#import "AppDelegate.h"
#import "SuplaApp.h"
#import "SUPLA-Swift.h"
#import "SADialog.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (id) init {
    self = [super init];
    
    // Setup dependency injection
    [DiContainer start];
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef DEBUG
    // Short-circuit starting app if running unit tests
    BOOL isInTest = NSProcessInfo.processInfo.environment[@"XCTestConfigurationFilePath"] != nil;
    if (isInTest) {
        return YES;
    }
#endif
    
    // Override point for customization after application launch.
    self.navigation = [[MainNavigationCoordinator alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.navigation attachTo: self.window];
    
    [CoreDataManager.shared setupWithCompletion: ^() {
        [self.navigation startFrom:nil];
        
        // Start SuplaClient only after the status window is displayed.
        // Otherwise - with empty settings, the user will see the message "Host not found"
        // instead of the settings window.
        [SAApp SuplaClient];
    }];

    [self registerForNotifications];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    id pc = SAApp.currentNavigationCoordinator.viewController.presentedViewController;
    if([pc isKindOfClass: [SADialog class]]) {
        [((SADialog*)pc) close];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ( ![SAApp.currentNavigationCoordinator.viewController isKindOfClass: [SAAddWizardVC class]] ) {
        [SAApp SuplaClientWaitForTerminate];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#ifdef DEBUG
    // Short-circuit starting app if running unit tests
    BOOL isInTest = NSProcessInfo.processInfo.environment[@"XCTestConfigurationFilePath"] != nil;
    if (isInTest) {
        return;
    }
#endif
    
    id vc = [SAApp currentNavigationCoordinator].viewController;
    if ( ![vc isKindOfClass: [SAAddWizardVC class]] ) {
        // TODO: such checks should be solved in a generic way by coordintators
        [SAApp SuplaClient];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark Notifications

- (void) registerForNotifications {
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions: (UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler: ^(BOOL granted, NSError * _Nullable error) {
        
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication.sharedApplication registerForRemoteNotifications];
            });
        } else {
            NSLog(@"Notifications not allowed %@", error);
        }
    }];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#ifdef DEBUG
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhx", data[i]];
    }
    NSLog(@"Push token: %@", token);
#endif

    [DiContainer setPushTokenWithToken: deviceToken];
    if ([[SAApp SuplaClient] isRegistered]) {
        [[SAApp SuplaClient] registerPushNotificationClientToken:deviceToken appId:APP_ID];
    }
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications with error %@", error);
}

- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

@end
