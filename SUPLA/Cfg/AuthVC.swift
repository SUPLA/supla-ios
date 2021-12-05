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
class AuthVC: BaseViewController {
    
    @IBOutlet private var controlStack: UIStackView!
    
    @IBOutlet private var modeToggle: UISwitch!
    @IBOutlet private var modeToggleLabel: UILabel!
    @IBOutlet private var containerView: UIScrollView!
    @IBOutlet private var createAccountPrompt: UILabel!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var confirmButton: UIButton!

    @IBOutlet private var vBasic: UIView!
    @IBOutlet private var bsEmailAddr: UITextField!
    @IBOutlet private var bsEmailAddrLabel: UILabel!

    @IBOutlet private var vAdvanced: UIView!
    @IBOutlet private var adAuthType: UISegmentedControl!
    @IBOutlet private var adEmailAddr: UITextField!
    @IBOutlet private var adEmailAddrLabel: UILabel!
    @IBOutlet private var adServerAddrEmail: UITextField!
    @IBOutlet private var adServerAddrEmailLabel: UILabel!
    @IBOutlet private var adAccessID: UITextField!
    @IBOutlet private var adAccessIDLabel: UILabel!
    @IBOutlet private var adAccessPwd: UITextField!
    @IBOutlet private var adAccessPwdLabel: UILabel!
    @IBOutlet private var adServerAddrAccessId: UITextField!
    @IBOutlet private var adServerAddrAccessIdLabel: UILabel!
    @IBOutlet private var adServerAuto: CheckBox!
    @IBOutlet private var adFormHostView: UIView!
    @IBOutlet private var adFormEmailAuth: UIView!
    @IBOutlet private var adFormAccessIdAuth: UIView!
    
    @IBOutlet private var adAccessIdWizardWarning: UILabel!
    
    @IBOutlet private var bottomOffset: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    private var vM: AuthVM!
    
    private let bottomMargin: CGFloat = 58
    
