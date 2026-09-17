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

import Combine
import SwiftUI

private final class StatusBarHostingController<Content: View>: UIHostingController<Content> {
    private let appRouter: AppRouter
    private var cancellable: AnyCancellable?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        appRouter.root == .status ? .darkContent : .lightContent
    }

    override var childForStatusBarStyle: UIViewController? {
        nil
    }

    init(rootView: Content, appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(rootView: rootView)
        cancellable = appRouter.$root
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        nil
    }
}

private let BACKGROUND_UNLOCKED_TIME_DEBUG_S: Double = 10
private let BACKGROUND_UNLOCKED_TIME_S: Double = 120

struct BackgroundDisconnectState {
    private(set) var isInProgress = false
    private var pendingActivationEvent: SuplaAppEvent?

    mutating func start() -> Bool {
        pendingActivationEvent = nil

        guard !isInProgress else { return false }

        isInProgress = true
        return true
    }

    mutating func handleActivation(_ event: SuplaAppEvent) -> SuplaAppEvent? {
        guard isInProgress else { return event }

        pendingActivationEvent = event
        return nil
    }

    mutating func finish() -> SuplaAppEvent? {
        isInProgress = false
        defer { pendingActivationEvent = nil }
        return pendingActivationEvent
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Singleton private var settings: GlobalSettings
    @Singleton private var dateProvider: DateProvider
    @Singleton private var disconnectUseCase: DisconnectUseCase
    @Singleton private var suplaAppStateHolder: SuplaAppStateHolder
    @Singleton private var appRouter: AppRouter
    @Singleton private var authorizationCoordinator: AuthorizationCoordinator

    var window: UIWindow?

    private var wasInBackground = true
    private var backgroundDisconnectState = BackgroundDisconnectState()
    private var backgroundTask = UIBackgroundTaskIdentifier.invalid
    private var backgroundUnlockedTime: Double {
        #if DEBUG
        BACKGROUND_UNLOCKED_TIME_DEBUG_S
        #else
        BACKGROUND_UNLOCKED_TIME_S
        #endif
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if DEBUG
        // Short-circuit starting app if running unit tests
        if (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) {
            return
        }
        #endif

        let rootView = AppRootView()
            .environmentObject(appRouter)
            .environmentObject(authorizationCoordinator as! AuthorizationCoordinatorImpl)

        let hostingController = StatusBarHostingController(rootView: rootView, appRouter: appRouter)
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
        appRouter.start()

        if let userActivities = connectionOptions.userActivities.first,
           userActivities.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivities.webpageURL
        {
            handleDeepLink(url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else {
            return
        }
        handleDeepLink(url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        SALog.debug("Application did become active")

        #if DEBUG
        if (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) {
            return
        }
        #endif

        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if (isPreview) {
            return
        }

        let activationEvent: SuplaAppEvent
        if wasInBackground && settings.lockScreenSettings.pinForAppRequired,
           let backgroundEntryTime = settings.backgroundEntryTime,
           dateProvider.currentTimestamp() - backgroundEntryTime > backgroundUnlockedTime
        {
            activationEvent = .lock
        } else {
            activationEvent = .onStart
        }

        wasInBackground = false

        if let event = backgroundDisconnectState.handleActivation(activationEvent) {
            suplaAppStateHolder.handle(event: event)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        SALog.debug("Application did enter background")
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if (isPreview) {
            return
        }

        wasInBackground = true

        settings.backgroundEntryTime = dateProvider.currentTimestamp()

        disconnectInBackground(reason: .appInBackground)
    }

    private func disconnectInBackground(reason: SuplaAppState.Reason) {
        guard backgroundDisconnectState.start() else { return }

        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Disconnect") { [weak self] in
            self?.endBackgroundTask()
        }

        let disconnectUseCase = disconnectUseCase
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            disconnectUseCase.invokeSynchronous(reason: reason)

            DispatchQueue.main.async {
                self?.backgroundDisconnectDidFinish()
            }
        }
    }

    private func backgroundDisconnectDidFinish() {
        let activationEvent = backgroundDisconnectState.finish()
        endBackgroundTask()

        if let activationEvent {
            suplaAppStateHolder.handle(event: activationEvent)
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }

        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    private func handleDeepLink(_ url: URL) {
        appRouter.handleDeepLink(url)
    }
}
