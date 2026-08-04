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

extension LockScreenFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton<CheckPinUseCase> private var checkPinUseCase
        @Singleton<GlobalSettings> private var settings
        @Singleton<AppRouter> private var router
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<DateProvider> private var dateProvider
        
        init(unlockAction: UnlockAction? = nil) {
            super.init(state: ViewState())
            state.unlockAction = unlockAction
        }
        
        override func onViewAppear() {
            let lockScreenSettings = settings.lockScreenSettings
            state.biometricAllowed = lockScreenSettings.biometricAllowed
            state.lockedTime = lockScreenSettings.lockTime
            
            let context = LAContext()
            var error: NSError?
            
            if (!lockScreenSettings.isLocked(dateProvider) && lockScreenSettings.biometricAllowed && context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Strings.LockScreen.biometricPromptReason) { [weak self] success, _ in
                    DispatchQueue.main.async {
                        if (success) {
                            self?.verifyPin(.biometricGranted)
                        }
                    }
                }
            }
        }
        
        func setUnlockAction(_ unlockAction: UnlockAction) {
            state.unlockAction = unlockAction
        }
        
        func onPinChange(_ pin: String) {
            if (pin.count > 0) {
                state.wrongPin = false
            }
            
            if (pin.count == PIN_LENGTH) {
                verifyPin(.checkPin(pin: pin))
            }
        }
        
        private func verifyPin(_ pinAction: CheckPinAction) {
            guard let unlockAction = state.unlockAction else { return }
            checkPinUseCase.invoke(unlockAction: unlockAction, pinAction: pinAction)
                .subscribe(on: schedulers.background)
                .observe(on: schedulers.main)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in
                        switch ($0) {
                        case .unlocked:
                            switch (unlockAction) {
                            case .authorizeAccountsCreate:
                                self?.router.replaceCurrent(with: .profile(profileId: ProfileDto.INVALID_ID, withLockCheck: false))
                            case .authorizeAccountsEdit(let profileId):
                                self?.router.replaceCurrent(with: .profile(profileId: profileId, withLockCheck: false))
                            default: 
                                self?.router.back()
                            }
                        case .unlockedNoAccount:
                            switch (unlockAction) {
                            case .authorizeAccountsCreate:
                                self?.router.replaceCurrent(with: .profile(profileId: ProfileDto.INVALID_ID, withLockCheck: false))
                            case .authorizeApplication:
                                self?.router.back()
                            default: break
                            }
                        case .failure:
                            if let self = self {
                                self.state.pin = ""
                                self.state.wrongPin = true
                                self.state.lockedTime = self.settings.lockScreenSettings.lockTime
                            }
                        }
                    }
                )
                .disposed(by: disposeBag)
        }
    }
}
