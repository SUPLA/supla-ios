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
    
extension ImpulseCounterGeneralFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        private let item: ItemBundle
        
        init(viewModel: ViewModel, item: ItemBundle) {
            self.item = item
            super.init(viewModel: viewModel)
            
            contentView = View(viewState: state)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            viewModel.observerDownload(item.remoteId)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            viewModel.loadData(item.remoteId)
            
            observeNotification(
                name: NSNotification.Name.saChannelValueChanged,
                selector: #selector(handleValueChange)
            )
        }
        
        @objc
        private func handleValueChange(notification: Notification) {
            if
                let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
                let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
                !isGroup.boolValue
            {
                if (remoteId.int32Value == item.remoteId) {
                    viewModel.loadData(item.remoteId)
                }
            }
        }
        
        static func create(item: ItemBundle) -> UIViewController {
            ViewController(viewModel: ViewModel(), item: item)
        }
    }
}
