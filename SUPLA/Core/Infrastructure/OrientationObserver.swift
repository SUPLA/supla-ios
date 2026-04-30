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

class OrientationObserver: ObservableObject {
    @Published var orientation: UIDeviceOrientation

    private var cancellable: AnyCancellable?

    init() {
        @Singleton<GlobalSettings> var settings
        if (settings.screenRotationEnabled) {
            orientation = UIDevice.current.orientation
        } else {
            orientation = .portrait
        }
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        cancellable = NotificationCenter.default.publisher(
            for: UIDevice.orientationDidChangeNotification
        )
        .compactMap { _ in
            if (settings.screenRotationEnabled) {
                UIDevice.current.orientation
            } else {
                .portrait
            }
        }
        .assign(to: \.orientation, on: self)
    }
}
