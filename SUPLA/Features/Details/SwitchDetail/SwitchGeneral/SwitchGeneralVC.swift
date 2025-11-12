//
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
    
extension SwitchGeneralFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        private var itemBundle: ItemBundle
        private lazy var stateViewModel: StateDialogFeature.ViewModel = {
            let viewModel = StateDialogFeature.ViewModel { [weak self] in
                self?.showAuthorizationLightSourceLifespanSettings($0, $1, $2)
            }
            return viewModel
        }()
        private lazy var captionChangeViewModel = CaptionChangeDialogFeature.ViewModel()
        
        init(itemBundle: ItemBundle, viewModel: ViewModel) {
            self.itemBundle = itemBundle
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: viewModel.state,
                emState: viewModel.electricityState,
                icState: viewModel.impulseCounterState,
                stateDialogViewModel: stateViewModel,
                captionChangeDialogViewModel: captionChangeViewModel,
                delegate: viewModel,
                onInfoClick: { [weak self] in self?.stateViewModel.show(remoteId: $0.channelId) },
                onCaptionLongPress: { [weak self] in self?.captionChangeViewModel.show(self, sensorData: $0) }
            )
            
            switch (itemBundle.subjectType) {
            case .channel: viewModel.observeChannel(remoteId: Int(itemBundle.remoteId))
            case .group: viewModel.observeGroup(remoteId: itemBundle.remoteId)
            case .scene: break
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewModel.loadData(remoteId: itemBundle.remoteId, type: itemBundle.subjectType)
        }
        
        static func create(itemBundle: ItemBundle) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(itemBundle: itemBundle, viewModel: viewModel)
        }
    }
}
