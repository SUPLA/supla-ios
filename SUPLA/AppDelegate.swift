//
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

import Foundation

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Singleton private var settings: GlobalSettings
    @Singleton private var insertNotificationUseCase: InsertNotificationUseCase
    
    override init() {
        SALogWrapper.setup()
        DiContainer.start()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        SALog.debug("Application did finish launching with options")
        
        #if DEBUG
        // Short-circuit starting app if running unit tests
        if (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) {
            return true
        }
        #endif
        
        CoreDataManager.shared.setup {
            DispatchQueue.global(qos: .userInitiated).async {
                InitializationUseCase.invoke()
            }
        }
        
        registerForNotifications()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        SALog.debug("Push token: \(token)")
        #endif
        
        settings.pushToken = deviceToken
        UpdateTokenTask().update(token: deviceToken) { SALog.info("Token update task finished") }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        SALog.error("Failed to register for remote notifications with error \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        SALog.debug("Application did receive remote notification")
        
        do {
            try insertNotificationUseCase.invoke(userInfo: userInfo).subscribeSynchronous()
        } catch {
            SALog.error("Could not insert notification: \(String(describing: error))")
        }
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (settings.screenRotationEnabled) {
            return .all
        } else {
            return .portrait
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    private func registerForNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .carPlay]) { [weak self] (granted, error) in
            
            if (granted) {
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            } else {
                SALog.error("Notifications not allowed \(String(describing: error))")
                self?.settings.pushToken = nil
            }
        }
    }
}
