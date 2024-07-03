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
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<CheckPinUseCase> private var checkPinUseCase
        @Singleton<GlobalSettings> private var settings
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<DateProvider> private var dateProvider
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            let lockScreenSettings = settings.lockScreenSettings
            state.biometricAllowed = lockScreenSettings.biometricAllowed
            state.lockedTime = lockScreenSettings.lockTime
        }
        
        override func onViewAppeared() {
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
        
        func onPinForgotten() {
            let dialog = SAAlertDialogVC(
                title: Strings.LockScreen.forgottenCodeTitle,
                message: Strings.LockScreen.forgottenCodeMessage,
                positiveText: Strings.LockScreen.forgottenCodeButton,
                negativeText: nil
            )
            
            dialog.rx.positiveTap
                .asDriverWithoutError()
                .drive(onNext: { [unowned dialog] in dialog.dismiss(animated: true) })
                .disposed(by: disposeBag)
            
            coordinator.present(dialog)
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
                            self?.coordinator.popViewController()
                            
                            switch (unlockAction) {
                            case .authorizeAccountsCreate:
                                self?.coordinator.navigateToProfile(profileId: nil, withLockCheck: false)
                            case .authorizeAccountsEdit(let profileId):
                                self?.coordinator.navigateToProfile(profileId: profileId, withLockCheck: false)
                            default: break
                            }
                        case .unlockedNoAccount:
                            if (unlockAction == .authorizeAccountsCreate) {
                                self?.coordinator.navigateToProfile(profileId: nil, withLockCheck: false)
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
