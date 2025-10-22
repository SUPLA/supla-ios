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

extension GateGeneralFeature {
    protocol ViewDelegate {
        func onOpen()
        func onClose()
        func onOpenClose()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
        var delegate: ViewDelegate?
        
        let onInfoClick: (RelatedChannelData) -> Void
        let onCaptionLongPress: (RelatedChannelData) -> Void
        
        @StateObject private var orientationObserver = OrientationObserver()
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack {
                    if let stateData = viewState.deviceStateData {
                        DeviceStateView(data: stateData)
                        ChannelIssuesView(issues: viewState.issues)
                        Spacer()
                    }
                    
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
                        LandscapeButtons(viewState: viewState, delegate: delegate)
                    } else {
                        PortraitButtons(viewState: viewState, delegate: delegate)
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
    }
    
    private struct PortraitButtons: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            VStack {
                if let openButtonState = viewState.openButtonState,
                   let closeButtonState = viewState.closeButtonState
                {
                    SwitchButtons(
                        leftButton: closeButtonState,
                        rightButton: openButtonState,
                        enabled: !viewState.offline,
                        onLeftButtonClick: { delegate?.onClose() },
                        onRightButtonClick: { delegate?.onOpen() }
                    )
                }
                
                RoundedControlButtonWrapperView(
                    type: .positive,
                    text: viewState.mainButtonLabel,
                    isEnabled: viewState.offline == false,
                    onTap: { delegate?.onOpenClose() }
                )
                .frame(height: Dimens.buttonHeight)
                .padding([.leading, .trailing, .bottom], Distance.default)
            }
        }
    }
    
    private struct LandscapeButtons: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            HStack(spacing: Distance.default) {
                if let closeButtonState = viewState.closeButtonState {
                    SwitchButton(
                        state: closeButtonState,
                        enabled: !viewState.offline,
                        onClick: { delegate?.onClose() }
                    )
                }
                
                RoundedControlButtonWrapperView(
                    type: .positive,
                    text: viewState.mainButtonLabel,
                    isEnabled: viewState.offline == false,
                    onTap: { delegate?.onOpenClose() }
                )
                .frame(height: Dimens.buttonHeight)
                
                if let openButtonState = viewState.openButtonState {
                    SwitchButton(
                        state: openButtonState,
                        enabled: !viewState.offline,
                        onClick: { delegate?.onOpen() }
                    )
                }
            }
            .padding([.leading, .trailing, .bottom], Distance.default)
        }
    }
}

#Preview("Single gate") {
    let viewState = GateGeneralFeature.ViewState()
    viewState.deviceStateData = DeviceStateData(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: "gate-open"),
        value: Strings.General.open
    )
    viewState.openButtonState = .init(
        icon: .suplaIcon(name: "gate-open"),
        label: Strings.General.open,
        active: true,
        type: .positive
    )
    viewState.closeButtonState = .init(
        icon: .suplaIcon(name: "gate-closed"),
        label: Strings.General.close,
        active: false,
        type: .positive
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

#Preview("Group") {
    let viewState = GateGeneralFeature.ViewState()
    viewState.relatedChannelsData = [
        RelatedChannelData(
            channelId: 1,
            onlineState: .online,
            icon: .suplaIcon(name: "gate-open"),
            caption: "Gate",
            userCaption: "",
            batteryIcon: nil,
            showChannelStateIcon: true
        ),
        RelatedChannelData(
            channelId: 2,
            onlineState: .offline,
            icon: .suplaIcon(name: "gate-closed"),
            caption: "Gate",
            userCaption: "",
            batteryIcon: nil,
            showChannelStateIcon: false
        )
    ]
    viewState.showOpenAndCloseWarning = true
    viewState.openButtonState = .init(
        icon: .suplaIcon(name: "gate-open"),
        label: Strings.General.open,
        active: true,
        type: .positive
    )
    viewState.closeButtonState = .init(
        icon: .suplaIcon(name: "gate-closed"),
        label: Strings.General.close,
        active: false,
        type: .positive
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
