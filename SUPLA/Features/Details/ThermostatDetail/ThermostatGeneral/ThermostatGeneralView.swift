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

import RxSwift
import SharedCore
import SwiftUI

extension ThermostatGeneralFeature {
    protocol ViewDelegate {
        func onPositionEvent(_ event: SetpointEvent)
        func onTemperatureChange(_ step: TemperatureChangeStep)
        func onPowerButtonTap()
        func onManualButtonTap()
        func onWeeklyScheduleButtonTap()
        func onCoolButtonTap()
        func onHeatButtonTap()
        func onHeatCoolButtonTap()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ThermostatGeneralFeature.ViewState
        @ObservedObject private var orientationObserver = OrientationObserver()

        let delegate: ViewDelegate?

        private var stepperButtonColors: ButtonColors {
            .based(on: viewState.activeSetpointType?.color ?? .Supla.disabled)
        }

        var body: some SwiftUI.View {
            ZStack {
                if (orientationObserver.orientation.isLandscape) {
                    landscapeView
                } else {
                    portraitView
                }
            }
        }

        @ViewBuilder
        private var portraitView: some SwiftUI.View {
            VStack(spacing: 0) {
                ThermometerValuesRow(state: viewState.thermometerValues)
                    .shadow(
                        color: Color(uiColor: ShadowValues.color).opacity(Double(ShadowValues.opacity)),
                        radius: ShadowValues.radius,
                        x: ShadowValues.offset.width,
                        y: ShadowValues.offset.height
                    )
                if (viewState.thermostatAutoMode != nil) {
                    HStack(spacing: Distance.small) {
                        Spacer()
                        heatButton
                        coolButton
                        heatCoolButton
                    }
                    .padding(.top, Distance.small)
                    .padding(.horizontal, Distance.default)
                } else {
                    ChannelStateView(
                        currentState: viewState.channelCurrentStateData,
                        programState: viewState.channelProgramState
                    )
                }
                if let sensorIssue = viewState.sensorIssue {
                    SensorIssueView(issue: sensorIssue)
                        .padding(.horizontal, Distance.default)
                        .padding(.top, Distance.default)
                }

                Spacer(minLength: 0)

                thermostatControl

                Spacer(minLength: 0)

                ChannelIssuesView(issues: viewState.issues, alignment: .center)
                    .padding(.bottom, Distance.tiny)
                controlButtons()
                    .padding(.horizontal, Distance.default)
                    .padding(.bottom, Distance.default)
            }

            if viewState.loadingState.loading {
                SuplaCore.LoadingScrim()
            }
        }

        @ViewBuilder
        private var landscapeView: some SwiftUI.View {
            HStack(alignment: .center, spacing: 0) {
                ThermometerValuesColumn(state: viewState.thermometerValues)
                    .shadow(
                        color: Color(uiColor: ShadowValues.color).opacity(Double(ShadowValues.opacity)),
                        radius: ShadowValues.radius,
                        x: ShadowValues.offset.height,
                        y: ShadowValues.offset.width
                    )
                    .padding(.trailing, Distance.small)

                thermostatControl
                    .frame(maxWidth: .infinity)

                VStack(spacing: 0) {
                    if (viewState.thermostatAutoMode != nil) {
                        HStack(spacing: Distance.small) {
                            Spacer()
                            heatButton
                            coolButton
                            heatCoolButton
                        }
                        .padding(.top, Distance.small)
                        .padding(.horizontal, Distance.default)
                    } else {
                        ChannelStateView(
                            currentState: viewState.channelCurrentStateData,
                            programState: viewState.channelProgramState,
                            padding: .init(top: Distance.small, leading: 0, bottom: 0, trailing: 0)
                        )
                    }
                    if let sensorIssue = viewState.sensorIssue {
                        SensorIssueView(issue: sensorIssue)
                            .padding(.horizontal, Distance.default)
                            .padding(.top, Distance.default)
                    }
                    Spacer(minLength: 0)

                    ChannelIssuesView(issues: viewState.issues, alignment: .center)
                        .padding(.bottom, Distance.tiny)
                    controlButtons(spacing: Distance.tiny)
                }
                .frame(maxWidth: .infinity)
            }

            if viewState.loadingState.loading {
                SuplaCore.LoadingScrim()
            }
        }

        @ViewBuilder
        private var thermostatControl: some SwiftUI.View {
            ThermostatControlRepresentable(
                state: viewState,
                onPositionEvent: { delegate?.onPositionEvent($0) }
            )
            .frame(width: 280, height: 280)
            .overlay(alignment: .bottom) {
                HStack(spacing: Distance.small) {
                    if let icon = viewState.pumpSwitchIcon {
                        icon.image.resizable().scaledToFit()
                            .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                    }
                    if !viewState.plusMinusHidden {
                        minusButton

                        Spacer().frame(width: Distance.small)

                        plusButton
                    }

                    if let icon = viewState.heatOrColdSourceSwitchIcon {
                        icon.image.resizable().scaledToFit()
                            .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                    }
                }
                .offset(y: 10)
            }
        }

