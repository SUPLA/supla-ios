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

extension CaptionChangeDialogFeature {
    struct Dialog: View {
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: viewModel.hide) {
                SuplaCore.Dialog.Header(title: Strings.ChangeCaption.header)
                
                SuplaCore.Dialog.Content(spacing: 0) {
                    SuplaCore.Dialog.TextField(value: $viewModel.caption, label: viewModel.label)
                    
                    if let error = viewModel.error {
                        SuplaCore.Dialog.FieldErrorText(error)
                    }
                }
                
                SuplaCore.Dialog.DoubleButtons(
                    onNegativeClick: { viewModel.hide() },
                    onPositiveClick: { viewModel.onApply() }
                )
            }
        }
    }
}

#Preview {
    CaptionChangeDialogFeature.Dialog(
        viewModel: CaptionChangeDialogFeature.ViewModel(
            caption: "Thermostat",
            label: Strings.ChangeCaption.channelName,
            error: "Change failed!"
        )
    )
}
