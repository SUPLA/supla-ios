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

import RxSwift
import RxCocoa

/*
 Authentication config view model.
 */
class AccountCreationVM: BaseViewModel<AccountCreationViewState, AccountCreationViewEvent> {
    
    // MARK: Injected values
    @Singleton<GlobalSettings> var settings
    @Singleton<ReadProfileByIdUseCase> private var readProfileByIdUseCase
    @Singleton<SaveOrCreateProfileUseCase> private var saveOrCreateProfileUseCase
    @Singleton<DeleteProfileUseCase> private var deleteProfileUseCase
    @Singleton<SuplaSchedulers> private var schedulers
    
    var advancedMode: Observable<Bool> {
        get {
            stateObservable()
                .map() { state in state.advancedMode }
                .distinctUntilChanged()
        }
    }
    
    // MARK: Initialisation
    override init() {
        super.init()
        
        updateView() { state in
            state
                .changing(path: \.profileNameVisible, to: settings.anyAccountRegistered)
                .changing(path: \.backButtonVisible, to: settings.anyAccountRegistered)
        }
    }
    
    override func defaultViewState() -> AccountCreationViewState { AccountCreationViewState() }
    
    // MARK: Public modifiers
    func loadData(profileId: NSManagedObjectID?) {
        guard let id = profileId else { return }
        
        readProfileByIdUseCase.invoke(profileId: id)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] profile in
                let authConfig = profile.authInfo!
                
                self?.updateView { state in
                    state
                        .changing(path: \.profileId, to: profileId)
                        .changing(path: \.advancedMode, to: profile.advancedSetup)
                        .changing(path: \.profileName, to: profile.displayName)
                        .changing(path: \.emailAddress, to: authConfig.emailAddress)
                        .changing(path: \.authType, to: authConfig.emailAuth ? .email : .accessId)
                        .changing(path: \.serverAddressForEmail, to: authConfig.serverForEmail)
                        .changing(path: \.serverAutoDetect, to: authConfig.serverAutoDetect)
                        .changing(path: \.accessId, to: "\(authConfig.accessID)")
                        .changing(path: \.accessIdPassword, to: authConfig.accessIDpwd)
                        .changing(path: \.serverAddressForAccessId, to: authConfig.serverForAccessID)
                        .changing(path: \.deleteButtonVisible, to: self?.settings.anyAccountRegistered == true && profileId != nil)
                    
                }
            })
            .disposed(by: self)
    }
    
    func setEmailAddress(_ emailAddress: String) {
        guard let currentState = currentState() else { return }
        
        if currentState.emailAddress != emailAddress {
            updateView() { state in
                state
                    .changing(path: \.serverAddressForEmail, to: "")
                    .changing(path: \.emailAddress, to: emailAddress)
            }
        }
    }
    
    func setServerAutodetect(_ autodetect: Bool) {
        guard let currentState = currentState() else { return }
        if (currentState.serverAutoDetect == autodetect) { return }
        
        updateView() { state in
            if (autodetect) {
                return state
                    .changing(path: \.serverAutoDetect, to: autodetect)
                    .changing(path: \.serverAddressForEmail, to: "")
            } else {
                return state
                    .changing(path: \.serverAutoDetect, to: autodetect)
                    .changing(path: \.serverAddressForEmail, to: currentState.getEmailDomain())
            }
        }
    }
    
    func toggleAdvancedState(_ advancedOn: Bool) {
        guard let currentState = currentState() else { return }
        
        updateView() { $0.changing(path: \.advancedMode, to: advancedOn) }
        if currentState.advancedMode && !advancedOn && (currentState.authType != .email || !currentState.serverAutoDetect) {
            /* User needs to switch to email auth with auto-detected
             server, before he can go back to basic mode. */
            send(event: .showBasicModeUnavailableDialog)
            updateView() { $0.changing(path: \.advancedMode, to: true) }
        }
    }
    
    func removeTapped() {
        send(event: .showRemovalDialog)
    }
    
    func addAccountTapped() {
        send(event: .navigateToCreateAccount)
    }
    
    func logoutAccount() {
        guard let profileId = currentState()?.profileId else { return }
        
        send(event: .showProgress)
        deleteProfileUseCase.invoke(profileId: profileId)
            .observe(on: schedulers.main)
            .subscribe(
                onNext: { [weak self] result in
                    self?.send(event: .finish(
                        needsRestart: result.restartNeeded,
                        needsReauth: result.reauthNeeded
                    ))
                },
                onError: { [weak self] error in
                    self?.send(event: .showRemovalFailure)
                }
            )
            .disposed(by: self)
    }
    
    func removeAccount() {
        guard let profileId = currentState()?.profileId else { return }
        
        send(event: .showProgress)
        deleteProfileUseCase.invoke(profileId: profileId)
            .observe(on: schedulers.main)
            .subscribe(
                onNext: { [weak self] result in
                    self?.send(event: .navigateToRemoveAccount(
                        needsRestart: result.restartNeeded,
                        serverAddress: result.servertAddress
                    ))
                },
                onError: { [weak self] error in
                    self?.send(event: .showRemovalFailure)
                }
            )
            .disposed(by: self)
    }
    
    func save() {
        guard let state = currentState() else { return }
        
        let profileName = state.profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        if (state.profileNameVisible && profileName.isEmpty) {
            send(event: .showEmptyNameDialog)
            return
        }
        
        guard let authInfo = createAuthInfoFromState() else { return }
        
        send(event: .showProgress)
        saveOrCreateProfileUseCase.invoke(
            profileId: currentState()?.profileId,
            name: profileName,
            advancedMode: state.advancedMode,
            authInfo: authInfo
        ).observe(on: schedulers.main)
            .subscribe(
                onNext: { [weak self] result in
                    if (result.saved) {
                        self?.send(event: .formSaved(needsReauth: result.needsReauth))
                    } else {
                        self?.send(event: .showRequiredDataMisingDialog)
                    }
                },
                onError: { [weak self] error in
                    if let error = error as? SaveOrCreateProfileError {
                        switch (error) {
                        case .dataIncomplete:
                            self?.send(event: .showRequiredDataMisingDialog)
                        case .duplicatedName:
                            self?.send(event: .showDuplicatedNameDialog)
                        }
                    } else {
                        let description = String(describing: error)
                        NSLog("Could not create account: \(description)")
                        self?.send(event: .showRequiredDataMisingDialog)
                    }
                }
            )
            .disposed(by: self)
    }
    
    // MARK: Internal/private functions
    
    private func createAuthInfoFromState() -> AuthInfo? {
        guard let state = currentState() else { return nil }
        return AuthInfo.from(state: state)
    }
}

