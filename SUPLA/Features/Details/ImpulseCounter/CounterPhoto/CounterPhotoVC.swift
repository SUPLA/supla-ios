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
    
extension CounterPhotoFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        
        @Singleton<SuplaAppCoordinator> var coordinator
        
        private var profileId: Int32
        private var channelId: Int32
        
        init(profileId: Int32, channelId: Int32, viewModel: ViewModel) {
            self.profileId = profileId
            self.channelId = channelId
            super.init(viewModel: viewModel)
            
            contentView = View(
                viewState: state,
                onUrlClick: coordinator.openUrl(url:),
                onRefresh: {
                    await viewModel.onRefresh(channelId, profileId)
                }
            )
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.loadData(channelId, profileId)
            
            title = Strings.CounterPhoto.toolbar
        }
        
        static func create(profileId: Int32, channelId: Int32) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(profileId: profileId, channelId: channelId, viewModel: viewModel)
        }
    }
}
