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

extension ActionTriggerListFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel

        let onItemClick: (RelatedChannelData) -> Void

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    HStack {
                        Text(Strings.ActionTrigger.relatedButtons.uppercased())
                            .fontBodyMedium()
                        Spacer()
                    }
                    .padding(.horizontal, Dimens.distanceSmall)
                    .padding(.top, Dimens.distanceDefault)
                    .padding(.bottom, Distance.tiny)

                    RelatedChannelsView(
                        channels: viewState.relatedChannels,
                        onInfoClick: { stateDialogViewModel.show(remoteId: $0.id) },
                        onCaptionLongPress: {
                            captionChangeDialogViewModel.show(
                                remoteId: $0.id,
                                caption: $0.userCaption,
                                captionType: .channel
                            )
                        },
                        onItemClick: { onItemClick($0) }
                    )
                }

                if stateDialogViewModel.present {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }
                if captionChangeDialogViewModel.present {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
            }
            .environment(\.scaleFactor, viewState.scale)
        }
    }
}

struct ActionTriggerIconsBlock: SwiftUI.View {
    @Environment(\.scaleFactor) private var scaleFactor

    let indicatorType: ActionTriggerValue.IndicatorType
    let weeklyActive: Bool
    let stateIconVisible: Bool

    @ViewBuilder
    var body: some SwiftUI.View {
        if indicatorType != .none || weeklyActive {
            HStack(spacing: Distance.tiny) {
                indicatorIcon
                if weeklyActive {
                    Image(.Icons.schedule)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .foregroundColor(.Supla.onBackground)
                }
                if !stateIconVisible {
                    Spacer().frame(width: Distance.tiny)
                }
            }
            .padding(.trailing, Distance.tiny)
        }
    }

    @ViewBuilder
    private var indicatorIcon: some SwiftUI.View {
        switch indicatorType {
        case .none:
            EmptyView()
        case .locked:
            Icon.Lock(size: Dimens.iconSize, color: .Supla.onBackground)
        case .temporaryUnlocked:
            Image(.Icons.unlockTemporary)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                .foregroundColor(.Supla.onBackground)
        }
    }
    
    static func create(
        indicatorType: SharedCore.ActionTriggerValue.IndicatorType?,
        weeklyActive: Bool?,
        showChannelStateIcon: Bool
    ) -> AnyView {
        AnyView(ActionTriggerIconsBlock(
            indicatorType: indicatorType ?? .none,
            weeklyActive: weeklyActive ?? false,
            stateIconVisible: showChannelStateIcon
        ))
    }
}

#Preview("Action trigger list") {
    let viewState = ActionTriggerListFeature.ViewState()
    viewState.relatedChannels = [
        .visible(
            id: 101,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_switch-on"),
            caption: "Turn on lights",
            userCaption: "Evening lights",
            iconsBlock: {
                AnyView(ActionTriggerIconsBlock(
                    indicatorType: .locked,
                    weeklyActive: true,
                    stateIconVisible: true
                ))
            },
            showChannelStateIcon: true
        ),
        .visible(
            id: 102,
            onlineState: .online,
            icon: .suplaIcon(name: "fnc_switch-on"),
            caption: "Open the gate",
            userCaption: "",
            iconsBlock: {
                AnyView(ActionTriggerIconsBlock(
                    indicatorType: .temporaryUnlocked,
                    weeklyActive: false,
                    stateIconVisible: true
                ))
            },
            showChannelStateIcon: true
        )
    ]

    return BackgroundStack(alignment: .top) {
        ActionTriggerListFeature.View(
            viewState: viewState,
            stateDialogViewModel: StateDialogFeature.ViewModel(),
            captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel(),
            onItemClick: { _ in }
        )
    }
}

