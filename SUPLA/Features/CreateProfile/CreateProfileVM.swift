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
    
extension CreateProfileFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<SaveOrCreateProfileUseCase> private var saveOrCreateProfileUseCase
        @Singleton<ReadProfileByIdUseCase> private var readProfileByIdUseCase
        @Singleton<DeleteProfileUseCase> private var deleteProfileUseCase
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<GlobalSettings> var settings
        
        init() {
            super.init(state: ViewState())
            
            state.profileNameVisible = settings.anyAccountRegistered
        }
        
        func loadData(profileId: Int32?) {
            guard let profileId else { return }
            
            readProfileByIdUseCase.invoke(profileId: profileId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] profile in
                        guard let profile else { return }
                        
                        self?.state.advancedAuthorization = profile.advancedSetup
                        self?.state.profileName = profile.displayName
                        self?.state.email = profile.email ?? ""
                        self?.state.isActive = profile.isActive
                        self?.state.authorisationType = profile.authorizationType
                        self?.state.serverAutoDetect = profile.serverAutoDetect
                        self?.state.serwerAddress = profile.server?.address ?? ""
                        self?.state.accessId = "\(profile.accessId)"
                        self?.state.accessIdPassword = profile.accessIdPassword ?? ""
                        self?.state.deleteButtonVisible = self?.settings.anyAccountRegistered == true
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func onServerAutoDetectChange(_ autoDetect: Bool) {
            if (autoDetect) {
                state.serwerAddress = ""
            } else {
                state.serwerAddress = getEmailDomain()
            }
        }
        
        func onToggleAdvancedState(_ advancedOn: Bool) {
            if (!advancedOn && (state.authorisationType != .email || !state.serverAutoDetect)) {
                state.presentBasicModeNotAvaiable = true
                state.advancedAuthorization = true
            }
        }
        
        func logoutAccount(profileId: Int32?) {
            guard let profileId else { return }
            
            state.loading = true
            
            deleteProfileUseCase.invoke(profileId: profileId)
                .observe(on: schedulers.main)
                .subscribe(
                    onNext: { [weak self] result in
                        self?.state.loading = false
                        
                        if (result.restartNeeded || result.reauthNeeded) {
                            self?.coordinator.popToStatus()
                        } else {
                            self?.coordinator.popToViewController(ofClass: ProfilesVC.self)
                        }
                    },
                    onError: { [weak self] error in
                        self?.state.loading = false
                        self?.state.presentRemovalFailure = true
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func removeAccount(profileId: Int32?) {
            guard let profileId else { return }
            
            state.loading = true
            
            deleteProfileUseCase.invoke(profileId: profileId)
                .observe(on: schedulers.main)
                .subscribe(
                    onNext: { [weak self] result in
                        self?.state.loading = false
                        
                        self?.coordinator.popToViewController(ofClass: ProfilesVC.self)
                        self?.coordinator.navigateToRemoveAccountWeb(needsRestart: result.restartNeeded, serverAddress: result.serverAddress)
                    },
                    onError: { [weak self] error in
                        self?.state.loading = false
                        self?.state.presentRemovalFailure = true
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func save(profileId: Int32?) {
            let name = state.profileName.trimmingCharacters(in: .whitespacesAndNewlines)
            if (state.profileNameVisible && name.isEmpty) {
                state.presentEmptyName = true
                return
            }
            
            let profile = state.toProfileDto(profileId: profileId)
            state.loading = true
            
            saveOrCreateProfileUseCase.invoke(profileDto: profile)
                .observe(on: schedulers.main)
                .subscribe(
                    onNext: { [weak self] result in
                        self?.state.loading = false
                        
                        if (result.saved) {
                            if (result.needsReauth) {
                                SAApp.revokeOAuthToken()
                                self?.coordinator.popToStatus()
                            } else {
                                self?.coordinator.popToViewController(ofClass: ProfilesVC.self)
                            }
                        } else {
                            self?.state.presentRequiredDataMissing = true
                        }
                    },
                    onError: { [weak self] error in
                        self?.state.loading = false
                        
                        switch (error) {
                        case SaveOrCreateProfileError.dataIncomplete:
                            self?.state.presentRequiredDataMissing = true
                        case SaveOrCreateProfileError.duplicatedName:
                            self?.state.presentDuplicatedName = true
                        default:
                            SALog.warning("Could not create account: \(String(describing: error))")
                            self?.state.presentRequiredDataMissing = true
                        }
                    }
                )
                .disposed(by: disposeBag)
            
        }
        
        func createNewAccount() {
            coordinator.navigateToCreateAccountWeb()
        }
        
        private func getEmailDomain() -> String {
            if let atidx = state.email.lastIndex(of: "@"),
               state.email.endIndex > state.email.index(after: atidx)
            {
                return String(state.email[state.email.index(after: atidx)...])
            } else {
                return ""
            }
        }
    }
}

fileprivate extension CreateProfileFeature.ViewState {
    func toProfileDto(profileId: Int32?) -> ProfileDto {
        ProfileDto(
            id: profileId,
            name: profileName,
            isActive: isActive,
            authorizationType: authorisationType,
            advancedSetup: advancedAuthorization,
            serverAutoDetect: serverAutoDetect,
            email: email,
            accessId: Int32(accessId),
            accessIdPassword: accessIdPassword,
            serverAddress: serwerAddress
        )
    }
}
