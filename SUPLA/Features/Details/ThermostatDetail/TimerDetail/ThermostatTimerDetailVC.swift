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

extension ThermostatTimerDetailFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        private let item: ItemBundle
     
        init(item: ItemBundle, viewModel: ThermostatTimerDetailFeature.ViewModel) {
            self.item = item
            super.init(viewModel: viewModel)
            
            contentView = View(
                state: viewModel.state,
                delegate: viewModel
            )
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewModel.loadData()
            
            observeNotification(
                name: NSNotification.Name.saChannelValueChanged,
                selector: #selector(handleChannelValueChange)
            )
        }
        
        @objc
        private func handleChannelValueChange(notification: Notification) {
            if let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
               let remoteId = notification.userInfo?["remoteId"] as? NSNumber
            {
                if (!isGroup.boolValue && remoteId.int32Value == item.remoteId) {
                    viewModel.loadData()
                }
            }
        }
        
        static func create(item: ItemBundle) -> UIViewController {
            let viewModel = ViewModel(item: item)
            return ViewController(item: item, viewModel: viewModel)
        }
    }
}
