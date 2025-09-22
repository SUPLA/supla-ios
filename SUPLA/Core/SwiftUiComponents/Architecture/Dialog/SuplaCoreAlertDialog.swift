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
        var positiveButtonText: String?
        var negativeButtonText: String?
        var onPositiveButtonClick: (() -> Void)?
        var onNegativeButtonClick: (() -> Void)?
        
        init(
            header: String,
            message: String,
            onDismiss: @escaping () -> Void,
            positiveButtonText: String? = nil,
            negativeButtonText: String? = nil,
            onPositiveButtonClick: (() -> Void)? = nil,
            onNegativeButtonClick: (() -> Void)? = nil
        ) {
            self.header = header
            self.message = message
            self.onDismiss = onDismiss
            self.positiveButtonText = positiveButtonText
            self.negativeButtonText = negativeButtonText
            self.onPositiveButtonClick = onPositiveButtonClick
            self.onNegativeButtonClick = onNegativeButtonClick
        }
        
        init(
            state: AlertDialogState,
            onDismiss: @escaping () -> Void,
            onPositiveButtonClick: (() -> Void)? = nil,
            onNegativeButtonClick: (() -> Void)? = nil
        ) {
            self.header = state.header
            self.message = state.message
            self.positiveButtonText = state.positiveButtonText
            self.negativeButtonText = state.negativeButtonText
            self.onDismiss = onDismiss
            self.onPositiveButtonClick = onPositiveButtonClick
            self.onNegativeButtonClick = onNegativeButtonClick
        }
        
        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                SuplaCore.Dialog.Header(title: header)
                    
                SwiftUI.Text(message)
                    .fontBodyMedium()
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Distance.default)
                    
                if let positiveButtonText, let negativeButtonText {
                    SuplaCore.Dialog.DoubleButtons(
                        onNegativeClick: onNegativeButtonClick ?? {},
                        onPositiveClick: onPositiveButtonClick ?? {},
                        negativeText: negativeButtonText,
                        positiveText: positiveButtonText
                    )
                } else if let positiveButtonText {
                    SuplaCore.Dialog.Divider()
                        .padding([.top], Distance.default)
                    FilledButton(title: positiveButtonText, fullWidth: true) {
                        if let onPositiveButtonClick {
                            onPositiveButtonClick()
                        }
                    }
                    .padding(Distance.default)
                } else if let negativeButtonText {
                    SuplaCore.Dialog.Divider()
                        .padding([.top], Distance.default)
                    BorderedButton(title: negativeButtonText, fullWidth: true) {
                        if let onNegativeButtonClick {
                            onNegativeButtonClick()
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
        positiveButtonText: Strings.CarPlay.confirmDelete,
        negativeButtonText: Strings.General.cancel,
        onPositiveButtonClick: {},
        onNegativeButtonClick: {}
    )
}

#Preview("Only positive button") {
    SuplaCore.AlertDialog(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        onDismiss: {},
        positiveButtonText: Strings.CarPlay.confirmDelete,
        onPositiveButtonClick: {},
    )
}

#Preview("Only negative button") {
    SuplaCore.AlertDialog(
        header: Strings.CarPlay.deleteTitle,
        message: Strings.CarPlay.deleteMessage,
        onDismiss: {},
        negativeButtonText: Strings.General.cancel,
        onNegativeButtonClick: {}
    )
}
