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
        private var channelId: Int32
        
        init(channelId: Int32, viewModel: ViewModel) {
            self.channelId = channelId
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: viewModel.state,
                emState: viewModel.electricityState,
                icState: viewModel.impulseCounterState,
                onTurnOff: { viewModel.turnOff(remoteId: channelId) },
                onTurnOn: { viewModel.turnOn(remoteId: channelId) },
                onIntroductionClose: { viewModel.onIntroductionClose() },
                onForceTurnOn: { viewModel.forceTurnOnAction(remoteId: channelId) },
                onAlertClose: viewModel.closeAlertDialog
            )
            
            viewModel.observe(remoteId: Int(channelId))
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.loadChannel(remoteId: channelId)
        }
        
        static func create(channelId: Int32) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(channelId: channelId, viewModel: viewModel)
        }
    }
}
