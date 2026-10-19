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
import SharedCore

extension GateGeneralFeature {
    protocol ViewDelegate: OperationButtonsDelegate {
        func onOpen()
        func onClose()
        func onOpenClose()
        func onForce()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
        var delegate: ViewDelegate?
        
        let onInfoClick: (RelatedChannelData) -> Void
        let onCaptionLongPress: (RelatedChannelData) -> Void
        
        @StateObject private var orientationObserver = OrientationObserver()

        private var channelStateView: ChannelStateView {
            ChannelStateView(
                currentState: viewState.channelCurrentStateData,
                programState: viewState.channelProgramState
            )
        }
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack {
                    if viewState.channelCurrentStateData != nil {
                        channelStateView
                    }
                    
                    ChannelIssuesView(issues: viewState.issues)
                    Spacer()
                    
                    if let channels = viewState.relatedChannelsData {
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
                    }
                    
                    if (viewState.showOpenAndCloseWarning) {
                        ChannelIssueView(
                            icon: IssueIcon.Warning.shared,
                            message: Strings.GateDetail.openAndCloseWarning,
                            alignment: .center
                        )
                    }

                    if (orientationObserver.orientation.isLandscape) {
                        LandscapeButtons()
                    } else {
                        PortraitButtons()
                    }
                }
                
                if (stateDialogViewModel.present) {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }
                
                if (captionChangeDialogViewModel.present) {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
            }
        }
        
        @ViewBuilder
        private func PortraitButtons() -> some SwiftUI.View {
            VStack(spacing: Distance.small) {
                if (viewState.manualAllowed || viewState.weeklyAllowed || viewState.autoAllowed) {
                    OperatingButtons()
                }
                
                if let openButtonState = viewState.openButtonState,
                   let closeButtonState = viewState.closeButtonState
                {
                    SwitchButtons(
                        leftButton: closeButtonState,
                        rightButton: openButtonState,
                        enabled: !viewState.offline && !viewState.forceActive,
                        padding: EdgeInsets(top: 0, leading: Distance.default, bottom: 0, trailing: Distance.default),
                        spacing: Distance.tiny,
                        onLeftButtonClick: { delegate?.onClose() },
                        onRightButtonClick: { delegate?.onOpen() }
                    )
                }
                
                HStack(spacing: Distance.tiny) {
                    if viewState.forceSupported {
                        LockSuplaButton(
                            pressed: viewState.forceActive,
                            type: viewState.lockIconType,
                            onClick: { delegate?.onForce() }
                        )
                        .disabled(viewState.offline || viewState.forceButtonDisabled)
                    }
                    
                    SuplaButton(
                        viewState.mainButtonLabel,
                        colors: .primaryColors,
                        fullWidth: true,
                        action: { delegate?.onOpenClose() }
                    )
                    .frame(maxWidth: .infinity)
                    .disabled(viewState.offline || viewState.forceActive)
                }
                .padding([.leading, .trailing, .bottom], Distance.default)
            }
        }
        
        @ViewBuilder
        private func LandscapeButtons() -> some SwiftUI.View {
            if (viewState.manualAllowed || viewState.weeklyAllowed || viewState.autoAllowed) {
                OperatingButtons().padding(.bottom, Distance.tiny)
            }
            
            HStack(spacing: Distance.tiny) {
                if viewState.forceSupported {
                    LockSuplaButton(
                        pressed: viewState.forceActive,
                        type: viewState.lockIconType,
                        onClick: { delegate?.onForce() }
                    )
                    .disabled(viewState.offline || viewState.forceButtonDisabled)
                }
                
                if let closeButtonState = viewState.closeButtonState {
                    SwitchButton(
                        state: closeButtonState,
                        onClick: { delegate?.onClose() }
                    )
                    .disabled(viewState.offline || viewState.forceActive)
                }
                
                SuplaButton(
                    viewState.mainButtonLabel,
                    colors: .primaryColors,
                    action: { delegate?.onOpenClose() }
                )
                .frame(height: Dimens.buttonHeight)
                .disabled(viewState.offline || viewState.forceActive)

                if let openButtonState = viewState.openButtonState {
                    SwitchButton(
                        state: openButtonState,
                        onClick: { delegate?.onOpen() }
                    )
                    .disabled(viewState.offline || viewState.forceActive)
                }
            }
            .padding([.leading, .trailing, .bottom], Distance.default)
        }
        
