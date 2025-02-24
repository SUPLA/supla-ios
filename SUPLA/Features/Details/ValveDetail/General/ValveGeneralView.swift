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

extension ValveGeneralFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        
        let onInfoClick: (SensorData) -> Void
        let onCaptionLongPress: (SensorData) -> Void
        
        let onOpenClick: () -> Void
        let onCloseClick: () -> Void
        
        let onStateDialogDismiss: () -> Void
        let onWarningDialogDismiss: () -> Void
        let onForceAction: (Action) -> Void
        
        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Distance.small) {
                            DeviceState(state: viewState.stateString, icon: viewState.icon, offline: viewState.offline)
                            Issues(issues: viewState.issues)
                            Sensors(
                                sensors: viewState.sensors,
                                onInfoClick: onInfoClick,
                                onCaptionLongPress: onCaptionLongPress
                            )
                        }
                    }
                    HStack(spacing: Distance.default) {
                        RoundedControlButtonWrapperView(
                            type: .negative,
                            text: Strings.General.close,
                            icon: .suplaIcon(name: "valve-closed"),
                            active: viewState.isClosed,
                            isEnabled: !viewState.offline,
                            onTap: onCloseClick
                        )
                        .frame(height: Dimens.buttonHeight)
                        RoundedControlButtonWrapperView(
                            type: .positive,
                            text: Strings.General.open,
                            icon: .suplaIcon(name: "valve-open"),
                            active: !viewState.isClosed,
                            isEnabled: !viewState.offline,
                            onTap: onOpenClick
                        )
                        .frame(height: Dimens.buttonHeight)
                    }
                    .padding(Distance.default)
                }
                
                if let stateDialogState = viewState.stateDialogState {
                    StateDialogFeature.Dialog(state: stateDialogState, onDismiss: onStateDialogDismiss)
                }
                
                if let alertDialog = viewState.alertDialog {
                    SuplaCore.Dialog.Alert(
                        header: Strings.General.warning,
                        message: alertDialog.message,
                        onDismiss: onWarningDialogDismiss,
                        positiveButtonText: alertDialog.positiveButtonText,
                        negativeButtonText: alertDialog.negativeButtonText,
                        onPositiveButtonClick: { if let action = alertDialog.action { onForceAction(action) } },
                        onNegativeButtonClick: onWarningDialogDismiss
                    )
                }
            }
        }
    }
    
    private struct DeviceState: SwiftUI.View {
        let state: String?
        let icon: IconResult?
        let offline: Bool
        
        var body: some SwiftUI.View {
            HStack {
                VStack {
                    Text(Strings.SwitchDetail.stateLabel.uppercased())
                        .fontBodyMedium()
                        .textColor(Color.Supla.onSurfaceVariant)
                    if let state {
                        Text(state)
                            .font(.Supla.bodyMedium.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                
                if let icon {
                    icon.image
                        .renderingMode(.template)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(offline ? Color.Supla.outline : Color.Supla.onBackground)
                }
            }
            .frame(minHeight: 120)
            .padding([.leading, .trailing], Distance.default)
        }
    }
    
    private struct Issues: SwiftUI.View {
        var issues: [ChannelIssueItem]
        
        var body: some SwiftUI.View {
            ForEach(0 ..< issues.count, id: \.self) { issueIdx in
                ForEach(0 ..< issues[issueIdx].messages.count, id: \.self) { messageIdx in
                    HStack(alignment: .top, spacing: Distance.tiny) {
                        if let icon = issues[issueIdx].icon.resource {
                            Image(uiImage: icon)
                                .resizable()
                                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        }
                        Text(issues[issueIdx].messages[messageIdx].string)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding([.leading, .trailing], Distance.default)
                }
            }
        }
    }
    
    private struct Sensors: SwiftUI.View {
        let sensors: [SensorData]
        let onInfoClick: (SensorData) -> Void
        let onCaptionLongPress: (SensorData) -> Void
        
        var body: some SwiftUI.View {
            if (!sensors.isEmpty) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(Strings.Valve.detailSensors.uppercased())
                        .fontBodyMedium()
                        .padding([.leading, .trailing], Distance.default)
                        .padding(.bottom, Distance.tiny)
                    ForEach(sensors) { sensor in
                        HStack(spacing: 0) {
                            ListItemIcon(iconResult: sensor.icon)
                            CellCaption(text: sensor.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Distance.tiny)
                                .padding(.trailing, Distance.small)
                                .onLongPressGesture { onCaptionLongPress(sensor) }
                            ListItemIssueIcon(icon: sensor.batteryIcon)
                                .padding(.trailing, Distance.small)
                            if (sensor.showChannelStateIcon) {
                                ListItemInfoIcon()
                                    .padding(.trailing, Distance.small)
                                    .onTapGesture { onInfoClick(sensor) }
                            }
                            ListItemDot(onlineState: sensor.onlineState)
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.leading], Distance.small)
                        .padding([.trailing], Distance.default)
                        .padding([.top, .bottom], Distance.tiny)
                        .background(Color.Supla.surface)
                    }
                }
            }
        }
    }
}

#Preview {
    let state = ValveGeneralFeature.ViewState()
    state.stateString = "opened"
    state.icon = .suplaIcon(name: "valve-open")
    state.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: LocalizedStringWithId(id: LocalizedStringId.floodSensorActive)
        ),
        SharedCore.ChannelIssueItem.Error(
            string: LocalizedStringWithId(id: LocalizedStringId.valveFlooding)
        ),
        SharedCore.ChannelIssueItem.Error(
            string: LocalizedStringWithId(id: LocalizedStringId.valveManuallyClosed)
        ),
        SharedCore.ChannelIssueItem.LowBattery(messages: [
            LocalizedStringWithId(id: LocalizedStringId.channelBatteryLevel),
            LocalizedStringWithId(id: LocalizedStringId.channelBatteryLevel)
        ])
    ]
    state.sensors = [
        ValveGeneralFeature.SensorData(
            channelId: 1,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_flood_sensor-on"),
            caption: "Flood sensor",
            batteryIcon: IssueIcon.Battery25(),
            showChannelStateIcon: true
        ),
        ValveGeneralFeature.SensorData(
            channelId: 2,
            onlineState: .offline,
            icon: .suplaIcon(name: "fnc_flood_sensor-off"),
            caption: "Flood sensor",
            batteryIcon: IssueIcon.Battery50(),
            showChannelStateIcon: false
        ),
        ValveGeneralFeature.SensorData(
            channelId: 4,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_flood_sensor-off"),
            caption: "Flood sensor",
            batteryIcon: IssueIcon.Battery50(),
            showChannelStateIcon: true
        )
    ]
    
    return ValveGeneralFeature.View(
        viewState: state,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in },
        onOpenClick: {},
        onCloseClick: {},
        onStateDialogDismiss: {},
        onWarningDialogDismiss: {},
        onForceAction: { _ in }
    )
}
