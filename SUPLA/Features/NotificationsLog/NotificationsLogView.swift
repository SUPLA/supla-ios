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

extension NotificationsLogFeature {
    protocol ViewDelegate {
        func delete(notification: NotificationDto)
        func deleteAll()
        func deleteOlderThanMonth()
        func hideDeleteDialog()
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        @Singleton<ValuesFormatter> private var formatter

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 1) {
                    SwiftUI.List {
                        ForEach(state.notifications) { item in
                            ItemRow(item)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(
                                        role: .destructive,
                                        action: { delegate?.delete(notification: item) },
                                        label: { Image(.Icons.delete) }
                                    )
                                }
                        }
                    }
                    .listStyle(.plain)
                }
                
                if (state.showDeleteDialog) {
                    DeleteDialog()
                }
            }
        }

        @ViewBuilder
        private func ItemRow(_ notification: NotificationDto) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    Spacer()
                    if let profile = notification.profile {
                        Text(Strings.Notifications.profile)
                            .fontBodySmallSemiBold()
                        Text(profile)
                            .fontBodySmall()
                            .padding(.trailing, Distance.tiny)
                    }
                    if let date = formatter.getFullDateString(date: notification.date) {
                        Text(Strings.Notifications.date)
                            .fontBodySmallSemiBold()
                        Text(date)
                            .fontBodySmall()
                    }
                }
                .padding(Distance.tiny)
                if let title = notification.title, !title.isEmpty {
                    Text(title)
                        .fontHeadlineSmall()
                        .padding([.leading, .trailing], Distance.default)
                        .padding(.bottom, Distance.tiny)
                }
                if let message = notification.message, !message.isEmpty {
                    Text(message)
                        .fontBodyMedium()
                        .padding([.leading, .trailing], Distance.default)
                        .padding(.bottom, Distance.tiny)
                }
            }
            .padding(.bottom, Distance.tiny)
            .background(Color.Supla.surface)
            .padding(.bottom, 1)
            .background(Color.Supla.background)
        }
        
        @ViewBuilder
        private func DeleteDialog() -> some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: { delegate?.hideDeleteDialog() }) {
                SuplaCore.Dialog.Header(title: Strings.Notifications.deleteAllTitile)
                    
                SwiftUI.Text(Strings.Notifications.deleteAllMessage)
                    .fontBodyMedium()
                    .textColor(.Supla.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Distance.default)
                
                FilledButton(
                    buttonSpec: .critical(Strings.Notifications.buttonDeleteAll),
                    action: { delegate?.deleteAll() }
                )
                .padding([.leading, .top, .trailing], Distance.default)
                
                FilledButton(
                    buttonSpec: .critical(Strings.Notifications.buttonDeleteOlderThanMonth),
                    action: { delegate?.deleteOlderThanMonth() }
                )
                .padding([.leading, .trailing], Distance.default)
                .padding(.top, Distance.small)
                
                BorderedButton(
                    title: Strings.General.cancel,
                    fullWidth: true,
                    action: { delegate?.hideDeleteDialog() }
                )
                .padding([.leading, .trailing, .bottom], Distance.default)
                .padding(.top, Distance.small)
            }
        }
    }
}

#Preview {
    NotificationsLogFeature.View(
        state: NotificationsLogFeature.ViewState(
            notifications: [
                NotificationDto(
                    id: URL(fileURLWithPath: "1"),
                    title: "Light in living room",
                    message: "Light in living room turned on",
                    profile: "Default",
                    date: Date()
                ),
                NotificationDto(
                    id: URL(fileURLWithPath: "2"),
                    title: "Light in bedroom",
                    message: "Light in bedroom turned off",
                    profile: "Default",
                    date: Date()
                )
            ]
        ),
        delegate: nil
    )
}

#Preview("Deletion") {
    NotificationsLogFeature.View(
        state: NotificationsLogFeature.ViewState(
            notifications: [],
            showDeleteDialog: true
        ),
        delegate: nil
    )
}

