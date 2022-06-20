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
class AuthVM {
    
    enum AuthType: Int {
        case email = 0
        case accessId = 1
    }
 
    // MARK: Input bindings
    struct Inputs {
        let basicEmail: Observable<String?>
        let basicName: Observable<String?>
        let advancedEmail: Observable<String?>
        let advancedName: Observable<String?>
        let accessID: Observable<Int?>
        let accessIDpwd: Observable<String?>
        let serverAddressForEmail: Observable<String?>
        let serverAddressForAccessID: Observable<String?>
        let toggleAdvancedState: Observable<Bool>
        let advancedModeAuthType: Observable<AuthType>
        let createAccountRequest: Observable<Void>
        let autoServerSelected: Observable<Bool>
        let formSubmitRequest: Observable<Void>
        let accountDeleteRequest: Observable<Void>
    }

    let allowsEditingProfileName: Bool
    let allowsDeletingProfile: Bool
    
    // MARK: Output bindings
    var isAdvancedMode: Observable<Bool> {
        return _advancedMode.asObservable()
    }
    var isServerAutoDetect: Observable<Bool> {
        return _serverAutoDetect.asObservable()
    }

    var profileName: Observable<String?> {
        return _profileName.asObservable()
    }
    
    var emailAddress: Observable<String?> {
        return _emailAddress.asObservable()
    }
    var accessID: Observable<Int?> {
        return _accessID.asObservable()
    }
    var accessIDpwd: Observable<String?> {
        return _accessIDpwd.asObservable()
    }
    var serverAddressForEmail: Observable<String?> {
        return _serverAddressForEmail.asObservable()
    }
    var serverAddressForAccessID: Observable<String?> {
        return _serverAddressForAccessID.asObservable()
    }
    var advancedModeAuthType: Observable<AuthType> {
        return _advancedModeAuthType.asObservable()
    }
    var initiateSignup: Observable<Void> {
        return _initiateSignup.asObservable()
    }
    
    let signupPromptVisible = Observable<Bool>.deferred {
        return Observable<Bool>.of(!SAApp.suplaClientConnected())
    }
    
    var basicModeUnavailable: Observable<Void> {
        return _basicModeUnavailable.asObservable()
    }

    var formSaved: Observable<Bool> { return _formSaved.asObservable() }
    

    // MARK: Internal state
    private let _advancedMode = BehaviorRelay<Bool>(value: false)
    private let _serverAutoDetect = BehaviorRelay<Bool>(value: true)
    private let _emailAddress = BehaviorRelay<String?>(value: "")
    private let _profileName = BehaviorRelay<String?>(value: "")
    private let _accessID = BehaviorRelay<Int?>(value: 0)
    private let _accessIDpwd = BehaviorRelay<String?>(value: "")
    private let _serverAddressForEmail = BehaviorRelay<String?>(value: "")
    private let _serverAddressForAccessID = BehaviorRelay<String?>(value: "")

    private var _authCfg: AuthInfo
    private var _loadedCfg: AuthInfo
    private var _profileId: ProfileID?
    private let _isActive: Bool
    
    private let _advancedModeAuthType = BehaviorRelay<AuthType>(value: .email)
    private let _initiateSignup = PublishSubject<Void>()
    private let _formSaved = PublishSubject<Bool>()
    private let _basicModeUnavailable = PublishSubject<Void>()

    private let disposeBag = DisposeBag()
    private let _profileManager: ProfileManager
    
