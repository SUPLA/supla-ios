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
    
class RgbAndDimmerDetailVC: BaseDetailVC<RgbAndDimmerDetailViewState, RgbAndDimmerDetailViewEvent, RgbAndDimmerDetailVM> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    init(item: ItemBundle, pages: [DetailPage]) {
        super.init(viewModel: RgbAndDimmerDetailVM(), item: item, pages: pages)
    }
    
    override func handle(state: RgbAndDimmerDetailViewState) {
        if let title = state.title { self.title = title }
        
        showSettings(hasSettings: state.showSettings)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSettings(hasSettings: viewModel.showSettings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    private func showSettings(hasSettings: Bool) {
        if navigationItem.rightBarButtonItem == nil && hasSettings {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: .iconSettings,
                style: .plain,
                target: self,
                action: #selector(openSettings)
            )
        }
    }
    
    @objc
    private func openSettings() {
        coordinator.navigateToLegacyDimmerSettings(channelId: item.remoteId)
    }
}
