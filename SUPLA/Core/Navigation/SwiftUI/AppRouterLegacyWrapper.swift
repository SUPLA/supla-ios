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

import UIKit

@objc
final class AppRouterLegacyWrapper: NSObject {
    @objc
    static func finish() {
        @Singleton<AppRouter> var router
        router.back()
    }

    @objc
    static func currentViewController() -> UIViewController? {
        guard let rootController = UIApplication.shared.connectedScenes
            .compactMap({ ($0.delegate as? SceneDelegate)?.window?.rootViewController })
            .first
        else {
            return nil
        }

        return getPresentedController(rootController)
    }

    private static func getPresentedController(_ controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return getPresentedController(presentedController)
        }

        return controller
    }
}
