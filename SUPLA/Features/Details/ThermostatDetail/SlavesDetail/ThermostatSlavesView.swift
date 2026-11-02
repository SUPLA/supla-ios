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

import SharedCore
import SwiftUI

extension ThermostatSlavesFeature {
    protocol ViewDelegate: AnyObject {
        func onInfoAction(_ issueMessage: String)
        func onAlertDismissed()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel

        let delegate: ViewDelegate?
        let onStatusAction: (Int32) -> Void

        let onCaptionLongPress: (ThermostatData) -> Void
        let onSlaveClick: (ThermostatData) -> Void

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    if let master = viewState.master {
                        HeaderText(title: Strings.ThermostatDetail.mainThermostat)
                            .padding([.bottom], Distance.tiny)
                        ThermostatRow(
                            data: master,
                            onInfoAction: { delegate?.onInfoAction($0) },
                            onStatusAction: onStatusAction,
                            onCaptionLongPress: onCaptionLongPress,
                            onSlaveClick: { _ in }
                        )
                    }
                    HeaderText(title: Strings.ThermostatDetail.otherThermostats)
                        .padding([.top], Distance.default)
                        .padding([.bottom], Distance.tiny)
                    LazyList(items: viewState.slaves) {
                        ThermostatRow(
                            data: $0,
                            onInfoAction: { delegate?.onInfoAction($0) },
                            onStatusAction: onStatusAction,
                            onCaptionLongPress: onCaptionLongPress,
                            onSlaveClick: onSlaveClick
                        )
                    }
                }.padding([.top], Dimens.distanceDefault)

                if stateDialogViewModel.present {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }

                if captionChangeDialogViewModel.present {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }

                if let alertDialogState = viewState.alertDialogState {
                    SuplaCore.AlertDialog(
                        state: alertDialogState,
                        onDismiss: { delegate?.onAlertDismissed() },
                        onPrimaryButtonClick: { delegate?.onAlertDismissed() }
                    )
                }
            }.environment(\.scaleFactor, viewState.scale)
        }
    }

    struct HeaderText: SwiftUI.View {
        let title: String
        var body: some SwiftUI.View {
            HStack {
                Text(title.uppercased()).fontBodyMedium()
                Spacer()
            }.padding([.leading, .trailing], Dimens.distanceSmall)
        }
    }

    struct ThermostatRow: SwiftUI.View {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat

        let data: ThermostatData

        let onInfoAction: (String) -> Void
        let onStatusAction: (Int32) -> Void
        let onCaptionLongPress: (ThermostatData) -> Void
        let onSlaveClick: (ThermostatData) -> Void

        var body: some SwiftUI.View {
            ZStack {
                HStack {
                    VStack(alignment: .center) {
                        ListItemIcon(iconResult: data.icon)
                        Text(data.currentPower ?? "").fontBodySmall()
                    }.padding([.leading], Dimens.distanceSmall)
                    VStack(alignment: .leading, spacing: scaleFactor.scale(Dimens.distanceSmall)) {
                        HStack {
                            ListItemValue(value: data.value)
                            if (data.indicatorIcon == .off) {
                                Text("Off").fontBodyMedium()
                            } else {
                                SetpointIndicator(data.indicatorIcon)
                                if let subValue = data.subValue {
                                    SetpointText(subValue)
                                }
                            }
                            ChildChannelIcon(icon: data.pumpSwitchIcon)
                            ChildChannelIcon(icon: data.sourceSwitchIcon)
                        }
                        ListItemTitle(
                            text: data.caption,
                            onLongClick: { onCaptionLongPress(data) }
                        )
                        .padding([.trailing], Dimens.distanceSmall)
                    }
                    Spacer()
                }
                HStack(spacing: Dimens.distanceSmall) {
                    Spacer()
                    if let issueIcon = data.issues.icons.first {
                        ListItemIssueIcon(icon: issueIcon)
                            .onTapGesture {
                                if (data.issues.hasMessage()) {
                                    onInfoAction(data.issues.message)
                                }
                            }
                    }

                    if (data.showChannelStateIcon) {
                        ListItemInfoIcon()
                            .onTapGesture { onStatusAction(data.id) }
                    }
                    ListItemDot(onlineState: data.onlineState)
                }
                .padding([.trailing], Dimens.distanceSmall)
            }
            .padding([.top, .bottom], Dimens.distanceTiny)
            .background(Color.Supla.surface)
            .onTapGesture { onSlaveClick(data) }
        }
    }

    struct ChildChannelIcon: SwiftUI.View {
        let icon: IconResult?

        var body: some SwiftUI.View {
            if let icon = icon {
                icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            }
        }
    }
}

#Preview {
    let viewState = ThermostatSlavesFeature.ViewState()
    viewState.master = ThermostatSlavesFeature.ThermostatData(
        id: 1,
        profileId: 1,
        deviceId: 1,
        function: 0,
        onlineState: .online,
        caption: "FHC #0",
        userCaption: "FHC #0",
        icon: .suplaIcon(name: "fnc_thermostat_heat"),
        currentPower: nil,
        value: "22,7°C",
        indicatorIcon: .heating,
        issues: ListItemIssues(icons: [IssueIcon.Warning()], issuesStrings: []),
        showChannelStateIcon: true,
        subValue: "23,0°",
        pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-on"),
        sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-on")
    )
    viewState.slaves = [
        ThermostatSlavesFeature.ThermostatData(
            id: 1,
            profileId: 1,
            deviceId: 1,
            function: 0,
            onlineState: .online,
            caption: "FHC #1",
            userCaption: "FHC #1",
            icon: .suplaIcon(name: "fnc_thermostat_heat"),
            currentPower: "25%",
            value: "22,7°C",
            indicatorIcon: .standby,
            issues: ListItemIssues(icons: [], issuesStrings: []),
            showChannelStateIcon: true,
            subValue: "23,0°",
            pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-off"),
            sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-on")
        ),
        ThermostatSlavesFeature.ThermostatData(
            id: 2,
            profileId: 1,
            deviceId: 1,
            function: 0,
            onlineState: .online,
            caption: "FHC #2",
            userCaption: "FHC #2",
            icon: .suplaIcon(name: "fnc_thermostat_heat"),
            currentPower: "100%",
            value: "22,4°C",
            indicatorIcon: .standby,
            issues: ListItemIssues(icons: [], issuesStrings: []),
            showChannelStateIcon: true,
            subValue: "23,0°",
            pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-on"),
            sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-off")
        )
    ]
    let stateDialogViewModel = StateDialogFeature.ViewModel(title: "", function: "")
    let captionChangeDialogViewModel = CaptionChangeDialogFeature.ViewModel()

    return ThermostatSlavesFeature.View(
        viewState: viewState,
        stateDialogViewModel: stateDialogViewModel,
        captionChangeDialogViewModel: captionChangeDialogViewModel,
        delegate: nil,
        onStatusAction: { _ in },
        onCaptionLongPress: { _ in },
        onSlaveClick: { _ in }
    )
}
