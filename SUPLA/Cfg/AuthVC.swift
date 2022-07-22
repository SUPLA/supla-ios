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
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var createAccountPrompt: UILabel!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!

    @IBOutlet private var vBasic: UIView!
    @IBOutlet private var bsYourAccount: UILabel!

    
    @IBOutlet var profileNameContainer: [UIView]!
    @IBOutlet private var bsProfileName: UITextField!
    @IBOutlet private var bsProfileNameLabel: UILabel!
    @IBOutlet private var bsEmailAddr: UITextField!
    @IBOutlet private var bsEmailAddrLabel: UILabel!

    @IBOutlet private var vAdvanced: UIView!
    @IBOutlet private var adAuthType: UISegmentedControl!
    @IBOutlet private var adProfileName: UITextField!
    @IBOutlet private var adProfileNameLabel: UILabel!
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
    @IBOutlet private var topOffset: NSLayoutConstraint!
    
    @IBOutlet weak var adAccessIdWizardWarningHeight: NSLayoutConstraint!
    
    
    private let disposeBag = DisposeBag()
    private var vM: AuthVM!
    
    private let minTopMargin: CGFloat = 35
    private let minBottomMargin: CGFloat = 15
    private let topMargin: CGFloat = 65
    private let bottomMargin: CGFloat = 58
    private let minHeight: CGFloat = 700
    
    private let warningMaxHeight: CGFloat = 126
    private let warningMinHeight: CGFloat = 50
    
    private weak var currentTextField: UITextField?
    private weak var activeContentView: UIView?
    private var profileId: NSManagedObjectID?
    
    var viewModel: AuthVM {
        loadViewIfNeeded()
        assert(vM != nil)
        return vM
    }

    convenience init(navigationCoordinator: NavigationCoordinator,
                     profileId: NSManagedObjectID?) {
        self.init(nibName: "AuthVC", bundle: nil)
        self.navigationCoordinator = navigationCoordinator
        self.profileId = profileId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.NavBar.titleSupla
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onBackButtonPressed(_:)),
                                               name: Notification.Name(kSAMenubarBackButtonPressed),
                                               object: nil)

        navigationItem.hidesBackButton = !SAApp.configIsSet() ||
            !SAApp.isClientRegistered()

        configureUI()
        bindVM()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let warningOrigin = adAccessIdWizardWarning.superview?.convert(adAccessIdWizardWarning.frame.origin, to: nil)
        let btnOrigin = confirmButton.superview?.convert(confirmButton.frame.origin, to: nil)

        if (warningOrigin == nil || btnOrigin == nil) {
            adAccessIdWizardWarning.isHidden = true
        } else {
            var height =  btnOrigin!.y - warningOrigin!.y - 15
            if (height > warningMaxHeight) {
                height = warningMaxHeight
            }
            
            if (height >= warningMinHeight) {
                adAccessIdWizardWarningHeight.constant = height;
                adAccessIdWizardWarning.isHidden = false
            } else {
                adAccessIdWizardWarning.isHidden = true
                adAccessIdWizardWarningHeight.constant = 0;
            }
        }
    }

    override func adjustsStatusBarBackground() -> Bool {
        return true
    }
    
    override func hidesNavigationBar() -> Bool {
        return !adjustsStatusBarBackground()
    }
    
    private func configureUI() {
        [vBasic, vAdvanced, adFormHostView, adFormEmailAuth,
         adFormAccessIdAuth].forEach {
            $0.backgroundColor = self.view.backgroundColor
        }
        
        [ bsEmailAddr, adEmailAddr, adServerAddrEmail, adAccessID, adAccessPwd,
          adServerAddrAccessId ].forEach { $0.delegate = self }
        modeToggle.tintColor = .switcherBackground

        let gr = UITapGestureRecognizer(target: self,
                                        action: #selector(didTapBackground(_:)))
        view.addGestureRecognizer(gr)
        view.isUserInteractionEnabled = true
        
        createAccountButton.setAttributedTitle(NSLocalizedString("Create an account", comment: ""))
        modeToggleLabel.text = Strings.Cfg.advancedSettings
        createAccountPrompt.text = Strings.Cfg.createAccountPrompt
        createAccountButton.setTitle(Strings.Cfg.createAccountButton)
        
        bsYourAccount.text = Strings.Cfg.yourAccountLabel
        bsProfileNameLabel.text = Strings.Cfg.profileNameLabel
        adProfileNameLabel.text = Strings.Cfg.profileNameLabel
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
        
        deleteButton.setTitle(Strings.Profiles.delete, for: .normal)
        deleteButton.backgroundColor = .white
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.suplaGreenBackground.cgColor

        [adFormEmailAuth, adFormAccessIdAuth].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if #available(iOS 11.0, *) {
            controlStack.setCustomSpacing(24, after: confirmButton)
        }
        
    }

    private func bindVM() {
        /* Initialize view model and bind its inputs to the UI components */
        let bindings = AuthVM.Inputs(basicEmail: bsEmailAddr.rx.text.asObservable(),
                                     basicName: bsProfileName.rx.text.asObservable(),
                                     advancedEmail: adEmailAddr.rx.text.asObservable(),
                                     advancedName: adProfileName.rx.text.asObservable(),
                                     accessID: adAccessID.rx.text.asObservable().map { Int($0 ?? "0") }.asObservable(),
                                     accessIDpwd: adAccessPwd.rx.text.asObservable(),
                                     serverAddressForEmail: adServerAddrEmail.rx.text.asObservable(),
                                     serverAddressForAccessID: adServerAddrAccessId.rx.text.asObservable(),
                                     toggleAdvancedState: modeToggle.rx.isOn.asObservable(),
                                     advancedModeAuthType: adAuthType.rx.selectedSegmentIndex.asObservable().map({ AuthVM.AuthType(rawValue: $0)!}).asObservable(),
        createAccountRequest: createAccountButton.rx.tap.asObservable(),
        autoServerSelected: adServerAuto.rx.tap.asObservable().map({
                                                    self.adServerAuto.isSelected
                                                }),
                                     formSubmitRequest: confirmButton.rx.tap.asObservable(),
                                     accountDeleteRequest: deleteButton.rx.tap.asObservable())
        
        vM = AuthVM(bindings: bindings,
                    profileManager: SAApp.profileManager(),
                    profileId: profileId)

        
        profileNameContainer.forEach {
            $0.isHidden = !vM.allowsEditingProfileName
        }
        
        deleteButton.isHidden = !vM.allowsDeletingProfile
        
        /* Bind view model outputs to UI components */
        vM.isAdvancedMode.bind(to: self.modeToggle.rx.isOn)
            .disposed(by: disposeBag)
        vM.serverAddressForEmail.bind(to: self.adServerAddrEmail.rx.text)
            .disposed(by: disposeBag)
        vM.serverAddressForAccessID.bind(to: self.adServerAddrAccessId.rx.text)
            .disposed(by: disposeBag)
        vM.emailAddress.bind(to: self.bsEmailAddr.rx.text, self.adEmailAddr.rx.text)
            .disposed(by: disposeBag)
        vM.profileName.bind(to: self.bsProfileName.rx.text,
                            self.adProfileName.rx.text)
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
        
        vM.advancedModeAuthType.subscribe(onNext: { [weak self] at in
            self?.setAdvancedAuthMode(at)
        }).disposed(by: disposeBag)
        
        vM.isServerAutoDetect.subscribe { [weak self] autoDetect in
            self?.adServerAddrEmail.isEnabled = autoDetect.element == false
        }.disposed(by: disposeBag)

        vM.accessID.subscribe { [weak self] accessID in
            guard let accessID = accessID.element! else { return }
            self?.adAccessID.text = String(accessID)
        }.disposed(by: disposeBag)
        
        vM.accessIDpwd.bind(to: self.adAccessPwd.rx.text).disposed(by: disposeBag)
        
        vM.formSaved.subscribe { [weak self] needsReauth in
            if needsReauth.element == true {
                SAApp.revokeOAuthToken()
                SAApp.db().deleteAllUserIcons()
            }
            (self?.navigationCoordinator as? AuthConfigActionHandler)?.didFinish(shouldReauthenticate: needsReauth.element!)
            if needsReauth.element == true || !SAApp.suplaClientConnected() {
                NotificationCenter.default.post(name: .saConnecting,
                                                object: self, userInfo: nil)
                let pm = SAApp.profileManager()
                let ai = pm.getCurrentAuthInfo()
                ai.preferredProtocolVersion = Int(SUPLA_PROTO_VERSION)
                pm.updateCurrentAuthInfo(ai)
                SAApp.suplaClient().reconnect()
            }
        }.disposed(by: disposeBag)
        
        vM.basicModeUnavailable.subscribe(onNext: { [weak self] in
            self?.displayBasicModeUnavailableAlert()
        }).disposed(by: disposeBag)
        
        vM.signupPromptVisible.subscribe(onNext: {
            self.createAccountPrompt.isHidden = !$0
            self.createAccountButton.isHidden = !$0
        }).disposed(by: disposeBag)
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        var _topMargin = topMargin;
        var _bottomMargin = bottomMargin;
        
        var diff = minHeight - view.frame.size.height;
       
        if (diff > 0) {
            
            if (bottomMargin-diff < minBottomMargin) {
                diff += diff - (bottomMargin-minBottomMargin)
                _bottomMargin = minBottomMargin;
                
                if (topMargin-diff < minTopMargin) {
                    _topMargin = minTopMargin;
                } else {
                    _topMargin -= diff;
                }
            } else {
                _bottomMargin-=diff;
            }
        }
        
        if let navbar = navigationController?.navigationBar, !navbar.isHidden {
            let fr = navbar.frame
            topOffset.constant = _topMargin + fr.origin.x + fr.size.height
        }
        
        bottomOffset.constant = _bottomMargin
        
    }
    
    private func setContentView(_ v: UIView) {
        activeContentView?.removeFromSuperview()
        containerView.addSubview(v)
        activeContentView = v
        v.translatesAutoresizingMaskIntoConstraints = false
        v.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        v.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        v.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func setAdvancedAuthMode(_ at: AuthVM.AuthType) {
        let viewToRemove, viewToAdd: UIView

        switch at {
        case .email:
            viewToAdd = adFormEmailAuth
            viewToRemove = adFormAccessIdAuth
            adAuthType.selectedSegmentIndex = 0
        case .accessId:
            viewToRemove = adFormEmailAuth
            viewToAdd = adFormAccessIdAuth
            adAuthType.selectedSegmentIndex = 1
        }
        
        viewToRemove.removeFromSuperview()
        adFormHostView.addSubview(viewToAdd)
        
        viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        viewToAdd.topAnchor.constraint(equalTo: adFormHostView.topAnchor).isActive = true
        viewToAdd.bottomAnchor.constraint(equalTo: adFormHostView.bottomAnchor).isActive = true
        viewToAdd.leftAnchor.constraint(equalTo: adFormHostView.leftAnchor).isActive = true
        viewToAdd.rightAnchor.constraint(equalTo: adFormHostView.rightAnchor).isActive = true
     
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
        navigationCoordinator?.finish()
    }
    
    @objc private func didTapBackground(_ gr: UITapGestureRecognizer) {
        currentTextField?.resignFirstResponder()
    }
    
    private func nextInSequence(for fld: UITextField) -> UITextField? {
        switch fld {
        case adAccessID: return adAccessPwd
        case adAccessPwd: return adServerAddrAccessId
        default: return nil
        }
    }
}

extension AuthVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let tf = nextInSequence(for: textField) {
            tf.becomeFirstResponder()
        }
        return true
    }
}
