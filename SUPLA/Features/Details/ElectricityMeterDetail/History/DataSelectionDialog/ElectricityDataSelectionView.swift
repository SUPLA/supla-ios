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

extension ElectricityDataSelectionFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        var onTypeChange: (ElectricityMeterChartType) -> Void
        var onOk: () -> Void
        var onCancel: () -> Void

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(alignment: .leading, spacing: 0) {
                    SuplaCore.Dialog.Header(title: viewState.title)

                    Text(Strings.ElectricityMeter.chartDataType)
                        .fontPickerLabel()
                        .padding([.leading], Distance.default)
                    SuplaCore.Picker(
                        selected: $viewState.selectedType.onChange(onTypeChange),
                        items: viewState.availableTypes
                    )

                    if (viewState.selectedType.needsPhases) {
                        Text(Strings.ElectricityMeter.phases)
                            .fontPickerLabel()
                            .padding(.leading, Distance.default)
                            .padding(.top, Distance.small)
                        FlowHStack(data: viewState.selectablePhases) { index, item in
                            HStack {
                                Toggle(isOn: $viewState.selectablePhases[index].selected) {
                                    Text(item.item.label).fontBodyMedium()
                                }
                                .disabled(!item.enabled)
                                .toggleStyle(iOSCheckboxToggleStyle(color: item.item.color))
                            }
                        }
                        .padding([.leading, .trailing], Distance.default)
                        .padding(.top, 4)
                    }

                    SuplaCore.Dialog.Divider()
                        .padding(.top, Distance.default)

                    HStack(spacing: Distance.default) {
                        BorderedButton(title: Strings.General.cancel, fullWidth: true, action: onCancel)
                        FilledButton(title: Strings.General.ok, fullWidth: true, action: onOk)
                    }
                    .padding(Distance.default)
                }
            }
            .cornerRadius(Dimens.radiusDefault)
        }
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    let color: UIColor?
    let textFirst: Bool

    init(color: UIColor? = nil, textFirst: Bool = false) {
        self.color = color
        self.textFirst = textFirst
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                if (textFirst) {
                    configuration.label
                        .accentColor(Color.Supla.onBackground)
                }
                if let color = color {
                    Image(configuration.isOn ? .Icons.checkboxChecked : .Icons.checkboxEmpty)
                        .accentColor(Color(color))
                } else {
                    Image(configuration.isOn ? .Icons.checkboxChecked : .Icons.checkboxEmpty)
                }
                if (!textFirst) {
                    configuration.label
                        .accentColor(Color.Supla.onBackground)
                }
            }
        })
    }
}

#Preview {
    let state = ElectricityDataSelectionFeature.ViewState()
    state.title = "EM"
    state.selectablePhases = [
        SelectableItem(selected: true, item: .phase1),
        SelectableItem(selected: false, item: .phase2),
        SelectableItem(selected: true, item: .phase3)
    ]

    return ElectricityDataSelectionFeature.View(viewState: state, onTypeChange: { _ in }, onOk: {}, onCancel: {})
}
