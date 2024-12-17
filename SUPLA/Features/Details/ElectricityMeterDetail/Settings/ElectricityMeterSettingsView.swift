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
    
import SwiftUI

extension ElectricityMeterSettingsFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        
        var onShowOnChannelsListChange: (SuplaElectricityMeasurementType) -> Void
        var onBalancingChange: (ElectricityMeterBalanceType?) -> Void
        
        var body: some SwiftUI.View {
            let selectedTypeBinding = Binding<SuplaElectricityMeasurementType>(
                get: { viewState.showOnChannelsList.selected },
                set: { onShowOnChannelsListChange($0) }
            )
            let selectedBalancingBinding = Binding<ElectricityMeterBalanceType?>(
                get: { viewState.balancing?.selected },
                set: { onBalancingChange($0) }
            )
            
            return BackgroundStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.ElectricityMeter.settingsTitle.arguments(viewState.channelName).uppercased())
                        .fontBodyMedium()
                        .padding([.leading, .trailing], Distance.default)
                        .padding([.bottom], Distance.small)
                    VStack(alignment: .leading, spacing: 0) {
                        SuplaCore.Divider().color(Color.Supla.separator)
                            .padding([.bottom], Distance.small)
                        
                        Text(Strings.ElectricityMeter.settingsListItem.uppercased())
                            .fontBodySmall()
                            .textColor(Color.Supla.onSurfaceVariant)
                            .padding([.leading, .trailing], Distance.default)
                        SuplaCore.Picker(selected: selectedTypeBinding, items: viewState.showOnChannelsList.items)
                        
                        if let balancingUnwrapped = Binding(selectedBalancingBinding) {
                            SuplaCore.Divider().color(Color.Supla.separator)
                                .padding([.top, .bottom], Distance.small)
                            
                            Text(Strings.ElectricityMeter.lastMonthBalancing.uppercased())
                                .fontBodySmall()
                                .textColor(Color.Supla.onSurfaceVariant)
                                .padding([.leading, .trailing], Distance.default)
                            SuplaCore.Picker(selected: balancingUnwrapped, items: viewState.balancing!.items)
                        }
                        
                        SuplaCore.Divider().color(Color.Supla.separator)
                            .padding([.top], Distance.small)
                    }.background(Color.Supla.surface)
                }
                .padding([.top, .bottom], Distance.default)
            }
        }
    }
}

#Preview {
    let state = ElectricityMeterSettingsFeature.ViewState()
    state.channelName = "Electricity Meter"
    
    return ElectricityMeterSettingsFeature.View(
        viewState: state,
        onShowOnChannelsListChange: { _ in },
        onBalancingChange: { _ in }
    )
}
