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
        
        init (
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
                VStack(spacing: 0) {
                    SuplaCore.Dialog.Header(title: header)
                    
                    SwiftUI.Text(message)
                        .fontBodyMedium()
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], Distance.default)
                    
                    SuplaCore.Dialog.Divider()
                        .padding([.top], Distance.default)
                    
                    if let positiveButtonText, let negativeButtonText {
                        HStack(spacing: Distance.tiny) {
                            BorderedButton(title: negativeButtonText, fullWidth: true) {
                                if let onNegativeButtonClick {
                                    onNegativeButtonClick()
                                }
                            }
                            FilledButton(title: positiveButtonText, fullWidth: true) {
                                if let onPositiveButtonClick {
                                    onPositiveButtonClick()
                                }
                            }
                        }
                        .padding([.top, .bottom], Distance.small)
                        .padding([.leading, .trailing], Distance.default)
                    } else if let positiveButtonText {
                        FilledButton(title: positiveButtonText, fullWidth: true) {
                            if let onPositiveButtonClick {
                                onPositiveButtonClick()
                            }
                        }
                        .padding([.top, .bottom], Distance.small)
                        .padding([.leading, .trailing], Distance.default)
                    } else if let negativeButtonText {
                        BorderedButton(title: negativeButtonText, fullWidth: true) {
                            if let onNegativeButtonClick {
                                onNegativeButtonClick()
                            }
                        }
                        .padding([.top, .bottom], Distance.small)
                        .padding([.leading, .trailing], Distance.default)
                    }
                }
            }
        }
    }
}
