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
 `AccountCreationVC` - a view controller for managing authentication settings of a profile.
 */
class AccountCreationVC: BaseViewControllerVM<AccountCreationViewState, AccountCreationViewEvent, AccountCreationVM> {
    
    // MARK: UI variables
    @IBOutlet private var controlStack: UIStackView!
    @IBOutlet private var loadingStack: UIStackView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
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
    
    private var navigator: AuthCfgNavigationCoordinator? {
        get {
            navigationCoordinator as? AuthCfgNavigationCoordinator
        }
    }
    
    convenience init(navigationCoordinator: NavigationCoordinator, profileId: NSManagedObjectID?) {
        self.init(nibName: "AccountCreationVC", bundle: nil)
        self.navigationCoordinator = navigationCoordinator
        self.profileId = profileId
        
        viewModel = AccountCreationVM()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onBackButtonPressed(_:)),
            name: Notification.Name(kSAMenubarBackButtonPressed),
            object: nil
        )

        configureUI()
        bindVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData(profileId: profileId)
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
        
        [ bsEmailAddr, adEmailAddr, adServerAddrEmail, adAccessID, adAccessPwd, adServerAddrAccessId ].forEach {
            $0.delegate = self
            $0.font = .StaticSize.body2
        }
        bsEmailAddr.keyboardType = .emailAddress
        adEmailAddr.keyboardType = .emailAddress
        bsProfileName.font = .StaticSize.body2
        adProfileName.font = .StaticSize.body2
        modeToggleLabel.font = .StaticSize.body2
        modeToggle.tintColor = .switcherBackground
        modeToggle.onTintColor = .primary

        let gr = UITapGestureRecognizer(target: self,
                                        action: #selector(didTapBackground(_:)))
        view.addGestureRecognizer(gr)
        view.isUserInteractionEnabled = true
        
        createAccountButton.setAttributedTitle(NSLocalizedString("Create an account", comment: ""))
        modeToggleLabel.text = Strings.AccountCreation.advancedSettings
        createAccountPrompt.text = Strings.AccountCreation.createAccountPrompt
        createAccountButton.setTitle(Strings.AccountCreation.createAccountButton)
        
        bsYourAccount.text = Strings.AccountCreation.yourAccountLabel
        bsProfileNameLabel.text = Strings.AccountCreation.profileNameLabel
        adProfileNameLabel.text = Strings.AccountCreation.profileNameLabel
        bsEmailAddrLabel.text = Strings.AccountCreation.emailLabel
        adEmailAddrLabel.text = Strings.AccountCreation.emailLabel
        adServerAddrEmailLabel.text = Strings.AccountCreation.serverLabel
        adAccessIDLabel.text = Strings.AccountCreation.accessIdLabel
        adAccessPwdLabel.text = Strings.AccountCreation.passwordLabel
        adServerAddrAccessIdLabel.text = Strings.AccountCreation.serverLabel
        adAccessIdWizardWarning.text = Strings.AccountCreation.wizardWarningText
        adAuthType.setTitle(Strings.AccountCreation.emailSegment, forSegmentAt: 0)
        adAuthType.setTitle(Strings.AccountCreation.accessIdSegment, forSegmentAt: 1)
        
        adAccessIdWizardWarning.textColor = .error
        adAccessIdWizardWarning.layer.cornerRadius = 9
        adAccessIdWizardWarning.layer.borderColor = UIColor.error.cgColor
        adAccessIdWizardWarning.layer.borderWidth = 1
        
        deleteButton.setTitle(Strings.Profiles.delete, for: .normal)
        deleteButton.backgroundColor = .background
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.primary.cgColor

        [adFormEmailAuth, adFormAccessIdAuth].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if #available(iOS 11.0, *) {
            controlStack.setCustomSpacing(24, after: confirmButton)
        }
        
        loadingStack.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func bindVM() {
        viewModel.advancedMode.subscribe { [weak self] (isAdvanced: Bool) in
            guard let ss = self else { return }
            if isAdvanced {
                ss.setContentView(ss.vAdvanced)
            } else {
                ss.setContentView(ss.vBasic)
            }
            self?.modeToggle.isOn = isAdvanced
        }.disposed(by: self)
        
        viewModel.bind(field: \.profileName, toOptional: bsProfileName.rx.text.asObservable())
        viewModel.bind(field: \.profileName, toOptional: adProfileName.rx.text.asObservable())
        viewModel.bind(field: \.authType, toOptional: adAuthType.rx.selectedSegmentIndex.asObservable().map({ AccountCreationViewState.AuthType(rawValue: $0) }))
        viewModel.bind(field: \.serverAddressForEmail, toOptional: adServerAddrEmail.rx.text.asObservable())
        viewModel.bind(field: \.serverAddressForAccessId, toOptional: adServerAddrAccessId.rx.text.asObservable())
        viewModel.bind(field: \.accessId, toOptional: adAccessID.rx.text.asObservable())
        viewModel.bind(field: \.accessIdPassword, toOptional: adAccessPwd.rx.text.asObservable())
        
        viewModel.bind(confirmButton.rx.tap.asObservable()) { [weak self] in self?.viewModel.save() }
        viewModel.bind(bsEmailAddr.rx.text.asObservable()) { [weak self] in
            self?.viewModel.setEmailAddress($0!)
        }
        viewModel.bind(adEmailAddr.rx.text.asObservable()) { [weak self] in
            self?.viewModel.setEmailAddress($0!)
        }
        viewModel.bind(modeToggle.rx.isOn.asObservable()) { [weak self] isOn in
            self?.viewModel.toggleAdvancedState(isOn)
        }
        viewModel.bind(
            adServerAuto.rx.tap.asObservable()
                .map({ [weak self] in self?.adServerAuto.isSelected == true })
        ) { [weak self] isOn in self?.viewModel.setServerAutodetect(isOn) }
        viewModel.bind(deleteButton.rx.tap.asObservable()) { [weak self] in
            self?.viewModel.removeTapped()
        }
        viewModel.bind(createAccountButton.rx.tap.asObservable()) { [weak self] in
            self?.viewModel.addAccountTapped()
        }
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
    
    // MARK: Handlers
    override func handle(event: AccountCreationViewEvent) {
        loadingStack.isHidden = true
        
        switch (event) {
        case .showRemovalDialog:
            handleShowRemovalDialogEvent()
            break
        case .formSaved(let needsReauth):
            handleFormSavedEvent(needsReauth)
            break
        case .navigateToCreateAccount:
            navigator?.navigateToCreateAccount()
            break
        case .navigateToRemoveAccount(let needsRestart, let serverAddress):
            navigator?.navigateToRemoveAccount(needsRestart: needsRestart, serverAddress: serverAddress)
            break
        case .finish(let needsRestart, let needsReauth):
            if (needsRestart) {
                navigator?.restartAppFlow()
            } else if(needsReauth) {
                navigator?.finish(shouldReauthenticate: true)
            } else {
                navigator?.finish()
            }
            break
        case .showRemovalFailure:
            showInfoDialog(title: Strings.Cfg.Dialogs.Failed.title, message: Strings.Cfg.Dialogs.Failed.message)
            break
        case .showEmptyNameDialog:
            showInfoDialog(title: Strings.General.error, message: Strings.Cfg.Dialogs.missing_name)
            break
        case .showDuplicatedNameDialog:
            showInfoDialog(title: Strings.General.error, message: Strings.Cfg.Dialogs.duplicated_name)
            break
        case .showRequiredDataMisingDialog:
            showInfoDialog(title: Strings.General.error, message: Strings.Cfg.Dialogs.incomplete)
            break
        case .showBasicModeUnavailableDialog:
            displayBasicModeUnavailableAlert()
            break
        case .showProgress:
            loadingStack.isHidden = false
            break
        }
    }
    
    override func handle(state: AccountCreationViewState) {
        bsProfileName.text = state.profileName
        adProfileName.text = state.profileName
        bsEmailAddr.text = state.emailAddress
        adEmailAddr.text = state.emailAddress
        adAccessID.text = state.accessId
        adAccessPwd.text = state.accessIdPassword
        adServerAddrAccessId.text = state.serverAddressForAccessId
        
        adServerAddrEmail.text = state.serverAddressForEmail
        
        profileNameContainer.forEach { $0.isHidden = !state.profileNameVisible }
        createAccountPrompt.isHidden = state.profileNameVisible
        createAccountButton.isHidden = state.profileNameVisible
        deleteButton.isHidden = !state.deleteButtonVisible
        adServerAddrEmail.isEnabled = !state.serverAutoDetect
        adServerAuto.isSelected = state.serverAutoDetect
        setAdvancedAuthMode(state.authType)
        
        navigationItem.hidesBackButton = !state.backButtonVisible
        title = state.title
    }
    
    private func handleShowRemovalDialogEvent() {
        let actionSheet = UIAlertController(title: Strings.Cfg.removalConfirmationTitle, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: Strings.Cfg.removalActionLogout, style: .destructive, handler: { [weak self] action in
            self?.viewModel.logoutAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: Strings.Cfg.removalActionRemove, style: .destructive, handler: { [weak self] action in
            self?.viewModel.removeAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: Strings.General.cancel, style: .cancel, handler: { action in
            SALog.debug("User canceled removal action")
        }))
        self.present(actionSheet, animated: true)
    }
    
    private func handleFormSavedEvent(_ needsReauth: Bool) {
        if (needsReauth) {
            SAApp.revokeOAuthToken()
        }
        navigator?.finish(shouldReauthenticate: needsReauth)
        if (needsReauth || !SAApp.suplaClientConnected()) {
            NotificationCenter.default.post(name: .saConnecting, object: self, userInfo: nil)
        }
    }
    
    // MARK: Private functions
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
    
    private func setAdvancedAuthMode(_ at: AccountCreationViewState.AuthType) {
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
        let alert = UIAlertController(title: Strings.AccountCreation.basicModeNotAvailableTitle,
                                      message: Strings.AccountCreation.basicModeNotAvailableMessage,
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

extension AccountCreationVC: UITextFieldDelegate {
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
