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

extension ThermostatSlavesFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        @Singleton<SuplaAppCoordinator> private var coordinator
        
        private let item: ItemBundle
        
        init(viewModel: ViewModel, item: ItemBundle) {
            self.item = item
            super.init(viewModel: viewModel)
            
            contentView = ThermostatSlavesFeature.View(
                viewState: state,
                onInfoAction: { [weak self] in self?.onIssueIconTapped(issueMessage: $0) },
                onStatusAction: { viewModel.showStateDialog(remoteId: $0, caption: $1) },
                onStateDialogDismiss: { viewModel.closeStateDialog() },
                onCaptionLongPress: { [weak self] thermostatData in
                    self?.showAuthorizationForCaptionChange(thermostatData.caption, thermostatData.id)
                },
                onCaptionChangeDismiss: { viewModel.closeCaptionChangeDialog() },
                onCaptionChangeApply: { viewModel.onCaptionChange($0) }
            )
            
            viewModel.observe(remoteId: Int(item.remoteId))
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.loadData(item.remoteId)
            
            observeNotification(name: NSNotification.Name("KSA-N17"), selector: #selector(onStateEvent))
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        func onIssueIconTapped(issueMessage: String) {
            let alert = UIAlertController(title: "SUPLA", message: issueMessage, preferredStyle: .alert)
            let okButton = UIAlertAction(title: Strings.General.ok, style: .default)
            
            alert.title = NSLocalizedString("Warning", comment: "")
            alert.addAction(okButton)
            coordinator.present(alert, animated: true)
        }
        
        @objc
        func onStateEvent(notification: NSNotification) {
            if let userInfo = notification.userInfo,
               let channelState = userInfo["state"] as? SAChannelStateExtendedValue
            {
                viewModel.updateStateDialog(channelState)
            }
        }
        
        private func showAuthorizationForCaptionChange(_ caption: String, _ remoteId: Int32) {
            SAAuthorizationDialogVC { [weak self] in
                self?.viewModel.changeChannelCaption(caption: caption, remoteId: remoteId)
            }.showAuthorization(self)
        }
        
        static func create(item: ItemBundle) -> UIViewController {
            ViewController(viewModel: ViewModel(), item: item)
        }
    }
}
