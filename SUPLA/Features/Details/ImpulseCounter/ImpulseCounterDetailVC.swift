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
    
class ImpulseCounterDetailVC: StandardDetailVC<ImpulseCounterDetailViewState, ImpulseCounterDetailViewEvent, ImpulseCounterDetailVM> {
    @Singleton<SuplaAppCoordinator> var coordinator
    
    init(item: ItemBundle, pages: [DetailPage]) {
        super.init(viewModel: ImpulseCounterDetailVM(), item: item, pages: pages)
    }
    
    override func handle(state: ImpulseCounterDetailViewState) {
        if let title = state.title { self.title = title }
        
        showOcrPhotoIcon(hasPhoto: state.hasPhoto)
    }
    
    override func handle(event: ImpulseCounterDetailViewEvent) {
        switch (event) {
        case let .openOcrPhoto(profileId, remoteId):
            coordinator.navigateToCounterPhoto(profileId: profileId, channelId: remoteId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showOcrPhotoIcon(hasPhoto: navigationItem.rightBarButtonItem == nil && viewModel.hasPhoto)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    private func showOcrPhotoIcon(hasPhoto: Bool) {
        if hasPhoto {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: .iconOcrPhoto,
                style: .plain,
                target: viewModel,
                action: #selector(viewModel.onPhotoButtonClick)
            )
        }
    }
}
