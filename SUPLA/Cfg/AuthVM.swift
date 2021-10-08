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
    var isAdvancedMode: Observable<Bool> {
        return _advancedMode.asObservable()
    }
    private let _advancedMode = BehaviorRelay(value: false)
    
    enum AuthType: Int {
        case email = 0
        case accessId = 1
    }
    
    var advancedModeAuthType: Observable<AuthType> {
        return _advancedModeAuthType.asObservable()
    }
    private let _advancedModeAuthType = BehaviorRelay<AuthType>(value: .email)

    var initiateSignup: Observable<Void> {
        return _initiateSignup.asObservable()
    }
    private let _initiateSignup = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(basicEmail: Observable<String?>,
         toggleAdvancedState: Observable<Bool>,
         advancedModeAuthType: Observable<AuthType>,
         createAccountRequest: Observable<Void>,
         autoServerSelected: Observable<Bool>) {
        toggleAdvancedState.subscribe { [weak self] _ in
            guard let ss = self else { return }
            ss._advancedMode.accept(!ss._advancedMode.value)
        }.disposed(by: disposeBag)

        advancedModeAuthType.subscribe { [weak self]  in
            self?._advancedModeAuthType.accept($0)
        }.disposed(by: disposeBag)
        
        createAccountRequest.subscribe(onNext: { [weak self] in
            self?._initiateSignup.on(.next(()))
        }).disposed(by: disposeBag)
        
        autoServerSelected.subscribe { [weak self] in
            print("selected \($0)")
        }.disposed(by: disposeBag)
    }
    
    
}
