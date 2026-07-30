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

extension CredentialsFeature {
    protocol ViewDelegate {
        func onDismiss()
        func onAuthorize()
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: { delegate?.onDismiss() }) {
                SuplaCore.Dialog.Header(title: title)

                SuplaCore.Dialog.Content(spacing: 0) {
                    SuplaCore.Dialog.TextField(
                        value: $state.userName,
                        label: Strings.AuthorizationDialog.emailAddress,
                        disabled: !state.userNameEnabled
                    )

                    PasswordTextField(
                        title: Strings.AuthorizationDialog.password,
                        text: $state.password,
                        error: state.error != nil
                    )
                    .padding(.top, Distance.default)

                    if let error = state.error {
                        SuplaCore.Dialog.FieldErrorText(error)
                    }
                }

                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: { delegate?.onDismiss() },
                    onPrimaryClick: { delegate?.onAuthorize() },
                    processing: state.loading,
                    primaryDisabled: state.password.isEmpty
                )
            }
        }

        private var title: String {
            if (state.isCloudAccount) {
                Strings.AuthorizationDialog.cloudTitle
            } else {
                Strings.AuthorizationDialog.privateTitle
            }
        }
    }
}

#Preview {
    CredentialsFeature.View(
        state: CredentialsFeature.ViewState(
            userName: "user@supla.org",
            isCloudAccount: true,
            userNameEnabled: true
        ),
        delegate: nil
    )
}