    init(bindings b: Inputs, profileManager: ProfileManager,
         profileId: NSManagedObjectID?) {
        _profileManager = profileManager
        _profileId = profileId

        let profileName: String
        let profileAdvanced: Bool

        if let profileId = profileId,
           let profile = profileManager.getProfile(id: profileId) {
            _authCfg = profile.authInfo!
            profileName = profile.displayName
            profileAdvanced = profile.advancedSetup
            _isActive = profile.isActive
            allowsDeletingProfile = !_isActive
        } else {
            _authCfg = AuthInfo(emailAuth: true,
                                serverAutoDetect: true,
                                emailAddress: "",
                                serverForEmail: "",
                                serverForAccessID: "",
                                accessID: 0,
                                accessIDpwd: "")
            profileName = ""
            profileAdvanced = false
            _isActive = false
            allowsDeletingProfile = false
        }
        _loadedCfg = _authCfg.clone()

        allowsEditingProfileName = _profileManager.getAllProfiles().count > 1 ||
            _authCfg.isAuthDataComplete || profileId == nil
        
        b.autoServerSelected.bind(to: _serverAutoDetect).disposed(by: disposeBag)
        b.serverAddressForEmail.bind(to: _serverAddressForEmail).disposed(by: disposeBag)
        b.serverAddressForAccessID.bind(to: _serverAddressForAccessID).disposed(by: disposeBag)
        b.basicEmail.bind(to: _emailAddress).disposed(by: disposeBag)
        b.advancedEmail.bind(to: _emailAddress).disposed(by: disposeBag)
        b.accessID.bind(to: _accessID).disposed(by: disposeBag)
        b.accessIDpwd.bind(to: _accessIDpwd).disposed(by: disposeBag)
        b.basicName.bind(to: _profileName).disposed(by: disposeBag)
        b.advancedName.bind(to: _profileName).disposed(by: disposeBag)
        
        b.toggleAdvancedState.subscribe { [weak self] _ in
            guard let ss = self else { return }
            if ss._advancedMode.value && (!ss._authCfg.emailAuth ||
                !ss._authCfg.serverAutoDetect) {
                /* User needs to switch to email auth with auto-detected
                   server, before he can go back to basic mode. */
                ss._basicModeUnavailable.onNext(())
                ss._advancedMode.accept(ss._advancedMode.value)
            } else {
                ss._advancedMode.accept(!ss._advancedMode.value)
            }
        }.disposed(by: disposeBag)

        b.advancedModeAuthType.subscribe { [weak self]  in
            self?._advancedModeAuthType.accept($0)
        }.disposed(by: disposeBag)
        
        b.createAccountRequest.subscribe(onNext: { [weak self] in
            self?._initiateSignup.on(.next(()))
        }).disposed(by: disposeBag)
        
        b.formSubmitRequest.subscribe(onNext: { [weak self] in
            self?.onFormSubmit()
        }).disposed(by: disposeBag)
        
        b.accountDeleteRequest.subscribe(onNext: { [weak self] in
            self?.onDeleteAccount()
        }).disposed(by: disposeBag)
  
        
        _serverAutoDetect.subscribe { [weak self] in
            guard let autoDetect = $0.element, let ss = self else { return }
            if ss._authCfg.serverAutoDetect != autoDetect {
                ss._authCfg.serverAutoDetect = autoDetect
                if autoDetect {
                    ss._serverAddressForEmail.accept("")
                } else {
                    if let email = ss._emailAddress.value,
                       let atidx = email.lastIndex(of: "@"),
                       email.endIndex > email.index(after: atidx) {
                        let domain = email[email.index(after: atidx)...]
                        ss._serverAddressForEmail.accept(String(domain))
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        _emailAddress.subscribe { [weak self] v in
            if v.element != self?._authCfg.emailAddress {
                self?._serverAddressForEmail.accept("")
                self?._authCfg.emailAddress = v.element! ?? ""
            }
        }.disposed(by: disposeBag)
        
        _serverAddressForEmail.subscribe { [weak self] sa in
            self?._authCfg.serverForEmail = sa.element! ?? ""
        }.disposed(by: disposeBag)
        
        _serverAddressForAccessID.subscribe { [weak self] sa in
            self?._authCfg.serverForAccessID = sa.element! ?? ""
        }.disposed(by: disposeBag)
        
        _accessID.subscribe { [weak self] ai in
            self?._authCfg.accessID = ai.element! ?? 0
        }.disposed(by: disposeBag)
        
        _accessIDpwd.subscribe { [weak self] ap in
            self?._authCfg.accessIDpwd = ap.element! ?? ""
        }.disposed(by: disposeBag)
        
        _advancedModeAuthType.subscribe { [weak self] at in
            self?._authCfg.emailAuth = at.element == .email
        }.disposed(by: disposeBag)

        _profileName.accept(profileName)
        _advancedMode.accept(profileAdvanced)
        _serverAutoDetect.accept(_loadedCfg.serverAutoDetect)
        _emailAddress.accept(_loadedCfg.emailAddress)
        _serverAddressForEmail.accept(_loadedCfg.serverForEmail)
        _serverAddressForAccessID.accept(_loadedCfg.serverForAccessID)
        _accessID.accept(_loadedCfg.accessID)
        _accessIDpwd.accept(_loadedCfg.accessIDpwd)
        _advancedModeAuthType.accept(_loadedCfg.emailAuth ? .email : .accessId)
    }

    private func onDeleteAccount() {
        guard let profileId = _profileId else { return }
        _profileManager.removeProfile(id: profileId)
        _formSaved.on(.next(false))
    }
    
    private func onFormSubmit() {
        let needsReauth = self.needsReauth

        let profile: AuthProfileItem
        
        if let profileId = _profileId,
           let p = _profileManager.getProfile(id: profileId) {
            profile = p
        } else {
            profile = _profileManager.makeNewProfile()
            profile.isActive = false
        }
        
        profile.advancedSetup = _advancedMode.value
        profile.authInfo = _authCfg
        profile.name = _profileName.value
        _profileManager.updateCurrentProfile(profile)
        _loadedCfg = _authCfg
        _authCfg = _loadedCfg.clone()
        _formSaved.on(.next(needsReauth))
    }
    
    private var needsReauth: Bool {
        return _isActive && _loadedCfg != _authCfg
    }
}
