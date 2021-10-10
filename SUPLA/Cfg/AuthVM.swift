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
 
    // Input bindings
    struct Bindings {
        let basicEmail: Observable<String?>
        let advancedEmail: Observable<String?>
        let accessID: Observable<Int?>
        let accessIDpwd: Observable<String?>
        let serverAddress: Observable<String?>
        let toggleAdvancedState: Observable<Bool>
        let advancedModeAuthType: Observable<AuthType>
        let createAccountRequest: Observable<Void>
        let autoServerSelected: Observable<Bool>
        let formSubmitRequest: Observable<Void>
    }
    var isAdvancedMode: Observable<Bool> {
        return _advancedMode.asObservable()
    }
    private let _advancedMode = BehaviorRelay<Bool>(value: false)
    
    var isServerAutoDetect: Observable<Bool> {
        return _serverAutoDetect.asObservable()
    }
    private let _serverAutoDetect = BehaviorRelay<Bool>(value: true)
    
    var emailAddress: Observable<String?> {
        return _emailAddress.asObservable()
    }
    private let _emailAddress = BehaviorRelay<String?>(value: nil)
    
    var accessID: Observable<Int?> {
        return _accessID.asObservable()
    }
    private let _accessID = BehaviorRelay<Int?>(value: nil)
    
    var accessIDpwd: Observable<String?> {
        return _accessIDpwd.asObservable()
    }
    private let _accessIDpwd = BehaviorRelay<String?>(value: nil)
    
    var serverAddress: Observable<String?> {
        return _serverAddress.asObservable()
    }
    private let _serverAddress = BehaviorRelay<String?>(value: nil)

    private var _authCfg: AuthCfg
    private var _loadedCfg: AuthCfg
    
    var advancedModeAuthType: Observable<AuthType> {
        return _advancedModeAuthType.asObservable()
    }
    private let _advancedModeAuthType = BehaviorRelay<AuthType>(value: .email)

    var initiateSignup: Observable<Void> {
        return _initiateSignup.asObservable()
    }
    private let _initiateSignup = PublishSubject<Void>()
    
    var formSaved: Observable<Bool> { return _formSaved.asObservable() }
    private let _formSaved = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
    private let _configProvider: AuthCfgProvider
    
    init(bindings b: Bindings, authConfigProvider: AuthCfgProvider) {
        _configProvider = authConfigProvider
        
        b.autoServerSelected.bind(to: _serverAutoDetect).disposed(by: disposeBag)
        b.serverAddress.bind(to: _serverAddress).disposed(by: disposeBag)
        b.basicEmail.bind(to: _emailAddress).disposed(by: disposeBag)
        b.advancedEmail.bind(to: _emailAddress).disposed(by: disposeBag)
        b.accessID.bind(to: _accessID).disposed(by: disposeBag)
        b.accessIDpwd.bind(to: _accessIDpwd).disposed(by: disposeBag)


        let cfg = authConfigProvider.loadCurrentAuthCfg() ??
            AuthCfg(usesEmailAuth: true, isAdvancedConfig: false)
        _authCfg = cfg
        _loadedCfg = cfg

        _advancedMode.accept(cfg.isAdvancedConfig)
        _serverAutoDetect.accept((cfg.serverHostName ?? "").isEmpty)
        _serverAddress.accept(cfg.serverHostName)
        _emailAddress.accept(cfg.emailAddress)
        _accessID.accept(cfg.accessID)
        _accessIDpwd.accept(cfg.accessPassword)
        

        b.toggleAdvancedState.subscribe { [weak self] _ in
            guard let ss = self else { return }
            ss._advancedMode.accept(!ss._advancedMode.value)
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
        
        _serverAutoDetect.subscribe { [weak self] in
            if $0.element == true {
                self?._serverAddress.accept(nil)
            }
        }.disposed(by: disposeBag)
        
        _emailAddress.subscribe { [weak self] v in
            self?._serverAddress.accept(nil)
            self?._accessID.accept(nil)
            self?._accessIDpwd.accept(nil)
            self?._authCfg.emailAddress = v.element!
        }.disposed(by: disposeBag)
        
        _serverAddress.subscribe { [weak self] sa in
            self?._authCfg.serverHostName = sa.element!
        }.disposed(by: disposeBag)
        
        _accessID.subscribe { [weak self] ai in
            self?._authCfg.accessID = ai.element!
        }.disposed(by: disposeBag)
        
        _accessIDpwd.subscribe { [weak self] ap in
            self?._authCfg.accessPassword = ap.element!
        }.disposed(by: disposeBag)
    }
    
    
    private func onFormSubmit() {
        let needsReauth = self.needsReauth
        _configProvider.storeCurrentAuthCfg(_authCfg)
        _loadedCfg = _authCfg
        _formSaved.on(.next(needsReauth))
    }
    
    private var needsReauth: Bool {
        return !(_loadedCfg.usesEmailAuth == _authCfg.usesEmailAuth &&
                 (_loadedCfg.accessID ?? 0) == (_authCfg.accessID ?? 0) &&
                 (_loadedCfg.accessPassword ?? "") == (_authCfg.accessPassword ?? "") &&
                 (_loadedCfg.emailAddress ?? "") == (_authCfg.emailAddress ?? "") &&
                 (_loadedCfg.serverHostName ?? "") == (_authCfg.serverHostName ?? ""))
    }
}