        private func controlButtons(spacing: CGFloat = Distance.small) -> some SwiftUI.View {
            HStack(spacing: spacing) {
                SuplaButton(
                    .suplaIcon(name: .Icons.powerButton),
                    colors: SuplaButtonColors.buttonColors.copy(
                        content: Color(viewState.powerIconColor),
                        contentPressed: Color(viewState.powerIconColor)
                    ),
                    fullWidth: false,
                    action: { delegate?.onPowerButtonTap() }
                )
                .frame(width: Dimens.buttonHeight)
                .disabled(!viewState.controlButtonsEnabled)

                HStack(spacing: spacing) {
                    SuplaButton(Strings.ThermostatDetail.modeManual, active: viewState.manualActive, fullWidth: true) {
                        delegate?.onManualButtonTap()
                    }
                    .disabled(!viewState.controlButtonsEnabled)
                    SuplaButton(Strings.ThermostatDetail.modeWeeklySchedule, active: viewState.weeklyScheduleActive, fullWidth: true) {
                        delegate?.onWeeklyScheduleButtonTap()
                    }
                    .disabled(!viewState.controlButtonsEnabled)
                }
            }
            .frame(maxWidth: .infinity)
        }

        private var plusButton: some SwiftUI.View {
            IconButton(name: .Icons.plus) {
                delegate?.onTemperatureChange(.smallUp)
            }
            .borderedButtonStyle(colors: stepperButtonColors, fillColor: Color.Supla.surface, radius: Dimens.iconSize)
            .disabled(!viewState.plusButtonEnabled)
        }

        private var minusButton: some SwiftUI.View {
            IconButton(name: .Icons.minus) {
                delegate?.onTemperatureChange(.smallDown)
            }
            .borderedButtonStyle(colors: stepperButtonColors, fillColor: Color.Supla.surface, radius: Dimens.iconSize)
            .disabled(!viewState.minusButtonEnabled)
        }

        private var coolButton: some SwiftUI.View {
            SuplaButton(
                colors: .secondaryColors,
                active: viewState.thermostatAutoMode == .cool,
                padding: roundedPadding,
                action: { delegate?.onCoolButtonTap() }
            ) {
                Image(.Icons.cool)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            }
        }

        private var heatButton: some SwiftUI.View {
            SuplaButton(
                colors: .errorColors,
                active: viewState.thermostatAutoMode == .heat,
                padding: roundedPadding,
                action: { delegate?.onHeatButtonTap() }
            ) {
                Image(.Icons.heat)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            }
        }

        private var heatCoolButton: some SwiftUI.View {
            let active = viewState.thermostatAutoMode == .heatCool

            return SuplaButton(
                colors: .buttonColors,
                active: active,
                padding: roundedPadding,
                action: { delegate?.onHeatCoolButtonTap() }
            ) {
                HStack(spacing: 2) {
                    Image(.Icons.heat)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .foregroundColor(active ? Color.Supla.error : Color.Supla.onBackground)
                    Image(.Icons.cool)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .foregroundColor(active ? Color.Supla.secondary : Color.Supla.onBackground)
                }
            }
        }
    }

    struct SensorIssueView: SwiftUI.View {
        let issue: SensorIssue

