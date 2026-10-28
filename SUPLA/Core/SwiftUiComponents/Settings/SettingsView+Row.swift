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

extension SettingsView {
    struct Row<Content: View>: SwiftUI.View {
        let content: () -> Content

        @Environment(\.settingsBlockShowsDivider) private var showDivider

        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }

        var body: some View {
            HStack(alignment: .center) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Distance.small)
            .padding(.vertical, 4)
            .overlay(alignment: .bottom) {
                if showDivider {
                    Rectangle()
                        .fill(Color.Supla.background)
                        .frame(height: 1.5)
                        .padding(.leading, Distance.small)
                }
            }
        }
    }

    struct VerticalRow<Content: View>: SwiftUI.View {
        let alignment: HorizontalAlignment
        let spacing: CGFloat
        let content: () -> Content

        @Environment(\.settingsBlockShowsDivider) private var showDivider

        init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }

        var body: some View {
            VStack(alignment: alignment, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Distance.small)
            .padding(.vertical, 4)
            .overlay(alignment: .bottom) {
                if showDivider {
                    Rectangle()
                        .fill(Color.Supla.background)
                        .frame(height: 1.5)
                        .padding(.leading, Distance.small)
                }
            }
        }
    }
}

#Preview {
    BackgroundStack(alignment: .top) {
        SettingsView.Block {
            SettingsView.Row {
                SettingsView.Label("Temperature unit")
                Spacer()
                SettingsView.Description("°C")
            }
            SettingsView.VerticalRow(spacing: Distance.tiny) {
                SettingsView.Label("Channel height")
                SettingsView.Description("Standard")
            }
        }
    }
}
