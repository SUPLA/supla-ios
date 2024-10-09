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
    
extension ElectricityMeterHistoryFeature {
    class ViewController: BaseHistoryDetailVC {
        init(viewModel: ViewModel, item: ItemBundle, navigationItemProvider: NavigationItemProvider) {
            super.init(remoteId: item.remoteId, navigationItemProvider: navigationItemProvider)
            self.viewModel = viewModel
        }
        
        override func showDataSelectionDialog(_ channelSets: ChannelChartSets, _ filters: CustomChartFiltersContainer?) {
            guard let filters = filters?.filters as? ElectricityChartFilters else { return }
            if (filters.availableTypes.count == 1 && filters.availablePhases.count == 1) {
                return
            }
            
            let dialog = ElectricityDataSelectionFeature.ViewController.create(name: channelSets.name, filters: filters)
            dialog.onFinishCallback = { [weak self] type, phases in
                if let viewModel = self?.viewModel as? ElectricityMeterHistoryFeature.ViewModel {
                    viewModel.onDataSelectionChange(type: type, phases: phases)
                }
            }
            present(dialog, animated: true)
        }
        
        static func create(item: ItemBundle, navigationItemProvider: NavigationItemProvider) -> UIViewController {
            ViewController(viewModel: ViewModel(), item: item, navigationItemProvider: navigationItemProvider)
        }
    }
}