        var body: some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                if let icon = issue.icon {
                    icon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                        .overlay(alignment: .bottomLeading) {
                            if issue.showSensorIcon {
                                if let sensorIcon = UIImage.iconSensorAlertCircle {
                                    Image(uiImage: sensorIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                                        .offset(x: -4, y: 4)
                                }
                            }
                        }
                } else if issue.showSensorIcon {
                    if let sensorIcon = UIImage.iconSensorAlertCircle {
                        Image(uiImage: sensorIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                    }
                }
                Text(issue.message)
                    .fontBodyMedium()
                    .foregroundStyle(Color.Supla.onBackground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private struct ThermostatControlRepresentable: UIViewRepresentable {
        let state: ViewState
        let onPositionEvent: (SetpointEvent) -> Void

        func makeCoordinator() -> Coordinator { Coordinator(onPositionEvent: onPositionEvent) }

        func makeUIView(context: Context) -> ThermostatControlView {
            let view = ThermostatControlView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setpointPositionEvents
                .subscribe(onNext: { [weak coordinator = context.coordinator] in coordinator?.onPositionEvent($0) })
                .disposed(by: context.coordinator.disposeBag)
            return view
        }

        func updateUIView(_ view: ThermostatControlView, context: Context) {
            context.coordinator.onPositionEvent = onPositionEvent
            if view.setpointToDrag == nil { view.setpointToDrag = state.activeSetpointType }
            view.minTemperatureText = state.configMin.toTemperatureString()
            view.maxTemperatureText = state.configMax.toTemperatureString()
            view.minMaxHidden = state.configMinMaxHidden
            view.setpointText = state.setpointText
            view.setpointHeatPercentage = state.setpointHeatPercentage?.cg
            view.setpointCoolPercentage = state.setpointCoolPercentage?.cg
            view.temperaturePercentage = state.currentTemperaturePercentage?.cg
            view.operationalMode = state.operationalMode
            view.currentPower = state.currentPower
            view.greyOutSetpoins = state.grayOutSetpoints
        }

        final class Coordinator {
            let disposeBag = DisposeBag()
            var onPositionEvent: (SetpointEvent) -> Void
            init(onPositionEvent: @escaping (SetpointEvent) -> Void) { self.onPositionEvent = onPositionEvent }
        }
    }
}

enum ThermostatAutoMode {
    case heat, cool, heatCool
}

#Preview("Thermostat general in manual mode") {
    let viewState = ThermostatGeneralFeature.ViewState()
    viewState.offline = false
    viewState.mode = .heat
    viewState.setpointHeat = 21
    viewState.configMin = 5
    viewState.configMax = 30
    viewState.controlButtonsEnabled = true
    viewState.manualActive = true
    viewState.sensorIssue = SensorIssue(
        icon: .suplaIcon(name: .Icons.fncThermometerHome),
        message: Strings.ThermostatDetail.offBySensor
    )
    viewState.pumpSwitchIcon = .suplaIcon(name: "fnc_pump_switch-on")
    viewState.heatOrColdSourceSwitchIcon = .suplaIcon(name: "fnc_heat_or_cold_source_switch-on")
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.floodSensorActive)
        ),
        SharedCore.ChannelIssueItem.Warning(
            string: localizedString(id: LocalizedStringId.channelBatteryLevel, arg1: 10)
        )
    ]
    viewState.loadingState = viewState.loadingState.copy(loading: false)
    viewState.channelCurrentStateData = ChannelCurrentState.Data(
        label: "STATE UNTIL 18:30",
        icon: .suplaIcon(name: .Icons.heat),
        value: "21°",
        iconColor: .Supla.error
    )
    viewState.channelProgramState = [ ChannelProgramState.Data(label: "Test") ]
    viewState.thermometerValues.measurements = [
        MeasurementValue(
            id: 1,
            icon: .suplaIcon(name: .Icons.fncThermometerHome),
            value: "20.5°",
            batteryIcon: nil
        )
    ]

    return ThermostatGeneralFeature.View(viewState: viewState, delegate: nil)
}

#Preview("Thermostat general in program mode") {
    let viewState = ThermostatGeneralFeature.ViewState()
    viewState.offline = false
    viewState.mode = .heat
    viewState.setpointHeat = 21
    viewState.configMin = 5
    viewState.configMax = 30
    viewState.controlButtonsEnabled = true
    viewState.manualActive = true
    viewState.sensorIssue = SensorIssue(
        icon: .suplaIcon(name: .Icons.fncThermometerHome),
        message: Strings.ThermostatDetail.offBySensor
    )
    viewState.pumpSwitchIcon = .suplaIcon(name: "fnc_pump_switch-on")
    viewState.heatOrColdSourceSwitchIcon = .suplaIcon(name: "fnc_heat_or_cold_source_switch-on")
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.floodSensorActive)
        ),
        SharedCore.ChannelIssueItem.Warning(
            string: localizedString(id: LocalizedStringId.channelBatteryLevel, arg1: 10)
        )
    ]
    viewState.loadingState = viewState.loadingState.copy(loading: false)
    viewState.channelProgramState = [ ChannelProgramState.Data(label: "CURRENTLY:", description: "21.00 - 25.00", time: "for 45 minutes") ]
    viewState.thermometerValues.measurements = [
        MeasurementValue(
            id: 1,
            icon: .suplaIcon(name: .Icons.fncThermometerHome),
            value: "20.5°",
            batteryIcon: nil
        )
    ]

    return ThermostatGeneralFeature.View(viewState: viewState, delegate: nil)
}

#Preview("Thermostat heat and cool") {
    let viewState = ThermostatGeneralFeature.ViewState()
    viewState.offline = false
    viewState.mode = .heat
    viewState.setpointHeat = 21
    viewState.configMin = 5
    viewState.configMax = 30
    viewState.controlButtonsEnabled = true
    viewState.manualActive = true
    viewState.sensorIssue = SensorIssue(
        icon: .suplaIcon(name: .Icons.fncThermometerHome),
        message: Strings.ThermostatDetail.offBySensor
    )
    viewState.pumpSwitchIcon = .suplaIcon(name: "fnc_pump_switch-on")
    viewState.heatOrColdSourceSwitchIcon = .suplaIcon(name: "fnc_heat_or_cold_source_switch-on")
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.floodSensorActive)
        ),
        SharedCore.ChannelIssueItem.Warning(
            string: localizedString(id: LocalizedStringId.channelBatteryLevel, arg1: 10)
        )
    ]
    viewState.loadingState = viewState.loadingState.copy(loading: false)
    viewState.thermometerValues.measurements = [
        MeasurementValue(
            id: 1,
            icon: .suplaIcon(name: .Icons.fncThermometerHome),
            value: "20.5°",
            batteryIcon: nil
        )
    ]
    viewState.thermostatAutoMode = .heatCool

    return ThermostatGeneralFeature.View(viewState: viewState, delegate: nil)
}
