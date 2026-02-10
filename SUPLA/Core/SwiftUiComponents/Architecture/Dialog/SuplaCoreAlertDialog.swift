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
    
extension SuplaCore {
    struct AlertDialogState {
        var header: String
        var message: String
        var positiveButtonText: String?
        var negativeButtonText: String?
    }
    
    struct AlertDialog: View {
        var header: String
        var message: String
        var onDismiss: () -> Void
        var primaryButtonSpec: FilledButton.ButtonSpec?
        var secondaryButtonText: String?
        var onPrimaryButtonClick: (() -> Void)?
        var onSecondaryButtonClick: (() -> Void)?
        
        init(
            header: String,
            message: String,
            onDismiss: @escaping () -> Void,
            primaryButtonSpec: FilledButton.ButtonSpec? = nil,
            secondaryButtonText: String? = nil,
            onPrimaryButtonClick: (() -> Void)? = nil,
            onSecondaryButtonClick: (() -> Void)? = nil
        ) {
            self.header = header
            self.message = message
            self.onDismiss = onDismiss
            self.primaryButtonSpec = primaryButtonSpec
            self.secondaryButtonText = secondaryButtonText
            self.onPrimaryButtonClick = onPrimaryButtonClick
            self.onSecondaryButtonClick = onSecondaryButtonClick
        }
        
        init(
            state: AlertDialogState,
            onDismiss: @escaping () -> Void,
            onPrimaryButtonClick: (() -> Void)? = nil,
            onSecondaryButtonClick: (() -> Void)? = nil
        ) {
            self.header = state.header
            self.message = state.message
            self.primaryButtonSpec = .optional(state.positiveButtonText)
            self.secondaryButtonText = state.negativeButtonText
            self.onDismiss = onDismiss
            self.onPrimaryButtonClick = onPrimaryButtonClick
            self.onSecondaryButtonClick = onSecondaryButtonClick
        }
        
        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                SuplaCore.Dialog.Header(title: header)
                    
                SwiftUI.Text(message)
                    .fontBodyMedium()
                    .textColor(.Supla.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Distance.default)
                    
                if let primaryButtonSpec, let secondaryButtonText {
                    SuplaCore.Dialog.DoubleButtons(
                        onSecondaryClick: onSecondaryButtonClick ?? {},
                        onPrimaryClick: onPrimaryButtonClick ?? {},
                        secondaryText: secondaryButtonText,
                        primaryButtonSpec: primaryButtonSpec
                    )
                } else if let primaryButtonSpec {
                    FilledButton(title: primaryButtonSpec.text, fullWidth: true) {
                        if let onPrimaryButtonClick {
                            onPrimaryButtonClick()
                        }
                    }
                    .padding(Distance.default)
                } else if let secondaryButtonText {
                    BorderedButton(title: secondaryButtonText, fullWidth: true) {
                        if let onSecondaryButtonClick {
                            onSecondaryButtonClick()
                        }
                    }
                    .padding(Distance.default)
                }
            }
        }
    }
}

#Preview {
    SuplaCore.AlertDialog(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        onDismiss: {},
        primaryButtonSpec: .default(Strings.CarPlay.confirmDelete),
        secondaryButtonText: Strings.General.cancel
    )
}

#Preview("Only positive button") {
    SuplaCore.AlertDialog(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        onDismiss: {},
        primaryButtonSpec: .default(Strings.CarPlay.confirmDelete)
    )
}

#Preview("Only negative button") {
    SuplaCore.AlertDialog(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        onDismiss: {},
        secondaryButtonText: Strings.General.cancel
    )
}
