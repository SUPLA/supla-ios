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
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var emState: ElectricityMeterGeneralState
        @ObservedObject var icState: ImpulseCounterGeneralState
        
        let onTurnOff: () -> Void
        let onTurnOn: () -> Void
        let onIntroductionClose: () -> Void
        let onForceTurnOn: () -> Void
        let onAlertClose: () -> Void

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack {
                    if (viewState.showElectricityState) {
                        if (!viewState.issues.isEmpty) {
                            Spacer().frame(height: Distance.default)
                        }
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
                            onIntroductionClose: onIntroductionClose
                        )
                    } else if (viewState.showImpulseCounterState) {
                        if (!viewState.issues.isEmpty) {
                            Spacer().frame(height: Distance.default)
                        }
                        ChannelIssuesView(issues: viewState.issues)
                        ImpulseCounterGeneralBaseView(
                            online: icState.online,
                            totalData: icState.totalData,
                            currentMonthData: icState.currentMonthData,
                            currentMonthDownloading: $icState.currentMonthDownloading
                        )
                    } else {
                        DeviceStateView(
                            stateLabel: viewState.stateLabel,
                            icon: viewState.stateIcon,
                            stateValue: viewState.stateValue
                        )
                        ChannelIssuesView(issues: viewState.issues)
                        Spacer()
                    }
                    
                    if let leftButton = viewState.offButtonState,
                       let rightButton = viewState.onButtonState
                    {
                        SwitchButtons(
                            leftButton: leftButton,
                            rightButton: rightButton,
                            enabled: viewState.online,
                            onLeftButtonClick: onTurnOff,
                            onRightButtonClick: onTurnOn
                        )
                    }
                }
                
                if let alertDialogState = viewState.alertDialogState {
                    SuplaCore.AlertDialog(
                        state: alertDialogState,
                        onDismiss: onAlertClose,
                        onPositiveButtonClick: onForceTurnOn,
                        onNegativeButtonClick: onAlertClose
                    )
                }
            }
        }
    }
}

#Preview {
    let viewState = SwitchGeneralFeature.ViewState()
    viewState.stateIcon = .suplaIcon(name: .Icons.fncThermostatHeat)
    viewState.stateLabel = Strings.SwitchDetail.stateLabel
    viewState.stateValue = Strings.SwitchDetail.stateOff
    viewState.offButtonState = .init(
        icon: .suplaIcon(name: "fnc-power_off"),
        label: Strings.General.turnOff,
        active: true,
        type: .negative
    )
    viewState.onButtonState = .init(
        icon: .suplaIcon(name: "fnc-power_on"),
        label: Strings.General.turnOn,
        active: false,
        type: .positive
    )
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.overcurrentWarning)
        ),
    ]

    return SwitchGeneralFeature.View(
        viewState: viewState,
        emState: ElectricityMeterGeneralState(),
        icState: ImpulseCounterGeneralState(),
        onTurnOff: {},
        onTurnOn: {},
        onIntroductionClose: {},
        onForceTurnOn: {},
        onAlertClose: {}
    )
}