    private weak var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [Self.keyboardWillShowNotification, Self.keyboardWillHideNotification].forEach {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onKeyboardVisibilityChange(_:)),
                                                   name: $0, object: nil)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onBackButtonPressed(_:)),
                                               name: Notification.Name(kSAMenubarBackButtonPressed),
                                               object: nil)

        configureUI()
        bindVM()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientToScrollView()
    }
    
    private func configureUI() {
        [view, vBasic, vAdvanced, adFormHostView, adFormEmailAuth,
         adFormAccessIdAuth].forEach {
            $0.backgroundColor = .viewBackground
        }
        modeToggle.tintColor = .switcherBackground
        
        createAccountButton.setAttributedTitle(NSLocalizedString("Create an account", comment: ""))
        modeToggleLabel.text = Strings.Cfg.advancedSettings
        createAccountPrompt.text = Strings.Cfg.createAccountPrompt
        createAccountButton.setTitle(Strings.Cfg.createAccountButton)
        bsEmailAddrLabel.text = Strings.Cfg.emailLabel
        adEmailAddrLabel.text = Strings.Cfg.emailLabel
        adServerAddrEmailLabel.text = Strings.Cfg.serverLabel
        adAccessIDLabel.text = Strings.Cfg.accessIdLabel
        adAccessPwdLabel.text = Strings.Cfg.passwordLabel
        adServerAddrAccessIdLabel.text = Strings.Cfg.serverLabel
        adAccessIdWizardWarning.text = Strings.Cfg.wizardWarningText
        adAuthType.setTitle(Strings.Cfg.emailSegment, forSegmentAt: 0)
        adAuthType.setTitle(Strings.Cfg.accessIdSegment, forSegmentAt: 1)
        
        adAccessIdWizardWarning.textColor = .alertRed
        adAccessIdWizardWarning.layer.cornerRadius = 9
        adAccessIdWizardWarning.layer.borderColor = UIColor.alertRed.cgColor
        adAccessIdWizardWarning.layer.borderWidth = 1

        [adFormEmailAuth, adFormAccessIdAuth].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        bottomOffset.constant = bottomMargin
        
        if #available(iOS 11.0, *) {
            controlStack.setCustomSpacing(24, after: confirmButton)
        }
    }

    private func bindVM() {
        /* Initialize view model and bind its inputs to the UI components */
        let bindings = AuthVM.Inputs(basicEmail: bsEmailAddr.rx.text.asObservable(),
                                     advancedEmail: adEmailAddr.rx.text.asObservable(),
                                     accessID: adAccessID.rx.text.asObservable().map { Int($0 ?? "0") }.asObservable(),
                                     accessIDpwd: adAccessPwd.rx.text.asObservable(),
                                     serverAddressForEmail: adServerAddrEmail.rx.text.asObservable(),
                                     serverAddressForAccessID: adServerAddrAccessId.rx.text.asObservable(),
                                     toggleAdvancedState: modeToggle.rx.isOn.asObservable(),
                                     advancedModeAuthType: adAuthType.rx.selectedSegmentIndex.asObservable().map({ AuthVM.AuthType(rawValue: $0)!}).asObservable(),
        createAccountRequest: createAccountButton.rx.tap.asObservable(),
        autoServerSelected: adServerAuto.rx.tap.asObservable().map({
                                                    self.adServerAuto.isSelected
                                                }), formSubmitRequest: confirmButton.rx.tap.asObservable())
        
        vM = AuthVM(bindings: bindings,
                    profileManager: SAApp.profileManager())
        
        /* Bind view model outputs to UI components */
        vM.isAdvancedMode.bind(to: self.modeToggle.rx.isOn)
            .disposed(by: disposeBag)
        vM.serverAddressForEmail.bind(to: self.adServerAddrEmail.rx.text)
            .disposed(by: disposeBag)
        vM.serverAddressForAccessID.bind(to: self.adServerAddrAccessId.rx.text)
            .disposed(by: disposeBag)
        vM.emailAddress.bind(to: self.bsEmailAddr.rx.text, self.adEmailAddr.rx.text)
            .disposed(by: disposeBag)
        vM.isServerAutoDetect.bind(to: self.adServerAuto.rx.isSelected)
            .disposed(by: disposeBag)
        
        vM.isAdvancedMode.subscribe { [weak self] (isAdvanced: Bool) in
            guard let ss = self else { return }
            if isAdvanced {
                ss.setContentView(ss.vAdvanced)
            } else {
                ss.setContentView(ss.vBasic)
            }
        }.disposed(by: disposeBag)
        
        vM.initiateSignup.subscribe(onNext: {
            SAApp.ui().showCreateAccountVC()
        }).disposed(by: disposeBag)

        vM.advancedModeAuthType.subscribe(onNext: { [weak self] at in
            self?.setAdvancedAuthMode(at)
        }).disposed(by: disposeBag)
        
        vM.isServerAutoDetect.subscribe { [weak self] autoDetect in
            self?.adServerAddrEmail.isEnabled = autoDetect.element == false
        }.disposed(by: disposeBag)
        
        vM.formSaved.subscribe { [weak self] needsReauth in
            if needsReauth.element == true {
                SAApp.revokeOAuthToken()
                SAApp.db().deleteAllUserIcons()
            }
            SAApp.ui().showMainVC()
            if needsReauth.element == true || !SAApp.suplaClientConnected() {
                NotificationCenter.default.post(name: .saConnecting,
                                                object: self, userInfo: nil)
                let pm = SAApp.profileManager()
                let ai = pm.getCurrentAuthInfo()
                ai.preferredProtocolVersion = Int(SUPLA_PROTO_VERSION)
                pm.updateCurrentAuthInfo(ai)
                SAApp.suplaClient().reconnect()
            }
            self?.view = nil // A pathetic workaround before we implement vc lifecycle properly
        }.disposed(by: disposeBag)
        
        vM.basicModeUnavailable.subscribe(onNext: { [weak self] in
            self?.displayBasicModeUnavailableAlert()
        }).disposed(by: disposeBag)
        
        vM.signupPromptVisible.subscribe(onNext: {
            self.createAccountPrompt.isHidden = !$0
            self.createAccountButton.isHidden = !$0
            if !$0 { SAApp.ui().showMenubarBackBtn() }
        }).disposed(by: disposeBag)
    }
    
    private func setContentView(_ v: UIView) {
        containerView.subviews.first?.removeFromSuperview()
        containerView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        v.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        v.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        v.leftAnchor.constraint(equalTo: controlStack.leftAnchor).isActive = true
        v.rightAnchor.constraint(equalTo: controlStack.rightAnchor).isActive = true
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
        viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        viewToAdd.topAnchor.constraint(equalTo: adFormHostView.topAnchor).isActive = true
        viewToAdd.bottomAnchor.constraint(equalTo: adFormHostView.bottomAnchor).isActive = true
        viewToAdd.leftAnchor.constraint(equalTo: adFormHostView.leftAnchor).isActive = true
        viewToAdd.rightAnchor.constraint(equalTo: adFormHostView.rightAnchor).isActive = true
    }
    
    private func addGradientToScrollView() {
        let gradientLayer = CAGradientLayer()
        let innerColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        let outerColor = UIColor(white: 1.0, alpha: 0.0).cgColor
        let svBounds = containerView.bounds
        gradientLayer.bounds = svBounds
        gradientLayer.anchorPoint = .zero
        gradientLayer.colors = [ outerColor, innerColor, innerColor, outerColor ]
        gradientLayer.locations = [ 0.0, 0.05, 0.95, 1.0 ]
        containerView.superview?.layer.mask = gradientLayer
    }
    
    private func displayBasicModeUnavailableAlert() {
        let alert = UIAlertController(title: Strings.Cfg.basicModeNotAvailableTitle,
                                      message: Strings.Cfg.basicModeNotAvailableMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)
    }
    
    @objc private func onBackButtonPressed(_ n: Notification) {
        SAApp.ui().showMainVC()
        self.view = nil
    }

    @objc private func onKeyboardVisibilityChange(_ notification: Notification) {
        if notification.name == Self.keyboardWillShowNotification {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                bottomOffset.constant = 12 + keyboardSize.height
            }
        } else {
            bottomOffset.constant = bottomMargin
        }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: duration, animations: { self.view.layoutIfNeeded() }) { _ in
            if let fld = self.currentTextField {
                let destRect = self.containerView.convert(fld.bounds, from: fld)
                    .insetBy(dx: 0, dy: -self.bottomMargin / 2.0)
                self.containerView.scrollRectToVisible(destRect, animated: true)
                self.currentTextField = nil
            }
        }
    }
}

extension AuthVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
}
