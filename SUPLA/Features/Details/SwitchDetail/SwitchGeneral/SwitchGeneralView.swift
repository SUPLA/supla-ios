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

extension SwitchGeneralFeature {
    protocol ViewDelegate: OperationButtonsDelegate {
        func onTurnOff()
        func onTurnOn()
        func onIntroductionClose()
        func onForceTurnOn()
        func onAlertClose()
        func onForce()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var emState: ElectricityMeterGeneralState
        @ObservedObject var icState: ImpulseCounterGeneralState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel

        var delegate: ViewDelegate?

        let onInfoClick: (RelatedChannelData) -> Void
        let onCaptionLongPress: (RelatedChannelData) -> Void

        private var channelStateView: ChannelStateView {
            ChannelStateView(
                currentState: viewState.channelCurrentStateData,
                programState: viewState.channelProgramState
            )
        }

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    if (viewState.showElectricityState) {
                        channelStateView
                        ChannelIssuesView(issues: viewState.issues)
                        ElectricityMeterGeneralBaseView(
                            online: $emState.online,
                            totalForwardActiveEnergy: $emState.totalForwardActiveEnergy,
                            totalReverseActiveEnergy: $emState.totalReverseActiveEnergy,
                            currentMonthDownloading: $emState.currentMonthDownloading,
                            currentMonthForwardActiveEnergy: $emState.currentMonthForwardActiveEnergy,
                            currentMonthReverseActiveEnergy: $emState.currentMonthReverseActiveEnergy,
                            phaseMeasurementTypes: $emState.phaseMeasurementTypes,
                            phaseMeasurementValues: $emState.phaseMeasurementValues,
                            vectorBalancedValues: $emState.vectorBalancedValues,
                            electricGridParameters: $emState.electricGridParameters,
                            showIntroduction: $emState.showIntroduction,
                            topPadding: viewState.channelProgramState.isEmpty ? Distance.default : 0,
                            onIntroductionClose: { delegate?.onIntroductionClose() }
                        )
                    } else if (viewState.showImpulseCounterState) {
                        channelStateView
                        ChannelIssuesView(issues: viewState.issues)
                        ImpulseCounterGeneralBaseView(
                            online: icState.online,
                            totalData: icState.totalData,
                            currentMonthData: icState.currentMonthData,
                            topPadding: viewState.channelProgramState.isEmpty ? Distance.default : 0,
                            currentMonthDownloading: $icState.currentMonthDownloading
                        )
                    } else if let channels = viewState.relatedChannelsData {
                        Text(Strings.General.group.uppercased())
                            .fontBodyMedium()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing, .top], Distance.default)

                        RelatedChannelsView(
                            channels: channels,
                            onInfoClick: onInfoClick,
                            onCaptionLongPress: onCaptionLongPress
                        )

                        Spacer()
                    } else {
                        channelStateView
                        ChannelIssuesView(issues: viewState.issues)
                        Spacer()
                    }

                    if (viewState.manualAllowed || viewState.weeklyAllowed || viewState.autoAllowed) {
                        OperationButtons(
                            manualAllowed: viewState.manualAllowed,
                            manualActive: viewState.manualActive,
                            weeklyAllowed: viewState.weeklyAllowed,
                            weeklyActive: viewState.weeklyActive,
                            autoAllowed: viewState.autoAllowed,
                            autoActive: viewState.autoActive,
                            delegate: delegate
                        )
                        .padding(.top, Distance.default)
                    }

                    HStack(spacing: Distance.tiny) {
                        if let leftButton = viewState.offButtonState {
                            SwitchButton(
                                state: leftButton,
                                onClick: { delegate?.onTurnOff() }
                            )
                            .disabled(!viewState.online || viewState.forceActive)
                        }

                        if (viewState.forceSupported) {
                            LockSuplaButton(
                                pressed: viewState.forceActive,
                                type: viewState.lockIconType,
                                onClick: { delegate?.onForce() }
                            )
                            .disabled(viewState.forceButtonDisabled)
                        }

                        if let rightButton = viewState.onButtonState {
                            SwitchButton(
                                state: rightButton,
                                onClick: { delegate?.onTurnOn() }
                            )
                            .disabled(!viewState.online || viewState.forceActive)
                        }
                    }
                    .padding(Distance.default)
                }

                if let alertDialogState = viewState.alertDialogState {
                    SuplaCore.AlertDialog(
                        state: alertDialogState,
                        onDismiss: { delegate?.onAlertClose() },
                        onPrimaryButtonClick: { delegate?.onForceTurnOn() },
                        onSecondaryButtonClick: { delegate?.onAlertClose() }
                    )
                }

                if (stateDialogViewModel.present) {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }

                if (captionChangeDialogViewModel.present) {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
            }
        }
    }
}

