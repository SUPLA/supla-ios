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
        let label: String?
        let error: String?
        let onDismiss: () -> Void
        let onOK: (String) -> Void
        
        @State private var caption: String
        
        init(
            state: ViewState?,
            onDismiss: @escaping () -> Void,
            onOK: @escaping (String) -> Void
        ) {
            self.label = state?.captionLabel
            self.error = state?.error
            self.onDismiss = onDismiss
            self.onOK = onOK
            
            self._caption = State(initialValue: state?.caption ?? "")
        }
        
        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                VStack(alignment: .leading, spacing: 0) {
                    SuplaCore.Dialog.Header(title: Strings.ChangeCaption.header)
                    SuplaCore.Dialog.TextField(value: $caption, label: label)
                        .padding([.leading, .trailing], Distance.default)
                    if let error {
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
                            onDismiss()
                        }
                        FilledButton(title: Strings.General.ok, fullWidth: true) {
                            onOK(caption)
                        }
                    }
                    .padding([.top, .bottom], Distance.small)
                    .padding([.leading, .trailing], Distance.default)
                }
            }
        }
    }
}

fileprivate extension CaptionChangeDialogFeature.ViewState {
    var captionLabel: String {
        switch (subjectType) {
        case .channel: Strings.ChangeCaption.channelName
        case .group: Strings.ChangeCaption.groupName
        case .scene: Strings.ChangeCaption.sceneName
        }
    }
}

#Preview {
    CaptionChangeDialogFeature.Dialog(
        state: CaptionChangeDialogFeature.ViewState(
            remoteId: 1,
            subjectType: .channel,
            caption: "Thermostat",
            error: "Change failed!"
        ),
        onDismiss: {},
        onOK: { _ in }
    )
    
}
