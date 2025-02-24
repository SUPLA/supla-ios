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

extension StateDialogFeature {
    struct Dialog: View {
        let state: ViewState
        let onDismiss: () -> Void

        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss) {
                VStack(spacing: 0) {
                    SuplaCore.Dialog.Header(title: state.title)

                    if (state.loading) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ForEach(Array(state.values.keys).sorted { $0.rawValue < $1.rawValue }) { key in
                            HStack(alignment: .top, spacing: 1) {
                                Text(key.label)
                                    .fontBodyMedium()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .padding(.leading, Distance.small)
                                    .padding(.trailing, Distance.tiny)
                                    .background(Color.Supla.surface)
                                Text(state.values[key] ?? "")
                                    .font(.Supla.bodyMedium.bold())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .padding(.leading, Distance.tiny)
                                    .padding(.trailing, Distance.small)
                                    .background(Color.Supla.surface)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .background(Color.Supla.background)
                        }
                    }

                    SuplaCore.Dialog.Divider()
                        .padding([.top], Distance.default)

                    BorderedButton(title: Strings.General.close, fullWidth: true) { onDismiss() }
                        .padding([.top, .bottom], Distance.small)
                        .padding([.leading, .trailing], Distance.default)
                }
            }
        }
    }
}

#Preview {
    StateDialogFeature.Dialog(
        state: StateDialogFeature.ViewState(
            remoteId: 123,
            title: "Thermostat",
            loading: false,
            values: [
                .channelId: "1234567",
                .ipAddress: "192.168.100.2",
                .macAddress: "00:0a:95:9d:68:16"
            ]
        ),
        onDismiss: {}
    )
}

#Preview("Loading") {
    StateDialogFeature.Dialog(
        state: StateDialogFeature.ViewState(
            remoteId: 123,
            title: "Thermostat",
            loading: true,
            values: [:]
        ),
        onDismiss: {}
    )
}
