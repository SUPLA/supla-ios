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

final class SAAuthorizationDialogVC: SACustomDialogVC<SAAuthorizationDialogViewState, SAAuthorizationDialogViewEvent, SAAuthorizationDialogVM> {
    private lazy var titleLabel: UILabel = SADialogTitleLabel()

    private lazy var topSeparatorView: SeparatorView = .init()
    
    private lazy var userNameField: SALabeledTextField = {
        let field = SALabeledTextField()
        field.label = Strings.AuthorizationDialog.emailAddress
        return field
    }()
    
    private lazy var passwordField: SALabeledPasswordField = {
        let field = SALabeledPasswordField()
        field.label = Strings.AuthorizationDialog.password
        return field
    }()
    
    private lazy var errorMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .error
        label.font = .subtitle2
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bottomSeparatorView: SeparatorView = .init()
    
    fileprivate lazy var negativeButton: SADialogNegativeButton = {
        let button = SADialogNegativeButton()
        button.setTitle(Strings.General.cancel, for: .normal)
        return button
    }()
    
    fileprivate lazy var positiveButton: SADialogPositiveButton = {
        let button = SADialogPositiveButton()
        button.setTitle(Strings.General.ok, for: .normal)
        return button
    }()
    
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let onAuthorizedCallback: () -> Void
    
    init(_ onAuthorizedCallback: @escaping () -> Void) {
        self.onAuthorizedCallback = onAuthorizedCallback
        super.init()
        
        viewModel = SAAuthorizationDialogVM()
        setupView()
    }
    
    override func handle(state: SAAuthorizationDialogViewState) {
        titleLabel.text = if (state.isCloudAccount) {
            Strings.AuthorizationDialog.cloudTitle
        } else {
            Strings.AuthorizationDialog.privateTitle
        }
        userNameField.text = state.userName
        userNameField.isEnabled = state.userNameEnabled
        passwordField.isError = state.error != nil
        errorMessage.text = state.error ?? ""
        
        positiveButton.isHidden = state.loading
        loadingIndicatorView.isHidden = !state.loading
        if (state.loading) {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
    
    override func handle(event: SAAuthorizationDialogViewEvent) {
        switch (event) {
        case .dismiss: dismiss(animated: true)
        }
    }
    
    func showAuthorization(_ presenter: UIViewController) {
        if (viewModel.isAuthorized()) {
            onAuthorizedCallback()
            return
        }
        
        presenter.present(self, animated: true)
    }
    
    private func setupView() {
        container.addSubview(titleLabel)
        container.addSubview(topSeparatorView)
        container.addSubview(userNameField)
        container.addSubview(passwordField)
        container.addSubview(errorMessage)
        container.addSubview(bottomSeparatorView)
        container.addSubview(negativeButton)
        container.addSubview(positiveButton)
        container.addSubview(loadingIndicatorView)
        
        negativeButton.rx.tap.subscribe(onNext: { [weak self] in self?.dismiss(animated: true) }).disposed(by: self)
        positiveButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    self?.viewModel.onOk(
                        userName: self?.userNameField.text ?? "",
                        password: self?.passwordField.text ?? ""
                    ) { [weak self] in 
                        self?.onAuthorizedCallback()
                        self?.dismiss(animated: true)
                    }
                }
            )
            .disposed(by: self)
        passwordField.rx.text
            .subscribe(onNext: { [weak self] in
                self?.positiveButton.isEnabled = $0 != nil && !$0!.isEmpty
            })
            .disposed(by: self)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Dimens.distanceDefault),
            titleLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            topSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimens.distanceDefault),
            topSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            userNameField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            userNameField.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            userNameField.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            passwordField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            passwordField.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: Dimens.distanceDefault),
            passwordField.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            errorMessage.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault + Dimens.distanceSmall),
            errorMessage.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 4),
            errorMessage.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault - Dimens.distanceSmall),
            
            bottomSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            bottomSeparatorView.topAnchor.constraint(equalTo: errorMessage.bottomAnchor, constant: Dimens.distanceDefault),
            bottomSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            negativeButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            negativeButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            negativeButton.rightAnchor.constraint(equalTo: container.centerXAnchor, constant: -Dimens.distanceDefault / 2),
            
            positiveButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            positiveButton.leftAnchor.constraint(equalTo: container.centerXAnchor, constant: Dimens.distanceDefault / 2),
            positiveButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            positiveButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Dimens.distanceDefault),
            
            loadingIndicatorView.centerXAnchor.constraint(equalTo: positiveButton.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: positiveButton.centerYAnchor)
        ])
    }
}