        @ViewBuilder
        private func OperatingButtons() -> some SwiftUI.View {
            OperationButtons(
                manualAllowed: viewState.manualAllowed,
                manualActive: viewState.manualActive,
                weeklyAllowed: viewState.weeklyAllowed,
                weeklyActive: viewState.weeklyActive,
                autoAllowed: viewState.autoAllowed,
                autoActive: viewState.autoActive,
                delegate: delegate
            )
            .padding([.leading, .trailing], Distance.default)
        }
    }
}

#Preview("Single gate") {
    let viewState = GateGeneralFeature.ViewState()
    viewState.channelCurrentStateData = ChannelCurrentState.Data(
        label: Strings.SwitchDetail.stateLabel,
        icon: .originalSuplaIcon(name: "gate-open"),
        value: Strings.General.open
    )
    viewState.openButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-open"),
        label: Strings.General.open,
        active: true,
        colors: .primaryColors
    )
    viewState.closeButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-closed"),
        label: Strings.General.close,
        active: false,
        colors: .primaryColors
    )
    viewState.manualAllowed = true
    viewState.manualActive = true
    viewState.weeklyAllowed = true
    viewState.autoAllowed = true
    
    return GateGeneralFeature.View(
        viewState: viewState,
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "", function: ""),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}

#Preview("All components") {
    let viewState = GateGeneralFeature.ViewState()
    viewState.channelCurrentStateData = ChannelCurrentState.Data(
        label: Strings.SwitchDetail.stateLabel,
        icon: .originalSuplaIcon(name: "gate-open"),
        value: Strings.General.open
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
    viewState.issues = [
        SharedCore.ChannelIssueItem.Error(
            string: localizedString(id: LocalizedStringId.overcurrentWarning)
        )
    ]
    viewState.openButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-open"),
        label: Strings.General.open,
        active: false,
        colors: .primaryColors
    )
    viewState.closeButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-closed"),
        label: Strings.General.close,
        active: true,
        colors: .errorColors
    )
    viewState.manualAllowed = true
    viewState.weeklyAllowed = true
    viewState.weeklyActive = true
    viewState.autoAllowed = true
    viewState.showOpenAndCloseWarning = true
    viewState.forceSupported = true
    viewState.forceActive = true
    viewState.lockIconType = .temporaryClosed

    return GateGeneralFeature.View(
        viewState: viewState,
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "Gate state", function: "Garage door"),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}

#Preview("Group") {
    let viewState = GateGeneralFeature.ViewState()
    viewState.relatedChannelsData = [
        RelatedChannelData.visible(
            id: 1,
            onlineState: .online,
            icon: .originalSuplaIcon(name: "gate-open"),
            caption: "Gate",
            userCaption: "",
            batteryIcon: nil,
            showChannelStateIcon: true
        ),
        RelatedChannelData.visible(
            id: 2,
            onlineState: .offline,
            icon: .originalSuplaIcon(name: "gate-closed"),
            caption: "Gate",
            userCaption: "",
            batteryIcon: nil,
            showChannelStateIcon: false
        ),
        RelatedChannelData.invisible(id: 3)
    ]
    viewState.showOpenAndCloseWarning = true
    viewState.openButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-open"),
        label: Strings.General.open,
        active: true,
        colors: .primaryColors
    )
    viewState.closeButtonState = .init(
        icon: .originalSuplaIcon(name: "gate-closed"),
        label: Strings.General.close,
        active: false,
        colors: .errorColors
    )
    
    return GateGeneralFeature.View(
        viewState: viewState,
        stateDialogViewModel: StateDialogFeature.ViewModel(title: "", function: ""),
        captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
        delegate: nil,
        onInfoClick: { _ in },
        onCaptionLongPress: { _ in }
    )
}
