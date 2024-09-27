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
                onStatusAction: {
                    if let channel = $0 {
                        SAChannelStatePopup.globalInstance().show(channel)
                    }
                }
            )
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.loadData(item.remoteId)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            observeNotification(
                name: NSNotification.Name.saChannelValueChanged,
                selector: #selector(handleValueChange)
            )
        }
        
        func onIssueIconTapped(issueMessage: String) {
            let alert = UIAlertController(title: "SUPLA", message: issueMessage, preferredStyle: .alert)
            let okButton = UIAlertAction(title: Strings.General.ok, style: .default)
            
            alert.title = NSLocalizedString("Warning", comment: "")
            alert.addAction(okButton)
            coordinator.present(alert, animated: true)
        }
        
        @objc
        private func handleValueChange(notification: Notification) {
            if
                let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
                let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
                !isGroup.boolValue
            {
                viewModel.reloadData(item.remoteId, remoteId.int32Value)
            }
        }
        
        static func create(item: ItemBundle) -> UIViewController {
            ViewController(viewModel: ViewModel(), item: item)
        }
    }
}