enum AccountCreationViewEvent: ViewEvent {
    case showRemovalDialog
    case showRemovalFailure
    case formSaved(needsReauth: Bool)
    case navigateToCreateAccount
    case navigateToRemoveAccount(needsRestart: Bool, serverAddress: String?)
    case finish(needsRestart: Bool, needsReauth: Bool)
    case showEmptyNameDialog
    case showDuplicatedNameDialog
    case showRequiredDataMisingDialog
    case showBasicModeUnavailableDialog
    case showProgress
}

struct AccountCreationViewState: ViewState {
    var profileId: ProfileID? = nil
    
    var profileName: String = ""
    var emailAddress: String = ""
    var advancedMode: Bool = false
    
    var authType: AuthType = .email
    var serverAutoDetect: Bool = true
    var serverAddressForEmail: String = ""
    var accessId: String = ""
    var accessIdPassword: String = ""
    var serverAddressForAccessId: String = ""
    
    var profileNameVisible: Bool = false
    var deleteButtonVisible: Bool = false
    var backButtonVisible: Bool = false
    
    func getEmailDomain() -> String {
        if let atidx = emailAddress.lastIndex(of: "@"),
           emailAddress.endIndex > emailAddress.index(after: atidx) {
            return String(emailAddress[emailAddress.index(after: atidx)...])
        } else {
            return ""
        }
    }
    
    enum AuthType: Int {
        case email = 0
        case accessId = 1
    }
    
    var title: String {
        if (!profileNameVisible) {
            return Strings.NavBar.titleSupla
        } else if (profileId != nil) {
            return Strings.AccountCreation.creationTitle
        } else {
            return Strings.AccountCreation.modificationTitle
        }
    }
}
