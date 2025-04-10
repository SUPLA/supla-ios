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
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            SuplaCore.Dialog.Base(onDismiss: viewModel.onDismiss) {
                VStack(spacing: 0) {
                    StateDialogHeader(viewModel.title, viewModel.subtitle)

                    ZStack {
                        VStack(spacing: 0) {
                            StateDialogValueRow(Strings.General.function, viewModel.function)
                            ForEach(Array(viewModel.values.keys).sorted { $0.rawValue < $1.rawValue }) { key in
                                StateDialogValueRow(key.label, viewModel.values[key] ?? "")
                            }
                        }

                        if (viewModel.loading) {
                            LoadingView()
                        } else if (!viewModel.online) {
                            OfflineView()
                        }
                    }.fixedSize(horizontal: false, vertical: true)
                    
                    if (viewModel.showLifespanSettingsButton) {
                        Button(action: viewModel.onLifespanSettingsButton, label: {
                            Text(Strings.State.lightsourceSettings)
                                .fontLabelSmall()
                                .foregroundColor(.Supla.primary)
                                .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                        })
                        
                        SuplaCore.Dialog.Divider()
                            .padding([.top], Distance.tiny)
                    } else {
                        SuplaCore.Dialog.Divider()
                            .padding([.top], Distance.default)
                    }

                    Buttons(
                        showArrows: viewModel.showArrows,
                        onDismiss: viewModel.onDismiss,
                        onPrevious: viewModel.onPrevious,
                        onNext: viewModel.onNext
                    )
                }
            }
        }
    }
}

private struct StateDialogHeader: SwiftUI.View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, _ subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some SwiftUI.View {
        VStack(spacing: 0) {
            Text(title)
                .fontHeadlineSmall()
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], Distance.default)
                .padding([.top], Distance.small)

            if let subtitle {
                Text(subtitle)
                    .fontLabelSmall()
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Distance.default)
            }
            
            SuplaCore.Dialog.Divider()
                .padding(.top, Distance.small)
        }
        .padding([.bottom], Distance.default)
    }
}

private struct StateDialogValueRow: SwiftUI.View {
    let label: String
    let value: String
    
    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some SwiftUI.View {
        HStack(alignment: .top, spacing: 1) {
            Text(label)
                .fontBodySmall()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, Distance.small)
                .padding(.trailing, 4)
                .background(Color.Supla.surface)
            Text(value)
                .font(.Supla.bodySmall.bold())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.trailing, Distance.small)
                .background(Color.Supla.surface)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.Supla.grayLight)
    }
}

private struct LoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Supla.surface)
    }
}

private struct OfflineView: View {
    var body: some View {
        HStack {
            Image(.Icons.offline)
                .resizable()
                .renderingMode(.template)
                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                .foregroundColor(.Supla.gray)
            Text("offline")
                .fontBodyMedium()
                .textColor(.Supla.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.Supla.surface)
    }
}

private struct Buttons: View {
    let showArrows: Bool
    
    let onDismiss: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            if (showArrows) {
                IconButton(name: .Icons.arrowLeft, action: onPrevious)
                    .buttonStyle(BorderedIconStyle())
            }
            Spacer()
            Button(action: onDismiss, label: {
                Text(Strings.General.close)
                    .font(.Supla.labelLarge)
                    .frame(height: 32)
            })
            .buttonStyle(BorderedButtonStyle())
            Spacer()
            if (showArrows) {
                IconButton(name: .Icons.arrowRight, action: onNext)
                    .buttonStyle(BorderedIconStyle())
            }
        }
        .padding([.top, .bottom], Distance.small)
        .padding([.leading, .trailing], Distance.small)
    }
}

#Preview {
    StateDialogFeature.Dialog(
        viewModel: StateDialogFeature.ViewModel(
            title: "Thermostat",
            function: "Thermostat",
            values: [
                .channelId: "1234567",
                .ipAddress: "192.168.100.2",
                .macAddress: "00:0a:95:9d:68:16"
            ],
            online: true
        )
    )
}

#Preview("Loading") {
    StateDialogFeature.Dialog(
        viewModel: StateDialogFeature.ViewModel(
            title: "Thermostat",
            function: "Thermostat",
            values: [
                .channelId: "1234567",
                .ipAddress: "192.168.100.2",
                .macAddress: "00:0a:95:9d:68:16"
            ],
            online: true,
            loading: true
        )
    )
}

#Preview("Multiple channels") {
    StateDialogFeature.Dialog(
        viewModel: StateDialogFeature.ViewModel(
            title: "Thermostat",
            function: "Thermostat",
            values: [
                .channelId: "1234567",
                .ipAddress: "192.168.100.2",
                .macAddress: "00:0a:95:9d:68:16"
            ],
            showArrows: true,
            online: true
        )
    )
}

#Preview("Offline") {
    StateDialogFeature.Dialog(
        viewModel: StateDialogFeature.ViewModel(
            title: "Thermostat",
            function: "Thermostat",
            values: [
                .channelId: "1234567",
                .ipAddress: "192.168.100.2",
                .macAddress: "00:0a:95:9d:68:16"
            ],
            showArrows: true
        )
    )
}

