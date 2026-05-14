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

extension ImpulseCounterSettingsFeature {
    protocol ViewDelegate {
        func onListValueAggregationChanged(_ newValue: ListValueAggregation?)
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?

        var body: some SwiftUI.View {
            let listValueAggregationBinding = Binding<ListValueAggregation?>(
                get: { viewState.listValueAggregation.selected },
                set: { delegate?.onListValueAggregationChanged($0) }
            )

            BackgroundStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    SettingsView.Header(text: Strings.ElectricityMeter.settingsTitle.arguments(viewState.channelName))

                    SettingsView.List {
                        SettingsView.VerticalRow {
                            SettingsView.Label(text: Strings.ElectricityMeter.settingsListItem)
                            SuplaCore.Picker(
                                selected: listValueAggregationBinding,
                                items: viewState.listValueAggregation.items
                            )
                        }
                    }
                }
                .padding(.vertical, Distance.default)
            }
        }
    }
}

#Preview {
    let state = ImpulseCounterSettingsFeature.ViewState()
    state.channelName = "Impulse counter"

    return ImpulseCounterSettingsFeature.View(
        viewState: state
    )
}
