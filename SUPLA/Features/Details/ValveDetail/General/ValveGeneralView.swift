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
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
        
        let onInfoClick: (SensorItemData) -> Void
        let onCaptionLongPress: (SensorItemData) -> Void
        
        let onOpenClick: () -> Void
        let onCloseClick: () -> Void
        
        let onWarningDialogDismiss: () -> Void
        let onForceAction: (Action) -> Void
        
        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Distance.small) {
                            DeviceState(state: viewState.stateString, icon: viewState.icon, offline: viewState.offline)
                            ChannelIssuesView(issues: viewState.issues)
                            SensorItemsView(
                                sensors: viewState.sensors,
                                onInfoClick: onInfoClick,
                                onCaptionLongPress: onCaptionLongPress
                            )
                        }
                    }
                    
                    SwitchButtons(
                        isOn: !viewState.isClosed,
                        enabled: !viewState.offline,
                        positiveText: Strings.General.open,
                        negativeText: Strings.General.close,
                        positiveIcon: .suplaIcon(name: "valve-open"),
                        negativeIcon: .suplaIcon(name: "valve-closed"),
                        onPositiveClick: onOpenClick,
                        onNegativeClick: onCloseClick
                    )
                }
                
                if (stateDialogViewModel.present) {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }
                
                if (captionChangeDialogViewModel.present) {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
                
                if let alertDialog = viewState.alertDialog {
                    SuplaCore.AlertDialog(
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
                    if (offline) {
                        icon.image
                            .renderingMode(.template)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.Supla.outline)
                    } else {
                        icon.image.frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(minHeight: 120)
            .padding([.leading, .trailing], Distance.default)
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
        SensorItemData(
            channelId: 1,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_flood_sensor-on"),
            caption: "Flood sensor",
            userCaption: "",
            batteryIcon: IssueIcon.Battery25(),
            showChannelStateIcon: true
        ),
        SensorItemData(
            channelId: 2,
            onlineState: .offline,
            icon: .suplaIcon(name: "fnc_flood_sensor-off"),
            caption: "Flood sensor",
            userCaption: "",
            batteryIcon: IssueIcon.Battery50(),
            showChannelStateIcon: false
        ),
        SensorItemData(
            channelId: 4,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_flood_sensor-off"),
            caption: "Flood sensor",
            userCaption: "",
            batteryIcon: IssueIcon.Battery50(),
            showChannelStateIcon: true
        )
    ]
    let stateDialogViewModel = StateDialogFeature.ViewModel(title: "", function: "")
    let captionChangeDialogViewModel = CaptionChangeDialogFeature.ViewModel()
    
    return ValveGeneralFeature.View(
        viewState: state,
        stateDialogViewModel: stateDialogViewModel,
        captionChangeDialogViewModel: captionChangeDialogViewModel,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in },
        onOpenClick: {},
        onCloseClick: {},
        onWarningDialogDismiss: {},
        onForceAction: { _ in }
    )
}
