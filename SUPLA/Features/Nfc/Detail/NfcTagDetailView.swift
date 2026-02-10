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

extension NfcTagDetailFeature {
    protocol ViewDelegate {
        func onInfoClick()
        func onLockClick()
        func onEditClick()
        func onDeleteClick()
        func onDismissDialogs()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        let delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(spacing: Distance.tiny) {
                    ScrollView {
                        TagDetails()
                        TagReadings()
                    }
                    FilledButton(
                        title: Strings.Nfc.Edit.title,
                        fullWidth: true,
                        action: { delegate?.onEditClick() }
                    )
                    .padding(Distance.default)
                }
                
                if let dialog = viewState.dialog {
                    switch (dialog) {
                    case .deleteTag: DeleteDialog()
                    case .deleteLockedTag: DeleteLockedDialog()
                    case .info: InfoDialog()
                    case .lockFailed: LockFailureDialog()
                    }
                }
            }
        }

        @ViewBuilder
        private func TagDetails() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Nfc.Detail.tagData)
                    .fontTitleSmall()

                Spacer().frame(height: Distance.default)
                LabelText(text: Strings.Nfc.Edit.tagName)
                Text(viewState.tagName)
                    .fontBodyLarge()
                    .padding(0)

                Spacer().frame(height: Distance.default)
                LabelText(text: Strings.General.action)
                ActionText()

                Spacer().frame(height: Distance.default)
                LabelText(text: "UUID")
                Text(viewState.tagUuid)
                    .fontBodyLarge()

                Spacer().frame(height: Distance.default)
                LockedRow()
            }
            .padding(Distance.default)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Supla.surface)
        }

        @ViewBuilder
        private func ActionText() -> some SwiftUI.View {
            if let actionId = viewState.actionId,
               let subjectName = viewState.subjectName
            {
                Text("\(actionId.label) - \(subjectName)")
                    .fontBodyLarge()
            } else {
                HStack {
                    Image(.Icons.warning)
                    Text(Strings.Nfc.List.missingAction)
                        .fontBodyLarge()
                }
            }
        }

        @ViewBuilder
        private func LockedRow() -> some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                if (viewState.tagLocked) {
                    HStack {
                        Icon.Lock(color: .Supla.onBackground)
                        Text(Strings.Nfc.Detail.locked)
                            .fontBodySmall()
                    }
                    .frame(maxWidth: .infinity, minHeight: Dimens.buttonHeight)
                    .background(Color.Supla.background)
                    .cornerRadius(Dimens.radiusDefault)

                    IconButton(
                        name: .Icons.infoFilled,
                        color: .Supla.primary,
                        action: { delegate?.onInfoClick() }
                    )
                    .buttonStyle(FilledIconStyle(color: .Supla.surfaceVariant))
                } else {
                    LockButton { delegate?.onLockClick() }
                    IconButton(
                        name: .Icons.infoFilled,
                        color: .Supla.primary,
                        action: { delegate?.onInfoClick() }
                    )
                    .buttonStyle(FilledIconStyle(color: .Supla.surfaceVariant))
                }
            }
        }

        @ViewBuilder
        private func TagReadings() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                Text(Strings.Nfc.Detail.lastReadings)
                    .fontTitleSmall()
                
                if (viewState.lastReadingItems.isEmpty) {
                    EmptyListView(size: .small)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(Distance.default)
                } else {
                    ForEach(viewState.lastReadingItems.indices, id: \.self) { idx in
                        let reading = viewState.lastReadingItems[idx]
                        
                        HStack(alignment: .center, spacing: Distance.tiny) {
                            TimelineDot(
                                leading: idx == 0,
                                trailing: idx == viewState.lastReadingItems.count - 1
                            )
                            Text(reading.date.toStringMixedFormat())
                                .fontBodyMedium()
                            Circle()
                                .fill(Color.Supla.outline)
                                .frame(width: 6, height: 6)
                            Text(reading.resultIconText)
                                .fontBodyMedium()
                                .textColor(reading.resultIconColor)
                            Text(reading.resultText)
                                .fontBodyMedium()
                        }
                        .fixedSize()
                    }
                }
            }
            .padding(Distance.default)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Supla.surface)
        }
        
        @ViewBuilder
        private func DeleteDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.Nfc.Detail.deleteDialogTitle,
                message: Strings.Nfc.Detail.deleteDialogMessage,
                onDismiss: { delegate?.onDismissDialogs() },
                primaryButtonSpec: .critical(Strings.General.delete),
                secondaryButtonText: Strings.General.cancel,
                onPrimaryButtonClick: { delegate?.onDeleteClick() },
                onSecondaryButtonClick: { delegate?.onDismissDialogs() }
            )
        }
        
        @ViewBuilder
        private func DeleteLockedDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.Nfc.Detail.deleteLockedDialogTitle,
                message: Strings.Nfc.Detail.deleteLockedDialogMessage,
                onDismiss: { delegate?.onDismissDialogs() },
                primaryButtonSpec: .critical(Strings.General.delete),
                secondaryButtonText: Strings.General.cancel,
                onPrimaryButtonClick: { delegate?.onDeleteClick() },
                onSecondaryButtonClick: { delegate?.onDismissDialogs() }
            )
        }
        
        @ViewBuilder
        private func InfoDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.Nfc.Detail.infoDialogTitle,
                message: Strings.Nfc.Detail.infoDialogMessage,
                onDismiss: { delegate?.onDismissDialogs() },
                secondaryButtonText: Strings.General.close,
                onPrimaryButtonClick: { delegate?.onDeleteClick() },
                onSecondaryButtonClick: { delegate?.onDismissDialogs() }
            )
        }
        
        @ViewBuilder
        private func LockFailureDialog() -> some SwiftUI.View {
            SuplaCore.AlertDialog(
                header: Strings.Nfc.Detail.lockError,
                message: Strings.Nfc.Detail.errorProtectionFailed,
                onDismiss: { delegate?.onDismissDialogs() },
                primaryButtonSpec: .default(Strings.Status.tryAgain),
                secondaryButtonText: Strings.General.cancel,
                onPrimaryButtonClick: { delegate?.onLockClick() },
                onSecondaryButtonClick: { delegate?.onDismissDialogs() }
            )
        }
    }
}

