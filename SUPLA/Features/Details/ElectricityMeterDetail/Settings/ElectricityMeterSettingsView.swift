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
    protocol ViewDelegate {
        func metricOnListChange(_ type: ElectricityMeterMeasurementType?)
        func metricOnListAggregationChange(_ aggregation: ListValueAggregation?)
        func metricOnListBalancingChange(_ type: ElectricityMeterBalanceType?)
        func currentMonthBalancingChange(_ type: ElectricityMeterBalanceType?)
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            let currentMonthBalancing = Binding<ElectricityMeterBalanceType?>(
                get: { viewState.currentMonthBalancing?.selected },
                set: { delegate?.currentMonthBalancingChange($0) }
            )
            let metricOnListBinding = Binding<ElectricityMeterMeasurementType?>(
                get: { viewState.metricOnList?.selected },
                set: { delegate?.metricOnListChange($0) }
            )
            let metricOnListAggregationBinding = Binding<ListValueAggregation?>(
                get: { viewState.metricOnListAggregation?.selected },
                set: { delegate?.metricOnListAggregationChange($0) }
            )
            let metricOnListBalancingBinding = Binding<ElectricityMeterBalanceType?>(
                get: { viewState.metricOnListBalancing?.selected },
                set: { delegate?.metricOnListBalancingChange($0) }
            )
            
            return BackgroundStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    SettingsView.Header(text: Strings.ElectricityMeter.settingsTitle.arguments(viewState.channelName))
                    
                    SettingsView.List {
                        if (viewState.currentMonthBalancing != nil) {
                            SettingsView.VerticalRow {
                                SettingsView.Label(text: Strings.ElectricityMeter.lastMonthBalancing)
                                SuplaCore.Picker(selected: currentMonthBalancing, items: viewState.currentMonthBalancing!.items)
                            }
                        }
                    }
                    
                    SettingsView.Header(text: Strings.ElectricityMeter.onList)
                        .padding(.top, Distance.default)
                    SettingsView.List {
                        if (viewState.metricOnList != nil) {
                            SettingsView.VerticalRow {
                                SettingsView.Label(text: Strings.ElectricityMeter.metricOnList)
                                SuplaCore.Picker(selected: metricOnListBinding, items: viewState.metricOnList!.items)
                            }
                        }
                        if (viewState.metricOnListAggregation != nil) {
                            SettingsView.VerticalRow {
                                SettingsView.Label(text: Strings.ElectricityMeter.metricOnListAggregation)
                                SuplaCore.Picker(
                                    selected: metricOnListAggregationBinding,
                                    items: viewState.metricOnListAggregation!.items
                                )
                            }
                        }
                        if (viewState.metricOnListBalancing != nil) {
                            SettingsView.VerticalRow {
                                SettingsView.Label(text: Strings.ElectricityMeter.metricOnListBalance)
                                SuplaCore.Picker(
                                    selected: metricOnListBalancingBinding,
                                    items: viewState.metricOnListBalancing!.items
                                )
                            }
                        }
                    }
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
        viewState: state
    )
}
