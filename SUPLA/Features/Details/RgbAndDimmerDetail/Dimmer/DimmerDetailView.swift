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

extension DimmerDetailFeature {
    protocol ViewDelegate {
        func onBrightnessSelectionStarted()
        func onBrightnessSelecting(_ brightness: Int)
        func onBrightnessSelected()
        func turnOn()
        func turnOff()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?

        @StateObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                if (orientationObserver.orientation.isLandscape) {
                    landscape()
                } else {
                    portrait()
                }

                if (viewState.loadingState.loading) {
                    SuplaCore.LoadingScrim()
                }
            }
        }
        
        @ViewBuilder
        private func portrait() -> some SwiftUI.View {
            VStack(spacing: 0) {
                if let stateData = viewState.deviceStateData {
                    DeviceStateView(data: stateData)
                }
                ChannelIssuesView(issues: viewState.issues)

                Spacer()
                brightnessBox()
                selector()

                Spacer()
                buttons()
            }
        }
        
        @ViewBuilder
        private func landscape() -> some SwiftUI.View {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    if let stateData = viewState.deviceStateData {
                        DeviceStateView(data: stateData)
                    }
                    ChannelIssuesView(issues: viewState.issues)
                    
                    brightnessBox()
                    Spacer()
                    
                    buttons()
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 0) {
                    selector()
                        .padding(Distance.default)
                }
                .frame(maxWidth: .infinity)
            }
        }

        @ViewBuilder
        private func brightnessBox() -> some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                Text(Strings.RgbDetail.brightness)
                    .fontLabelMedium()
                    .textColor(.Supla.onSurfaceVariant)
                Text(viewState.value.brightnessString)
                    .fontBodyMedium()
                    .textColor(.Supla.onBackground)
            }
            .padding([.leading, .trailing], Distance.default)
            .padding([.top, .bottom], Distance.small)
            .background(Color.Supla.surface.clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault)))
            .padding(Distance.default)
        }

        @ViewBuilder
        private func selector() -> some SwiftUI.View {
            LinearColorSelector(
                value: viewState.value.brightness?.asPercentageFloat,
                selectedColor: viewState.value.brightness?.asGrayColor,
                valueMarkers: viewState.value.markers.map { $0.asPercentageFloat },
                enabled: !viewState.offline,
                onValueChangeStarted: { delegate?.onBrightnessSelectionStarted() },
                onValueChanging: { delegate?.onBrightnessSelecting(Int($0 * 100)) },
                onValueChanged: { delegate?.onBrightnessSelected() }
            )
            .frame(width: 40)
            .frame(maxHeight: 350)
        }

        @ViewBuilder
        private func buttons() -> some SwiftUI.View {
            if let onButtonState = viewState.onButtonState,
               let offButtonState = viewState.offButtonState
            {
                SwitchButtons(
                    leftButton: offButtonState,
                    rightButton: onButtonState,
                    enabled: !viewState.offline,
                    onLeftButtonClick: { delegate?.turnOff() },
                    onRightButtonClick: { delegate?.turnOn() }
                )
            }
        }
    }
}

#Preview {
    let viewState = DimmerDetailFeature.ViewState()
    viewState.deviceStateData = DeviceStateData(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: "dimmer-on"),
        value: Strings.General.on
    )
    viewState.onButtonState = .init(
        icon: .originalSuplaIcon(name: "dimmer-on"),
        label: Strings.General.turnOn,
        active: true,
        type: .positive
    )
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "dimmer-off"),
        label: Strings.General.turnOff,
        active: false,
        type: .positive
    )
    viewState.value = .single(brightness: 50)
    viewState.loadingState = viewState.loadingState.copy(loading: false)

    return DimmerDetailFeature.View(
        viewState: viewState,
        delegate: nil,
    )
}
