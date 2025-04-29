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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Singleton private var settings: GlobalSettings
    @Singleton private var coordinator: SuplaAppCoordinator

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if DEBUG
        // Short-circuit starting app if running unit tests
        if (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) {
            return
        }
        #endif

        window = UIWindow(windowScene: windowScene)
        if let window {
            window.overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
            coordinator.attachToWindow(window)
            coordinator.start(animated: true)
        }
    }
}
