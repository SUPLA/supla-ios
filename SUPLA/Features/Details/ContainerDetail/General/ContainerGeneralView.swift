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

extension ContainerGeneralFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel

        let onMuteClick: () -> Void
        let onInfoClick: (RelatedChannelData) -> Void
        let onCaptionLongPress: (RelatedChannelData) -> Void

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: Distance.small) {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ContainerLevelView(
                                    fluidLevelString: viewState.fluidLevelString,
                                    soundOn: viewState.soundOn,
                                    onMuteClick: onMuteClick
                                )
                                .frame(width: geometry.size.width * 0.5)
                                ContainerIconView(
                                    level: viewState.fluidLevel,
                                    containerType: viewState.containerType,
                                    controlLevels: viewState.controlLevels
                                )
                                .frame(width: geometry.size.width * 0.5)
                            }
                        }
                        .frame(height: 260)
                        .padding(Distance.default)

                        ChannelIssuesView(issues: viewState.issues)
                        SensorItemsView(
                            sensors: viewState.sensors,
                            onInfoClick: onInfoClick,
                            onCaptionLongPress: onCaptionLongPress
                        )
                    }
                }

                if stateDialogViewModel.present {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }

                if captionChangeDialogViewModel.present {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
            }
        }
    }

    private struct ContainerLevelView: SwiftUI.View {
        let fluidLevelString: String
        let soundOn: Bool
        let onMuteClick: () -> Void

        var body: some SwiftUI.View {
            ZStack {
                VStack {
                    Text(Strings.Container.fillLevel)
                        .fontTitleSmall()
                        .textColor(Color.Supla.onSurfaceVariant)
                    Text(fluidLevelString)
                        .fontDisplaySmall()
                }
                if (soundOn) {
                    VStack {
                        Spacer()
                        RoundedControlButtonWrapperView(
                            type: .neutral,
                            icon: .suplaIcon(name: .Icons.soundOff),
                            iconColor: .primary,
                            onTap: onMuteClick
                        ).frame(width: Dimens.buttonHeight, height: Dimens.buttonHeight)
                    }
                }
            }
        }
    }
}

#Preview {
    let state = ContainerGeneralFeature.ViewState()
    state.fluidLevel = 0.6
    state.fluidLevelString = "60%"
    state.containerType = .water
    state.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.containerAlarmLevel)
        ),
        SharedCore.ChannelIssueItem.Warning(
            string: localizedString(id: LocalizedStringId.containerWarningLevel)
        )
    ]
    state.sensors = [
        RelatedChannelData(
            channelId: 1,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_container_level_sensor-on"),
            caption: "Container level sensor",
            userCaption: "",
            batteryIcon: IssueIcon.Battery25(),
            showChannelStateIcon: true
        )
    ]
    state.soundOn = true
    let stateDialogViewModel = StateDialogFeature.ViewModel(title: "", function: "")
    let captionChangeDialogViewModel = CaptionChangeDialogFeature.ViewModel()

    return ContainerGeneralFeature.View(
        viewState: state,
        stateDialogViewModel: stateDialogViewModel,
        captionChangeDialogViewModel: captionChangeDialogViewModel,
        onMuteClick: {},
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}