#Preview {
    let viewState = SwitchGeneralFeature.ViewState()
    viewState.channelCurrentStateData = .init(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: .Icons.fncThermostatHeat),
        value: Strings.SwitchDetail.stateOff
    )
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "fnc_switch-off"),
        label: Strings.General.turnOff,
        active: true,
        colors: .errorColors
    )
    viewState.onButtonState = .init(
        icon: .suplaIcon(name: "fnc_switch-on"),
        label: Strings.General.turnOn,
        active: false,
        colors: .primaryColors
    )
    viewState.manualAllowed = true
    viewState.manualActive = true
    viewState.weeklyAllowed = true
    viewState.autoAllowed = true
    viewState.forceSupported = true
    viewState.channelProgramState = [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.Schedule.programForceOn,
            time: Strings.ThermostatDetail.programTime.arguments(
                Strings.General.time_just_minutes.arguments(12)
            )
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.General.turnOff
        ),
    ]
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.overcurrentWarning)
        ),
    ]

    return SwitchGeneralFeature.View(
        viewState: viewState,
        emState: ElectricityMeterGeneralState(),
        icState: ImpulseCounterGeneralState(),
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "", function: ""),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}

#Preview("Switch with energy counter") {
    let viewState = SwitchGeneralFeature.ViewState()
    viewState.online = true
    viewState.showElectricityState = true
    viewState.channelCurrentStateData = .init(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: "fnc_switch-on"),
        value: Strings.SwitchDetail.stateOn
    )
    viewState.channelProgramState = [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.Schedule.programForceOn,
            time: Strings.ThermostatDetail.programTime.arguments(
                Strings.General.time_just_minutes.arguments(12)
            )
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.General.turnOff
        )
    ]
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "fnc_switch-off"),
        label: Strings.General.turnOff,
        active: false,
        colors: .errorColors
    )
    viewState.onButtonState = .init(
        icon: .suplaIcon(name: "fnc_switch-on"),
        label: Strings.General.turnOn,
        active: true,
        colors: .primaryColors
    )
    viewState.manualAllowed = true
    viewState.manualActive = false
    viewState.weeklyAllowed = true
    viewState.weeklyActive = true
    viewState.autoAllowed = true
    viewState.autoActive = false
    viewState.forceSupported = true
    viewState.forceActive = false
    viewState.forceButtonDisabled = false
    viewState.lockIconType = .temporaryClosed

    let emState = ElectricityMeterGeneralState()
    emState.online = true
    emState.totalForwardActiveEnergy = SummaryCardData(energy: "4273 kWh", price: "3418.33 PLN")
    emState.totalReverseActiveEnergy = SummaryCardData(energy: "5715 kWh")
    emState.currentMonthForwardActiveEnergy = SummaryCardData(energy: "182 kWh", price: "145.60 PLN")
    emState.currentMonthReverseActiveEnergy = SummaryCardData(energy: "24 kWh")
    emState.phaseMeasurementTypes = [.frequency, .voltage, .current, .powerApparent, .reverseReactiveEnergy]
    emState.phaseMeasurementValues = [
        .init(id: 1, phase: Strings.ElectricityMeter.phase1, values: [
            .init(type: .frequency, value: "50.00"),
            .init(type: .voltage, value: "230.12"),
            .init(type: .current, value: "5.32"),
            .init(type: .powerApparent, value: "1224.24"),
            .init(type: .reverseReactiveEnergy, value: "2066.96")
        ]),
        .init(id: 2, phase: Strings.ElectricityMeter.phase2, values: [
            .init(type: .frequency, value: "50.01"),
            .init(type: .voltage, value: "229.87"),
            .init(type: .current, value: "4.81"),
            .init(type: .powerApparent, value: "1105.67"),
            .init(type: .reverseReactiveEnergy, value: "1842.30")
        ]),
        .init(id: 3, phase: Strings.ElectricityMeter.phase3, values: [
            .init(type: .frequency, value: "49.99"),
            .init(type: .voltage, value: "231.04"),
            .init(type: .current, value: "6.14"),
            .init(type: .powerApparent, value: "1418.59"),
            .init(type: .reverseReactiveEnergy, value: "2210.48")
        ])
    ]

    return SwitchGeneralFeature.View(
        viewState: viewState,
        emState: emState,
        icState: ImpulseCounterGeneralState(),
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "", function: ""),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}

#Preview("Switch with impulse counter") {
    let viewState = SwitchGeneralFeature.ViewState()
    viewState.online = true
    viewState.showImpulseCounterState = true
    viewState.channelProgramState = [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.Schedule.programForceOn,
            time: Strings.ThermostatDetail.programTime.arguments(
                Strings.General.time_just_minutes.arguments(12)
            )
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.General.turnOff
        )
    ]
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "fnc_switch-off"),
        label: Strings.General.turnOff,
        active: false,
        colors: .errorColors
    )
    viewState.onButtonState = .init(
        icon: .suplaIcon(name: "fnc_switch-on"),
        label: Strings.General.turnOn,
        active: true,
        colors: .primaryColors
    )
    viewState.manualAllowed = true
    viewState.weeklyAllowed = true
    viewState.weeklyActive = true
    viewState.autoAllowed = true
    viewState.forceSupported = true

    let icState = ImpulseCounterGeneralState()
    icState.online = true
    icState.totalData = SummaryCardData(energy: "1284.56 m³", price: "642.28 PLN")
    icState.currentMonthData = SummaryCardData(energy: "18.42 m³", price: "9.21 PLN")

    return SwitchGeneralFeature.View(
        viewState: viewState,
        emState: ElectricityMeterGeneralState(),
        icState: icState,
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "", function: ""),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}
