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

import LocalAuthentication

extension PinSetupFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<GlobalSettings> private var settings
        @Singleton<SuplaAppCoordinator> private var coordinator

        init() {
            super.init(state: ViewState())
        }

        override func onViewDidLoad() {
            let context = LAContext()
            var error: NSError?
            state.biometricPossible = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        }

        func onAppear() {
            state.focused = .pin
        }

        func onPinChange(_ pin: String) {
            if (pin.count == PIN_LENGTH) {
                state.focused = .secondPin
            }
        }

        func onSaveClick(_ scope: LockScreenScope) {
            if (state.pin.count == PIN_LENGTH && state.pin == state.secondPin) {
                setupLockScreen(scope)
            } else {
                state.pin = ""
                state.secondPin = ""
                state.errorString = Strings.PinSetup.different

                state.focused = .pin
            }
        }

        private func setupLockScreen(_ scope: LockScreenScope) {
            let pinHash = state.pin.sha1()
            settings.lockScreenSettings = LockScreenSettings(scope: scope, pinSum: pinHash, biometricAllowed: state.biometricAllowed)
            coordinator.popViewController()
        }
    }
}
