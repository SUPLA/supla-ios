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
    
extension ValveGeneralFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        @Singleton<SuplaAppCoordinator> var coordinator
        
        private var channelId: Int32
        
        init(channelId: Int32, viewModel: ViewModel) {
            self.channelId = channelId
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: viewModel.state,
                onInfoClick: { viewModel.showStateDialog(remoteId: $0.channelId, caption: $0.caption) },
                onCaptionLongPress: { [weak self] sensorData in
                    self?.showAuthorizationForCaptionChange(sensorData.userCaption, sensorData.id)
                },
                onOpenClick: { viewModel.onActionClick(channelId, action: .open) },
                onCloseClick: { viewModel.onActionClick(channelId, action: .close) },
                onStateDialogDismiss: { viewModel.closeStateDialog() },
                onWarningDialogDismiss: { viewModel.closeValveAlertDialog() },
                onForceAction: { viewModel.forceAction(channelId, action: $0) },
                onCaptionChangeDismiss: { viewModel.closeCaptionChangeDialog() },
                onCaptionChangeApply: { viewModel.onCaptionChange($0) }
            )
            
            viewModel.observe(remoteId: Int(channelId))
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.loadData(channelId)
            
            observeNotification(name: NSNotification.Name("KSA-N17"), selector: #selector(onStateEvent))
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
        
        static func create(channelId: Int32) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(channelId: channelId, viewModel: viewModel)
        }
    }
}
