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
    
extension CarPlayListFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        @Singleton<SuplaAppCoordinator> private var coordinator
        
        override init(viewModel: ViewModel) {
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: viewModel.state,
                onNewItem: { [weak self] in self?.coordinator.navigateToCarPlayAdd() },
                onPlayMessagesChange: viewModel.onVoiceMessagesChanged,
                onItemTapped: { [weak self] in self?.coordinator.navigateToCarPlayEdit(id: $0) },
                onMoved: viewModel.onMoved
            )
            
            title = Strings.CarPlay.label
        }
        
        static func create() -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(viewModel: viewModel)
        }
    }
}
