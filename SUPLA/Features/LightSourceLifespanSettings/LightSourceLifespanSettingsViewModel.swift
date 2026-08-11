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

extension LightSourceLifespanSettingsFeature {
    class ViewModel: SuplaCore.Dialog.ViewModel {
        @Singleton<AuthorizationCoordinator> private var authorizationCoordinator
        @Singleton<SuplaClientProvider> private var suplaClientProvider

        @Published private(set) var title: String = ""
        @Published var lifespan: String = ""
        @Published var resetCounter: Bool = false

        private var remoteId: Int32 = 0
        private var initialLifespan: Int32 = 0

        init(
            title: String = "",
            lifespan: Int32 = 0,
            resetCounter: Bool = false
        ) {
            self.title = title
            self.lifespan = "\(lifespan)"
            self.resetCounter = resetCounter
            self.initialLifespan = lifespan
        }

        func show(remoteId: Int32, title: String, lightSourceLifespan: Int32) {
            Task { @MainActor [weak self] in
                self?.authorizationCoordinator.authorize(
                    onAuthorized: { [weak self] in
                        self?.showAuthorized(
                            remoteId: remoteId,
                            title: title,
                            lightSourceLifespan: lightSourceLifespan
                        )
                    }
                )
            }
        }

        func hide() {
            present = false
        }

        func onApply() {
            let value = boundedLifespan
            let shouldSetTime = value != initialLifespan

            if shouldSetTime || resetCounter {
                suplaClientProvider.provide()?.setLightsourceLifespanWithChannelId(
                    remoteId,
                    resetCounter: resetCounter,
                    setTime: shouldSetTime,
                    lifespan: UInt16(value)
                )
            }

            hide()
        }

        private func showAuthorized(remoteId: Int32, title: String, lightSourceLifespan: Int32) {
            self.remoteId = remoteId
            self.title = title
            self.initialLifespan = lightSourceLifespan
            self.lifespan = "\(lightSourceLifespan)"
            resetCounter = false

            present = true
        }

        private var boundedLifespan: Int32 {
            let value = Int32(lifespan) ?? 0
            return min(max(value, 0), Int32(UInt16.max))
        }
    }
}
