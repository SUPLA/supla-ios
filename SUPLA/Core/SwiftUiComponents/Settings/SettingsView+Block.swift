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

private struct SettingsBlockShowsDividerKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var settingsBlockShowsDivider: Bool {
        get { self[SettingsBlockShowsDividerKey.self] }
        set { self[SettingsBlockShowsDividerKey.self] = newValue }
    }
}

@resultBuilder
enum SettingsBlockContentBuilder {
    static func buildExpression<Content: View>(_ expression: Content) -> [AnyView] {
        [AnyView(expression)]
    }

    static func buildBlock(_ components: [AnyView]...) -> [AnyView] {
        components.flatMap { $0 }
    }

    static func buildOptional(_ component: [AnyView]?) -> [AnyView] {
        component ?? []
    }

    static func buildEither(first component: [AnyView]) -> [AnyView] {
        component
    }

    static func buildEither(second component: [AnyView]) -> [AnyView] {
        component
    }

    static func buildArray(_ components: [[AnyView]]) -> [AnyView] {
        components.flatMap { $0 }
    }
}

extension SettingsView {
    struct Block: SwiftUI.View {
        let content: () -> [AnyView]
        private let appliesDividerContext: Bool

        init(@SettingsBlockContentBuilder content: @escaping () -> [AnyView]) {
            self.content = content
            self.appliesDividerContext = true
        }

        init<Item, Content: View>(
            items: [Item],
            @ViewBuilder content: @escaping (Item) -> Content
        ) {
            self.content = {
                items.enumerated().map { index, item in
                    AnyView(
                        content(item)
                            .environment(\.settingsBlockShowsDivider, index < items.count - 1)
                    )
                }
            }
            self.appliesDividerContext = false
        }

        var body: some View {
            VStack(spacing: 0) {
                let items = content()
                ForEach(items.indices, id: \.self) { index in
                    if appliesDividerContext {
                        items[index]
                            .environment(\.settingsBlockShowsDivider, index < items.count - 1)
                    } else {
                        items[index]
                    }
                }
            }
            .settingsSurface()
        }
    }
}
