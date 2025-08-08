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

extension AddWizardFeature {
    protocol SetPasswordDialogDelegate: AnyObject {
        func onCloseSetPasswordDialog()
        func onSetPassword(_ password: String, _ repeatPassword: String)
    }

    struct SetPasswordDialogState: Changeable {
        var error: Bool
        var processing: Bool
        var ssid: String?

        init(error: Bool = false, processing: Bool = false, ssid: String? = nil) {
            self.error = error
            self.processing = processing
            self.ssid = ssid
        }
    }

    struct SetPasswordDialog: SwiftUI.View {
        let state: SetPasswordDialogState
        weak var delegate: SetPasswordDialogDelegate?

        @State private var password: String = ""
        @State private var passwordRepeat: String = ""
        @State private var focusField: FocusField? = .password

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: {}) {
                SuplaCore.Dialog.Header(title: Strings.AddWizard.passwordEnterTitle)

                SuplaCore.Dialog.Content(alignment: .center) {
                    if let ssid = state.ssid {
                        Text(ssid)
                            .fontLabelMedium()
                    }
                    PasswordTextField(
                        title: Strings.AddWizard.passwordNewLabel.uppercased(),
                        text: $password,
                        disabled: state.processing,
                        error: state.error
                    )
                    .focused($focusField, equals: .password)
                    .onSubmitCompat { focusField = .repeatPassword }
                    .submitLabelCompat(.next)
                    
                    PasswordTextField(
                        title: Strings.AddWizard.passwordRepeatLabel.uppercased(),
                        text: $passwordRepeat,
                        disabled: state.processing,
                        error: state.error
                    )
                    .focused($focusField, equals: .repeatPassword)
                    .onSubmitCompat { delegate?.onSetPassword(password, passwordRepeat) }
                    .submitLabelCompat(.go)
                    
                    Text(Strings.AddWizard.passwordRules)
                        .fontBodySmall()
                        .textColor(state.error ? Color.Supla.error : Color.Supla.onSurfaceVariant)
                }

                SuplaCore.Dialog.DoubleButtons(
                    onNegativeClick: { delegate?.onCloseSetPasswordDialog() },
                    onPositiveClick: { delegate?.onSetPassword(password, passwordRepeat) },
                    processing: state.processing,
                    positiveDisabled: password.isEmpty,
                    negativeText: Strings.General.cancel,
                    positiveText: Strings.General.ok
                )
            }
        }
    }

    private enum FocusField {
        case password, repeatPassword
    }
}

#Preview {
    AddWizardFeature.SetPasswordDialog(
        state: AddWizardFeature.SetPasswordDialogState(
            error: true,
            ssid: "SUPLA-EXAMPLE-78218479E27C"
        )
    )
}

#Preview("Processing") {
    AddWizardFeature.SetPasswordDialog(
        state: AddWizardFeature.SetPasswordDialogState(
            processing: true,
            ssid: "SUPLA-EXAMPLE-78218479E27C"
        )
    )
}
