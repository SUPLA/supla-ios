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

extension StatusFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton<AuthorizationCoordinator> private var authorizationCoordinator
        @Singleton<DisconnectUseCase> private var disconnectUseCase
        @Singleton<SuplaAppStateHolder> private var stateHolder
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<AppRouter> private var router
        
        init(state: ViewState = ViewState()) {
            super.init(state: state)
        }
        
        override func onViewAppear() {
            stateHolder.state()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] state in
                    SALog.debug("Status got state: \(state)")
                    
                    switch (state) {
                    case .connected: self?.router.setRoot(.main)
                    case .firstProfileCreation: self?.router.navigate(to: .profile(profileId: ProfileDto.INVALID_ID, withLockCheck: true))
                    case .finished(let reason): self?.handleErrorState(reason)
                    case .initialization:
                        self?.state.viewType = .connecting
                        self?.state.stateText = .initializing
                    case .connecting:
                        self?.state.viewType = .connecting
                        self?.state.stateText = .connecting
                    case .disconnecting, .locking:
                        self?.state.viewType = .connecting
                        self?.state.stateText = .disconnecting
                    case .locked:
                        self?.router.navigate(to: .lockScreen(action: .authorizeApplication))
                    }
                })
                .disposedWhenDisappear(by: self)
            
            CoreDataManager.shared.initializationSubject
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] step in
                        self?.state.showMigrationMessage = switch step {
                        case .awaiting, .initialized: false
                        case .initializing, .migrating: true
                        }
                    }
                )
                .disposedWhenDisappear(by: self)
        }
        
        func onTryAgain() {
            stateHolder.handle(event: .connecting)
        }

        func goToProfiles() {
            disconnectUseCase.invoke()
                .subscribe(on: schedulers.background)
                .observe(on: schedulers.main)
                .asDriverWithoutError()
                .drive(
                    onCompleted: { [weak self] in self?.router.navigate(to: .profiles) }
                )
                .disposed(by: disposeBag)
        }
        
        private func handleErrorState(_ reason: SuplaAppState.Reason?) {
            if (reason?.shouldAuthorize == true) {
                Task { @MainActor [weak self] in
                    self?.authorizationCoordinator.authorize()
                }
            }
            
            if (reason == .appInBackground) {
                state.viewType = .connecting
                state.stateText = .initializing
            } else {
                state.viewType = .error
                state.errorDescription = getErrorDescription(reason)
            }
        }
        
        private func getErrorDescription(_ reason: SuplaAppState.Reason?) -> String? {
            switch (reason) {
            case .connectionError(let code):
                switch (code) {
                case SUPLA_RESULT_CANT_CONNECT_TO_HOST: Strings.Status.errorCantConnectToHost
                case SUPLA_RESULT_HOST_NOT_FOUND: Strings.Status.errorHostNotFound
                default: nil
                }
            case .registerError(let code): SuplaResultCode.companion.from(value: code).message(isLogin: true).string
            case .noNetwork, .versionError, .appInBackground, .addWizardStarted, .none: nil
            }
        }
    }
}
