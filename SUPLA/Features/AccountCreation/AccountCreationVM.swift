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
    private let profileManager: ProfileManager
    @Singleton<GlobalSettings> var settings
    @Singleton<RuntimeConfig> var config
    @Singleton<SuplaClientProvider> var suplaClientProvider
    @Singleton<SuplaAppWrapper> var suplaApp
    
    // MARK: Internal state
    private var profileId: ProfileID?
    
    var advancedMode: Observable<Bool> {
        get {
            stateObservable()
                .map() { state in state.advancedMode }
                .distinctUntilChanged()
        }
    }
    
    // MARK: Initialisation
    init(profileManager: ProfileManager, profileId: NSManagedObjectID?) {
        self.profileManager = profileManager
        self.profileId = profileId
        super.init()

        if let profileId = profileId,
           let profile = profileManager.read(id: profileId) {
            let authConfig = profile.authInfo!
            
            updateView() { state in
                state
                    .changing(path: \.advancedMode, to: profile.advancedSetup)
                    .changing(path: \.profileName, to: profile.displayName)
                    .changing(path: \.emailAddress, to: authConfig.emailAddress)
                    .changing(path: \.authType, to: authConfig.emailAuth ? .email : .accessId)
                    .changing(path: \.serverAddressForEmail, to: authConfig.serverForEmail)
                    .changing(path: \.serverAutoDetect, to: authConfig.serverAutoDetect)
                    .changing(path: \.accessId, to: "\(authConfig.accessID)")
                    .changing(path: \.accessIdPassword, to: authConfig.accessIDpwd)
                    .changing(path: \.serverAddressForAccessId, to: authConfig.serverForAccessID)
            }
        }

        updateView() { state in
            state
                .changing(path: \.deleteButtonVisible, to: settings.anyAccountRegistered && isNewProfile())
                .changing(path: \.profileNameVisible, to: settings.anyAccountRegistered)
                .changing(path: \.backButtonVisible, to: settings.anyAccountRegistered)
                .changing(path: \.title, to: settings.anyAccountRegistered ? Strings.AccountCreation.title : Strings.NavBar.titleSupla)
        }
    }
    
    override func defaultViewState() -> AccountCreationViewState { AccountCreationViewState() }
    
    // MARK: Public modifiers
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
        doRemoveAccount(onSuccess: { needsRestart, needsReauth in
            send(event: .finish(needsRestart: needsRestart, needsReauth: needsReauth))
        })
    }
    
    func removeAccount() {
        doRemoveAccount(onSuccess: { needsRestart, _ in
            send(event: .navigateToRemoveAccount(needsRestart: needsRestart))
        })
    }
    
    func save() {
        guard let state = currentState() else { return }
        var settings = self.settings
        
        let profileName = state.profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        if (state.profileNameVisible && profileName.isEmpty) {
            send(event: .showEmptyNameDialog)
            return
        }
        if (isNameDuplicated(profileName: profileName)) {
            send(event: .showDuplicatedNameDialog)
            return
        }
        let authInfo = createAuthInfoFromState()
        if (authInfo?.isAuthDataComplete != true) {
            send(event: .showRequiredDataMisingDialog)
            return
        }
        
        let profile = getProfile()
        let authDataChanged = authDataChanged(authInfo: profile.authInfo)
        
        profile.name = profileName
        profile.advancedSetup = state.advancedMode
        profile.authInfo = authInfo
        if (authDataChanged) {
            profile.authInfo?.preferredProtocolVersion = Int(SUPLA_PROTO_VERSION)
        }
        
        if (profileManager.update(profile)) {
            settings.anyAccountRegistered = true
            
            let needsReauth = profile.isActive && authDataChanged
            if (needsReauth) {
                suplaClientProvider.provide().reconnect()
            }
            send(event: .formSaved(needsReauth: needsReauth))
        } else {
            send(event: .showRequiredDataMisingDialog)
        }
    }
    
    private func getProfile() -> AuthProfileItem {
        if let profileId = profileId {
            return profileManager.read(id: profileId)!
        } else {
            let profile = profileManager.create()
            profile.isActive = !settings.anyAccountRegistered
            return profile
        }
    }
    
    // MARK: Internal/private functions
    private func doRemoveAccount(onSuccess: (_ needsRestart: Bool, _ needsReauth: Bool ) -> Void) {
        guard let profileId = profileId else { return }
        guard let profile = profileManager.read(id: profileId) else { return }
        var settings = settings
        var config = config
        
        if (!profile.isActive) {
            // Removing inactive account - just remove
            removeAccountFromDb(profileId) { onSuccess(false, false) }
        } else {
            // We're removing an active account - supla client needs to be stopped first
            suplaApp.terminateSuplaClient()
            
            if let firstInactiveProfile = profileManager.getAllProfiles().first(where: { profile in !profile.isActive }) {
                // Removing active account, when other account exists
                if (profileManager.activateProfile(id: firstInactiveProfile.objectID, force: true)) {
                    removeAccountFromDb(profileId) {
                        onSuccess(false, true)
                    }
                } else {
                    send(event: .showRemovalFailure)
                }
            } else {
                // Removing last account
                removeAccountFromDb(profileId) {
                    config.activeProfileId = nil
                    settings.anyAccountRegistered = false
                    onSuccess(true, true)
                }
            }
            
            suplaClientProvider.provide().reconnect()
        }
    }
    
    private func removeAccountFromDb(_ profileId: ProfileID, _ onSuccess: () -> Void) {
        // Removing inactive account - just remove
        if (profileManager.delete(id: profileId)) {
            onSuccess()
        } else {
            send(event: .showRemovalFailure)
        }
    }
    
    private func isNameDuplicated(profileName: String?) -> Bool {
        return profileManager.getAllProfiles().first(where: {profile in profile.displayName == profileName && profile.objectID != profileId}) != nil
    }
    
    private func createAuthInfoFromState() -> AuthInfo? {
        guard let state = currentState() else { return nil }
        
        return AuthInfo(
            emailAuth: state.authType == .email,
            serverAutoDetect: state.serverAutoDetect,
            emailAddress: state.emailAddress,
            serverForEmail: state.serverAddressForEmail,
            serverForAccessID: state.serverAddressForAccessId,
            accessID: Int(state.accessId) ?? 0,
            accessIDpwd: state.accessIdPassword
        )
    }
    
    private func authDataChanged(authInfo: AuthInfo?) -> Bool {
        guard let state = currentState() else { return false }
        guard let authInfo = authInfo else { return true }
        
        return state.emailAddress != authInfo.emailAddress
        || state.serverAutoDetect != authInfo.serverAutoDetect
        || state.emailAddress != authInfo.emailAddress
        || state.serverAddressForEmail != authInfo.serverForEmail
        || state.serverAddressForAccessId != authInfo.serverForAccessID
        || authInfo.accessID != Int(state.accessId) ?? 0
        || state.accessIdPassword != authInfo.accessIDpwd
    }
    
    private func isNewProfile() -> Bool { profileId != nil }
}

enum AccountCreationViewEvent: ViewEvent {
    case showRemovalDialog
    case showRemovalFailure
    case formSaved(needsReauth: Bool)
    case navigateToCreateAccount
    case navigateToRemoveAccount(needsRestart: Bool)
    case finish(needsRestart: Bool, needsReauth: Bool)
    case showEmptyNameDialog
    case showDuplicatedNameDialog
    case showRequiredDataMisingDialog
    case showBasicModeUnavailableDialog
}

struct AccountCreationViewState: ViewState {
    var title: String = ""
    
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
}
