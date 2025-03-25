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

import SwiftUI
import RxSwift

extension SuplaCore.Dialog {
    class BaseViewController<S: ObservableObject, V: View, VM: SuplaCore.BaseViewModel<S>>: UIViewController {
        @Singleton<GlobalSettings> private var settings
        
        var viewModel: VM
        var state: S
        var contentView: V!
        
        private lazy var hostingController: UIHostingController! = {
            let controller = UIHostingController(rootView: contentView)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            return controller
        }()
        
        private lazy var backgroundTapGestureDelegate = FilteredTapGestureDelegate { [weak self] in
            guard let self = self else { return false }
            return !self.hostingController.view.frame.contains($0.location(in: self.view))
        }

        private lazy var backgroundTapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap))
            recognizer.delegate = backgroundTapGestureDelegate
            return recognizer
        }()
        
        init(viewModel: VM) {
            self.viewModel = viewModel
            self.state = viewModel.state
            super.init(nibName: nil, bundle: nil)
            
            modalPresentationStyle = .overFullScreen
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
            viewModel.onViewDidLoad()
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.layer.backgroundColor = UIColor.transparent.cgColor
            
            view.addGestureRecognizer(backgroundTapGestureRecognizer)
            view.backgroundColor = .dialogScrim
            
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            
            setupConstraints()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            overrideUserInterfaceStyle = settings.darkMode.interfaceStyle
            viewModel.onViewWillAppear()
            
            NotificationCenter.default.addObserver(self, selector: #selector(onViewAppeared), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onViewDisappeared), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onViewAppeared()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            viewModel.onViewWillDisappear()
            
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            onViewDisappeared()
        }
        
        func observeNotification(name: NSNotification.Name?, selector: Selector) {
            NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
        }
        
        func setNeedsUpdateConstraints() {
            hostingController.view.setNeedsUpdateConstraints()
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                hostingController.view.widthAnchor.constraint(equalToConstant: 320)
            ])
        }
        
        @objc func onViewAppeared() {
            viewModel.onViewAppeared()
        }
        
        @objc func onViewDisappeared() {
            viewModel.onViewDisappeared()
        }
        
        @objc private func onBackgroundTap(_ gr: UIGestureRecognizer) {
            dismiss(animated: true)
        }
    }
}
