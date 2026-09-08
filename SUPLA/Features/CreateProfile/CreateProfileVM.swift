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
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton<SaveOrCreateProfileUseCase> private var saveOrCreateProfileUseCase
        @Singleton<ReadProfileByIdUseCase> private var readProfileByIdUseCase
        @Singleton<ProfileSessionManager> private var profileSessionManager
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<AppRouter> private var router
        @Singleton<GlobalSettings> var settings

        private let profileId: Int32

        init(profileId: Int32, state: ViewState = ViewState()) {
            self.profileId = profileId
            super.init(state: state)
            
            state.profileNameVisible = settings.anyAccountRegistered
        }

        override func onViewAppear() {
            loadData()
        }

        func loadData() {
            guard profileId != ProfileDto.INVALID_ID else { return }
            
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
                        self?.state.serverAddress = profile.server?.address ?? ""
                        self?.state.accessId = "\(profile.accessId)"
                        self?.state.accessIdPassword = profile.accessIdPassword ?? ""
                        self?.state.deleteButtonVisible = self?.settings.anyAccountRegistered == true
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func onServerAutoDetectChange(_ autoDetect: Bool) {
            if (autoDetect) {
                state.serverAddress = ""
            } else {
                state.serverAddress = getEmailDomain()
            }
        }
        
        func onToggleAdvancedState(_ advancedOn: Bool) {
            if (!advancedOn && (state.authorisationType != .email || !state.serverAutoDetect)) {
                state.presentBasicModeNotAvaiable = true
                state.advancedAuthorization = true
            }
        }
        
        func logoutAccount() {
            guard profileId != ProfileDto.INVALID_ID else { return }
            
            state.loading = true
            
            profileSessionManager.deleteProfile(
                profileId: profileId,
                onSuccess: { [weak self] result in
                    self?.state.loading = false
                    
                    if (result.restartNeeded || result.reauthNeeded) {
                        self?.router.setRoot(.status)
                    } else {
                        self?.router.back()
                    }
                },
                onError: { [weak self] _ in
                    self?.state.loading = false
                    self?.state.presentRemovalFailure = true
                }
            )
        }
        
        func removeAccount() {
            guard profileId != ProfileDto.INVALID_ID else { return }
            
            state.loading = true
            
            profileSessionManager.deleteProfile(
                profileId: profileId,
                onSuccess: { [weak self] result in
                    self?.state.loading = false
                    
                    self?.router.replaceCurrent(
                        with: .removeAccountWeb(
                            needsRestart: result.restartNeeded,
                            serverAddress: result.serverAddress
                        )
                    )
                },
                onError: { [weak self] _ in
                    self?.state.loading = false
                    self?.state.presentRemovalFailure = true
                }
            )
        }
        
        func save() {
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
                                self?.router.setRoot(.status)
                            } else {
                                self?.router.back()
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
            router.navigate(to: .createAccountWeb)
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
    func toProfileDto(profileId: Int32) -> ProfileDto {
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
            serverAddress: serverAddress
        )
    }
}
