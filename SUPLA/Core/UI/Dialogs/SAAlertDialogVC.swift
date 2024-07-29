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

final class SAAlertDialogVC: SACustomDialogVC<SAAlertDialogViewState, SAAlertDialogViewEvent, SAAlertDialogVM> {
    private lazy var titleLabel: UILabel = SADialogTitleLabel()

    private lazy var topSeparatorView: SeparatorView = .init()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body2
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bottomSeparatorView: SeparatorView = .init()
    
    fileprivate lazy var negativeButton: SADialogNegativeButton = .init()
    
    fileprivate lazy var positiveButton: SADialogPositiveButton = .init()
    
    private let showPositiveButton: Bool
    private let showNegativeButton: Bool
    
    init(
        title: String,
        message: String,
        positiveText: String? = Strings.General.yes,
        negativeText: String? = Strings.General.no
    ) {
        showPositiveButton = positiveText != nil
        showNegativeButton = negativeText != nil
        
        super.init()
        
        viewModel = SAAlertDialogVM()
        
        titleLabel.text = title
        messageLabel.text = message
        positiveButton.setTitle(positiveText, for: .normal)
        negativeButton.setTitle(negativeText, for: .normal)
        
        positiveButton.isHidden = !showPositiveButton
        negativeButton.isHidden = !showNegativeButton
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        container.addSubview(titleLabel)
        container.addSubview(topSeparatorView)
        container.addSubview(messageLabel)
        container.addSubview(bottomSeparatorView)
        container.addSubview(negativeButton)
        container.addSubview(positiveButton)
        
        negativeButton.rx.tap.subscribe(onNext: { [weak self] in self?.dismiss(animated: true) }).disposed(by: self)
        
        setupLayout()
    }
    
    private func setupLayout() {
        var constraints: [NSLayoutConstraint] = [
            titleLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Dimens.distanceDefault),
            titleLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            topSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimens.distanceDefault),
            topSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            messageLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
            messageLabel.topAnchor.constraint(equalTo: topSeparatorView.topAnchor, constant: Dimens.distanceDefault),
            messageLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault),
            
            bottomSeparatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            bottomSeparatorView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Dimens.distanceDefault),
            bottomSeparatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            
            negativeButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            
            positiveButton.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: Dimens.distanceDefault),
            positiveButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Dimens.distanceDefault)
        ]
        
        if (showPositiveButton && showNegativeButton) {
            constraints.append(contentsOf: [
                negativeButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                negativeButton.rightAnchor.constraint(equalTo: container.centerXAnchor, constant: -Dimens.distanceDefault / 2),
                
                positiveButton.leftAnchor.constraint(equalTo: container.centerXAnchor, constant: Dimens.distanceDefault / 2),
                positiveButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault)
            ])
        } else if (showPositiveButton) {
            constraints.append(contentsOf: [
                positiveButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                positiveButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault)
            ])
        } else if (showNegativeButton) {
            constraints.append(contentsOf: [
                negativeButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Dimens.distanceDefault),
                negativeButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Dimens.distanceDefault)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension Reactive where Base: SAAlertDialogVC {
    var positiveTap: Observable<Void> {
        base.positiveButton.rx.tap.asObservable()
    }

    var negativeTap: Observable<Void> {
        base.negativeButton.rx.tap.asObservable()
    }
}
