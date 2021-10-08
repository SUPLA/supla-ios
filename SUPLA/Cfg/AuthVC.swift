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

	

import UIKit
import RxSwift
import RxCocoa

/**
 `AuthVC` - a view controller for managing authentication settings of a profile.
 */
class AuthVC: UIViewController {
    
    @IBOutlet private var vBasic: UIView!
    @IBOutlet private var basicModeToggle: UISwitch!
    @IBOutlet private var bsEmailAddr: UITextField!
    @IBOutlet private var bsCreateAccountButton: UIButton!

    @IBOutlet private var vAdvanced: UIView!
    @IBOutlet private var advancedModeToggle: UISwitch!
    @IBOutlet private var adAuthType: UISegmentedControl!
    @IBOutlet private var adEmailAddr: UITextField!
    @IBOutlet private var adServerAddrEmail: UITextField!
    @IBOutlet private var adAccessID: UITextField!
    @IBOutlet private var adAccessPwd: UITextField!
    @IBOutlet private var adServerAddrAccessId: UITextField!
    @IBOutlet private var adServerAuto: CheckBox!
    @IBOutlet private var adFormHostView: UIView!
    @IBOutlet private var adFormEmailAuth: UIView!
    @IBOutlet private var adFormAccessIdAuth: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindVM()
    }
    
    private func configureUI() {
        [vBasic, vAdvanced, adFormHostView, adFormEmailAuth, adFormAccessIdAuth].forEach {
            $0.backgroundColor = .viewBackground
        }
        bsCreateAccountButton.setAttributedTitle(NSLocalizedString("Create an account", comment: ""))
        [adFormEmailAuth, adFormAccessIdAuth].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private let disposeBag = DisposeBag()
    private var vM: AuthVM!
    
    private func bindVM() {
        vM = AuthVM(basicEmail: bsEmailAddr.rx.text.asObservable(),
                    toggleAdvancedState: Observable.of(basicModeToggle.rx.isOn.asObservable(),
                                          advancedModeToggle.rx.isOn.asObservable()).merge().asObservable(),
                    advancedModeAuthType: adAuthType.rx.selectedSegmentIndex.asObservable().map({ AuthVM.AuthType(rawValue: $0)!
                    }),
                        createAccountRequest: bsCreateAccountButton.rx.tap.asObservable(),
                        autoServerSelected: adServerAuto.rx.tap.asObservable().map({
                            self.adServerAuto.isSelected
                        }))
        vM.isAdvancedMode.bind(to: self.advancedModeToggle.rx.isOn,
                               self.basicModeToggle.rx.isOn)
            .disposed(by: disposeBag)
        
        vM.isAdvancedMode.subscribe { [weak self] (isAdvanced: Bool) in
            guard let ss = self else { return }
            if isAdvanced {
                ss.view = ss.vAdvanced
            } else {
                ss.view = ss.vBasic
            }
        }.disposed(by: disposeBag)
        
        vM.initiateSignup.subscribe(onNext: {
            SAApp.ui().showCreateAccountVC()
        }).disposed(by: disposeBag)

        vM.advancedModeAuthType.subscribe(onNext: { [weak self] at in
            self?.setAdvancedAuthMode(at)
        }).disposed(by: disposeBag)
    }
    
    private func setAdvancedAuthMode(_ at: AuthVM.AuthType) {
        let viewToRemove, viewToAdd: UIView

        switch at {
        case .email:
            viewToAdd = adFormEmailAuth
            viewToRemove = adFormAccessIdAuth
        case .accessId:
            viewToRemove = adFormEmailAuth
            viewToAdd = adFormAccessIdAuth
        }

        viewToRemove.removeFromSuperview()
        adFormHostView.addSubview(viewToAdd)
        viewToAdd.topAnchor.constraint(equalTo: adFormHostView.topAnchor).isActive = true
        viewToAdd.bottomAnchor.constraint(equalTo: adFormHostView.bottomAnchor).isActive = true
        viewToAdd.leftAnchor.constraint(equalTo: adFormHostView.leftAnchor).isActive = true
        viewToAdd.rightAnchor.constraint(equalTo: adFormHostView.rightAnchor).isActive = true
    }
}
