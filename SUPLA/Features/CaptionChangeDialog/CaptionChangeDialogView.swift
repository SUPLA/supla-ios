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
                VStack(alignment: .leading, spacing: 0) {
                    SuplaCore.Dialog.Header(title: Strings.ChangeCaption.header)
                    SuplaCore.Dialog.TextField(value: $viewModel.caption, label: viewModel.label)
                        .padding([.leading, .trailing], Distance.default)
                    if let error = viewModel.error {
                        Text(error)
                            .fontTitleSmall()
                            .textColor(Color.Supla.error)
                            .padding([.leading, .trailing], Distance.small + Distance.default)
                            .padding(.top, 2)
                    }
                    SuplaCore.Dialog.Divider()
                        .padding([.top], Distance.default)
                    HStack(spacing: Distance.default) {
                        BorderedButton(title: Strings.General.cancel, fullWidth: true) {
                            viewModel.hide()
                        }
                        FilledButton(title: Strings.General.ok, fullWidth: true) {
                            viewModel.onApply()
                        }
                    }
                    .padding([.top, .bottom], Distance.small)
                    .padding([.leading, .trailing], Distance.default)
                }
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