private struct LockButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Icon.Lock(color: .Supla.onBackground)
                Text(Strings.Nfc.Detail.lockTag)
                    .fontLabelLarge()
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BorderedButtonStyle(backgroundColor: .Supla.surface))
    }
}

private struct TimelineDot: View {
    var leading: Bool = false
    var trailing: Bool = false
    
    var body: some View {
        VStack(spacing: 3) {
            if leading {
                Spacer()
            } else {
                Rectangle()
                    .fill(Color.Supla.outline)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .clipShape(
                        RoundedCorner(radius: 1, corners: [.bottomLeft, .bottomRight])
                    )
            }
            
            Circle()
                .fill(Color.Supla.onBackground)
                .frame(width: 8, height: 8)
            
            if trailing {
                Spacer()
            } else {
                Rectangle()
                    .fill(Color.Supla.outline)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .clipShape(
                        RoundedCorner(radius: 1, corners: [.topLeft, .topRight])
                    )
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 1
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview() {
    NfcTagDetailFeature.View(
        viewState: NfcTagDetailFeature.ViewState(
            tagName: "Living room",
            tagUuid: UUID().uuidString
        ),
        delegate: nil
    )
}

#Preview("Locked") {
    NfcTagDetailFeature.View(
        viewState: NfcTagDetailFeature.ViewState(
            tagName: "Living room",
            tagUuid: UUID().uuidString,
            tagLocked: true,
            lastReadingItems: [
                NfcTagReadingItem(date: .now, result: .success),
                NfcTagReadingItem(date: .now.advanced(by: -120), result: .failure),
                NfcTagReadingItem(date: .now.advanced(by: -12000), result: .actionMissing),
                NfcTagReadingItem(date: .now.advanced(by: -92000), result: .success)
            ]
        ),
        delegate: nil
    )
}

#Preview("With action") {
    NfcTagDetailFeature.View(
        viewState: NfcTagDetailFeature.ViewState(
            tagName: "Living room",
            tagUuid: UUID().uuidString,
            actionId: .turnOn,
            subjectName: "Living room light"
        ),
        delegate: nil
    )
}

#Preview("With delete dialog") {
    NfcTagDetailFeature.View(
        viewState: NfcTagDetailFeature.ViewState(
            tagName: "Living room",
            tagUuid: UUID().uuidString,
            actionId: .turnOn,
            subjectName: "Living room light",
            dialog: .deleteTag
        ),
        delegate: nil
    )
}
