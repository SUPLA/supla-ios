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

extension CarPlayListFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        var onNewItem: () -> Void
        var onPlayMessagesChange: (Bool) -> Void
        var onItemTapped: (NSManagedObjectID) -> Void
        var onMoved: (IndexSet, Int) -> Void

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                VStack(spacing: 1) {
                    if (BrandingConfiguration.CARPLAY_SUPPORT) {
                        HStack {
                            Toggle(isOn: $viewState.playMessages) {
                                Text(Strings.CarPlay.voiceMessages)
                                    .fontBodyMedium()
                            }
                            .onChange(of: viewState.playMessages) { onPlayMessagesChange($0) }
                        }
                        .padding([.leading, .trailing], Distance.default)
                        .padding([.top, .bottom], Distance.small)
                        .background(Color.Supla.surface)
                    }

                    if (viewState.items.isEmpty) {
                        Spacer()
                        EmptyListView()
                        Spacer()
                    } else {
                        SwiftUI.List {
                            ForEach(viewState.items) { item in
                                ItemRow(data: item)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .onTapGesture { onItemTapped(item.id) }
                            }
                            .onMove(perform: onMoved)
                        }
                        .listStyle(.plain)
                        .environment(\.editMode, Binding.constant(EditMode.active))
                    }
                }
            }
            .overlay(
                PlusButton(action: onNewItem),
                alignment: .bottomTrailing
            )
        }
    }

    struct PlusButton: SwiftUI.View {
        var action: () -> Void

        var body: some SwiftUI.View {
            IconButton(
                name: .Icons.plus,
                color: .Supla.onPrimary,
                action: action
            )
            .buttonStyle(FilledIconStyle())
            .padding(Distance.default)
        }
    }

    struct ItemRow: SwiftUI.View {
        let data: ReadCarPlayItems.Item

        var body: some SwiftUI.View {
            HStack {
                ListItemIcon(iconResult: data.icon)
                VStack(alignment: .leading, spacing: 6) {
                    CellCaption(text: data.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let action = data.action {
                        Text(Strings.CarPlay.action.arguments(action.name))
                            .fontBodySmall()
                            .textColor(.Supla.onSurfaceVariant)
                    }
                }
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(Strings.Notifications.profile)
                            .fontBodySmall()
                            .textColor(.Supla.onSurfaceVariant)
                        Text(data.profileName)
                            .fontBodySmall()
                    }
                    Text(data.subjectType.name)
                        .fontBodySmall()
                        .textColor(.Supla.onSurfaceVariant)
                }
            }
            .padding([.leading], Distance.default)
            .padding([.trailing], Distance.default)
            .padding([.top, .bottom], Distance.small)
            .background(Color.Supla.surface)
            .padding(.bottom, 1)
            .background(Color.Supla.background)
        }
    }
}

#Preview("Filled") {
    let state = CarPlayListFeature.ViewState()
    state.items = [
        ReadCarPlayItems.Item(id: NSManagedObjectID(), subjectId: 123, subjectType: .channel, action: .open, icon: .suplaIcon(name: .Icons.fncGpm1), caption: "Humidity", profileName: "Default"),
        ReadCarPlayItems.Item(id: NSManagedObjectID(), subjectId: 123, subjectType: .channel, action: .open, icon: .suplaIcon(name: .Icons.fncGpm1), caption: "Humidity", profileName: "Default")
    ]
    return CarPlayListFeature.View(
        viewState: state,
        onNewItem: {},
        onPlayMessagesChange: { _ in },
        onItemTapped: { _ in },
        onMoved: { _, _ in }
    )
}

#Preview("Empty") {
    let state = CarPlayListFeature.ViewState()
    state.items = []
    return CarPlayListFeature.View(
        viewState: state,
        onNewItem: {},
        onPlayMessagesChange: { _ in },
        onItemTapped: { _ in },
        onMoved: { _, _ in }
    )
}
