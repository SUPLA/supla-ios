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

private let BACKGROUND_UNLOCKED_TIME_DEBUG_S: Double = 10
private let BACKGROUND_UNLOCKED_TIME_S: Double = 120

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow? = nil
    
    @Singleton private var settings: GlobalSettings
    @Singleton private var insertNotificationUseCase: InsertNotificationUseCase
    @Singleton private var coordinator: SuplaAppCoordinator
    @Singleton private var suplaAppStateHolder: SuplaAppStateHolder
    @Singleton private var disconnectUseCase: DisconnectUseCase
    @Singleton private var dateProvider: DateProvider
    
    private var clientStopWork: DispatchWorkItem? = nil
    private var wasInBackground = true
    
    private var backgroundUnlockedTime: Double {
        #if DEBUG
        BACKGROUND_UNLOCKED_TIME_DEBUG_S
        #else
        BACKGROUND_UNLOCKED_TIME_S
        #endif
    }
    
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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
            coordinator.attachToWindow(window)
            coordinator.start(animated: true)
        }
        
        CoreDataManager.shared.setup {
            DispatchQueue.global(qos: .userInitiated).async {
                InitializationUseCase.invoke()
            }
        }
        
        registerForNotifications()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SALog.debug("Application did become active")
        
        #if DEBUG
        if (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) {
            return
        }
        #endif
        
        if wasInBackground && settings.lockScreenSettings.pinForAppRequired,
           let backgroundEntryTime = settings.backgroundEntryTime,
           dateProvider.currentTimestamp() - backgroundEntryTime > backgroundUnlockedTime
        {
            suplaAppStateHolder.handle(event: .lock)
        } else {
            suplaAppStateHolder.handle(event: .onStart)
        }
        
        wasInBackground = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SALog.debug("Application did enter background")
        wasInBackground = true
        
        settings.backgroundEntryTime = dateProvider.currentTimestamp()
        
        disconnectUseCase.invokeSynchronous(reason: .appInBackground)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    private func registerForNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] (granted, error) in
            
            if (granted) {
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            } else {
                SALog.error("Notifications not allowed \(String(describing: error))")
                self?.settings.pushToken = nil
            }
        }
    }
}
