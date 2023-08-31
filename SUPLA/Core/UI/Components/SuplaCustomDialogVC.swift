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

import Foundation

class SuplaCustomDialogVC<S : ViewState, E : ViewEvent, VM : BaseViewModel<S, E>>: BaseViewControllerVM<S, E, VM> {
    
    var container: UIView {
        get { containerView }
    }
    
    private lazy var containerView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .surface
        view.layer.cornerRadius = Dimens.radiusDefault
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var backgroundTapGestureDelegate = {
        FilteredTapGestureDelegate() { !self.container.frame.contains($0.location(in: self.view))}
    }()
    private lazy var backgroundTapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap))
        recognizer.delegate = backgroundTapGestureDelegate
        return recognizer
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBackgroundView.isHidden = true
        
        view.addGestureRecognizer(backgroundTapGestureRecognizer)
        view.backgroundColor = .dialogScrim
        
        super.view.addSubview(containerView)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: super.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: super.view.centerYAnchor),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 320)
        ])
    }
    
    @objc private func onBackgroundTap(_ gr: UIGestureRecognizer) {
        dismiss(animated: true)
    }
}
