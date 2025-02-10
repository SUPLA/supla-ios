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
    
extension ElectricityDataSelectionFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        let name: String
        let filters: ElectricityChartFilters
        
        init(name: String, filters: ElectricityChartFilters) {
            self.name = name
            self.filters = filters
            
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            let selectedType = filters.type
            
            state.title = name
            state.selectedType = selectedType
            state.availableTypes = filters.availableTypes
            state.selectablePhases = getPhases(
                selectedType: selectedType,
                availablePhases: filters.availablePhases,
                selectedPhases: filters.selectedPhases
            )
        }
        
        func onTypeChange(_ type: ElectricityMeterChartType) {
            state.selectablePhases = getPhases(
                selectedType: type,
                availablePhases: filters.availablePhases,
                selectedPhases: state.selectablePhases.filter { $0.selected }.map { $0.item }
            )
        }
        
        private func getPhases(selectedType: ElectricityMeterChartType, availablePhases: [Phase], selectedPhases: [Phase]) -> [SelectableItem<Phase>] {
            let disabledPhases = selectedType.needsPhases ? Phase.allCases.filter { !availablePhases.contains($0) } : Phase.allCases
            return Phase.allCases
                .map {
                    SelectableItem(
                        selected: selectedPhases.isEmpty ? availablePhases.contains($0) : selectedPhases.contains($0),
                        item: $0,
                        enabled: !disabledPhases.contains($0)
                    )
                }
        }
    }
}
