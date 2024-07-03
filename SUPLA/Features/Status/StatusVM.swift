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

extension StatusFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<SuplaAppStateHolder> private var stateHolder
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<DisconnectUseCase> private var disconnectUseCase
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewWillAppear() {
            stateHolder.state()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] state in
                    SALog.debug("Status got state: \(state)")
                    
                    switch (state) {
                    case .connected: self?.coordinator.navigateToMain()
                    case .firstProfileCreation: self?.coordinator.navigateToProfile(profileId: nil)
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
                        self?.coordinator.navigateToLockScreen(unlockAction: .authorizeApplication)
                    }
                })
                .disposedWhenDisappear(by: self)
        }
        
        func onTryAgain() {
            stateHolder.handle(event: .connecting)
        }
        
        func goToProfiles() {
            disconnectUseCase.invoke()
                .asDriverWithoutError()
                .drive(
                    onCompleted: { [weak self] in self?.coordinator.navigateToProfiles() }
                )
                .disposed(by: disposeBag)
        }
        
        private func handleErrorState(_ reason: SuplaAppState.Reason?) {
            if (reason?.shouldAuthorize == true) {
                coordinator.showLogin()
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
                code == SUPLA_RESULT_HOST_NOT_FOUND ? Strings.Status.errorHostNotFound : nil
            case .registerError(let code): SuplaResultCode.from(value: code).getTextMessage(authDialog: true)
            case .noNetwork, .versionError, .appInBackground, .none: nil
            }
        }
    }
}
