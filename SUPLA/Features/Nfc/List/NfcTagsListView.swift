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

extension NfcTagsListFeature {
    protocol ViewDelegate {
        func onNewItem()
        func onItemClick(uuid: String)
        func hideDialog()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(spacing: 0) {
                    if (viewState.nfcState == .unavailable) {
                        MessageView(message: Strings.Nfc.List.notSupported, icon: .Icons.error)
                    } else {
                        if (viewState.items.isEmpty) {
                            Spacer()
                            EmptyListView()
                            Spacer()
                        } else {
                            SwiftUI.List {
                                ForEach(viewState.items) { item in
                                    ItemRow(data: item)
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparator(.hidden)
                                        .onTapGesture { delegate?.onItemClick(uuid: item.uuid) }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }
                
                if (viewState.loading) {
                    ZStack {
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if let dialog = viewState.dialog {
                    switch (dialog) {
                        case .duplicate(let uuid, let name): DuplicateDialog(uuid, name: name)
                        case .timeout: TimeoutDialog()
                    }
                }
            }
            .if(viewState.nfcState == .available) {
                $0.overlay(
                    FloatingPlusButton(action: { delegate?.onNewItem() }),
                    alignment: .bottomTrailing
                )
            }
        }
        
        @ViewBuilder
        private func DuplicateDialog(_ uuid: String, name: String) -> some SwiftUI.View {
            SuplaCore.DialogWithIcon(
                header: Strings.Nfc.List.duplicateDialogTitle,
                message: Strings.Nfc.List.duplicateDialogMessage.arguments(name),
                iconType: .warning,
                onDismiss: {},
                primaryButtonSpec: .default(Strings.Nfc.List.duplicateDialogOpenTag),
                secondaryButtonText: Strings.General.cancel,
                onPrimaryButtonClick: { delegate?.onItemClick(uuid: uuid) },
                onSecondaryButtonClick: { delegate?.hideDialog() }
            )
        }
        
        @ViewBuilder
        private func TimeoutDialog() -> some SwiftUI.View {
            SuplaCore.DialogWithIcon(
                header: Strings.Nfc.List.timeoutDialogTitle,
                message: Strings.Nfc.List.timeoutDialogMessage,
                iconType: .timeout,
                onDismiss: {},
                primaryButtonSpec: .default(Strings.Status.tryAgain),
                secondaryButtonText: Strings.General.exit,
                onPrimaryButtonClick: {
                    delegate?.hideDialog()
                    delegate?.onNewItem()
                },
                onSecondaryButtonClick: { delegate?.hideDialog() }
            )
        }
    }
    
    struct MessageView: SwiftUI.View {
        let message: String
        let icon: String?
        
        init(message: String, icon: String? = .Icons.warning) {
            self.message = message
            self.icon = icon
        }
        
        var body: some SwiftUI.View {
            HStack(alignment: .center, spacing: Distance.small) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                }
                Text(message)
                    .fontBodyMedium()
            }
            .padding(Distance.small)
            .suplaCard()
        }
    }
    
    struct ItemRow: SwiftUI.View {
        let data: NfcTagDataDto

        var body: some SwiftUI.View {
            ListItemRow {
                ListItemIcon(iconResult: data.icon)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: Distance.tiny) {
                        CellCaption(text: data.name)
                        if (data.readOnly) {
                            Image(.Icons.lock)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
                        }
                    }
                    HStack {
                        if (data.noAction) {
                            Icon.Warning()
                        } else if (data.subjectNotExists) {
                            Icon.Error()
                        }
                        Text(actionText)
                            .fontBodySmall()
                            .textColor(.Supla.onSurfaceVariant)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Image(.Icons.arrowRight)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSizeSmall, height: Dimens.iconSizeSmall)
            }
        }
        
        private var actionText: String {
            if let actionName = data.action?.name,
               let subjectName = data.subjectName,
               let profileName = data.profileName
            {
                "\(actionName) - \(subjectName) (\(profileName))"
            } else if let actionName = data.action?.name, let subjectName = data.subjectName {
                "\(actionName) - \(subjectName)"
            } else {
                Strings.Nfc.List.missingAction
            }
        }
    }
}

#Preview("Unsupported") {
    NfcTagsListFeature.View(
        viewState: NfcTagsListFeature.ViewState(),
        delegate: nil
    )
}

#Preview("Empty") {
    let state = NfcTagsListFeature.ViewState()
    state.nfcState = .available
    
    return NfcTagsListFeature.View(
        viewState: state,
        delegate: nil
    )
}

#Preview("With content") {
    let state = NfcTagsListFeature.ViewState()
    state.nfcState = .available
    state.items = [
        NfcTagDataDto(
            uuid: UUID().uuidString,
            name: "Tag 1",
            icon: .suplaIcon(name: .Icons.fncRgbOn),
            profileId: 1,
            profileName: "Default",
            subjectType: .channel,
            subjectId: 2,
            subjectName: "Living room",
            action: .toggle,
            readOnly: false,
            subjectNotExists: false,
            readingItems: []
        ),
        NfcTagDataDto(
            uuid: UUID().uuidString,
            name: "Tag 2",
            icon: .suplaIcon(name: .Icons.fncUnknown),
            profileId: 1,
            profileName: "Default",
            subjectType: .channel,
            subjectId: 2,
            subjectName: nil,
            action: .turnOn,
            readOnly: false,
            subjectNotExists: true,
            readingItems: []
        ),
        NfcTagDataDto(
            uuid: UUID().uuidString,
            name: "Tag 3",
            icon: .suplaIcon(name: .Icons.fncUnknown),
            profileId: 1,
            profileName: nil,
            subjectType: .channel,
            subjectId: 2,
            subjectName: nil,
            action: nil,
            readOnly: true,
            subjectNotExists: false,
            readingItems: []
        )
    ]
    
    return NfcTagsListFeature.View(
        viewState: state,
        delegate: nil
    )
}
