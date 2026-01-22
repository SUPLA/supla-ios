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
import UniformTypeIdentifiers

private let PLACEHOLDER_ID: Int = -1
private let SPACE_NAME = "ReorderableHStackSpace"

protocol ReorderableHStackItem: Identifiable, Equatable {
    var id: Int { get }
}

struct ReorderableHStack<
    Item: ReorderableHStackItem,
    ItemView: View,
    PlaceholderView: View
>: View {
    @Binding var items: [Item]

    var spacing: CGFloat = 0
    var enabled: Bool = true

    let onReorderEnd: ([Item]) -> Void
    let onPlaceholderTap: () -> Void
    let onDelete: (Item) -> Void
    let onItemTap: (Item) -> Void

    @ViewBuilder let placeholder: () -> PlaceholderView
    @ViewBuilder let itemView: (Item) -> ItemView

    var body: some View {
        HStack(spacing: spacing) {
            if (enabled) {
                placeholder()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard enabled else { return }
                        onPlaceholderTap()
                    }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(items) { item in
                        itemView(item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard enabled else { return }
                                onItemTap(item)
                            }
                            .contextMenu {
                                if (items.count > 1) {
                                    if (item != items.first) {
                                        if (items.count > 2) {
                                            contextButton(label: Strings.RgbDetail.moveStart, icon: String.Icons.arrowStart) { move(item, position: .start) }
                                        }
                                        contextButton(label: Strings.RgbDetail.moveLeft, icon: String.Icons.arrowLeft) { move(item, position: .left) }
                                    }
                                    if (item != items.last) {
                                        contextButton(label: Strings.RgbDetail.moveRight, icon: String.Icons.arrowRight) { move(item, position: .right) }
                                        if (items.count > 2) {
                                            contextButton(label: Strings.RgbDetail.moveEnd, icon: String.Icons.arrowEnd) { move(item, position: .end) }
                                        }
                                    }
                                }
                                contextButton(label: Strings.General.delete, icon: String.Icons.delete, role: .destructive) { onDelete(item) }
                            }
                    }
                }
            }
        }
    }

    private func move(_ item: Item, position: Position) {
        guard let fromIndex = items.firstIndex(of: item)
        else {
            return
        }

        let toIndex = switch (position) {
        case .left: fromIndex - 1
        case .right: fromIndex + 1
        case .start: 0
        case .end: items.count - 1
        }

        var itemsCopy = items
        itemsCopy.remove(at: fromIndex)
        itemsCopy.insert(item, at: toIndex)

        onReorderEnd(itemsCopy)
    }

    private enum Position {
        case left
        case right
        case start
        case end
    }

    @ViewBuilder
    private func contextButton(label: String, icon: String, role: ButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(
            role: role,
            action: action,
            label: {
                Label(
                    title: { Text(label).fontBodySmall() },
                    icon: { Image(icon).renderingMode(.template) }
                )
            }
        )
    }
}

private struct PreviewItem: ReorderableHStackItem {
    let id: Int
    var text: String
}

private struct DemoView: View {
    @State private var chips: [PreviewItem] = [
        .init(id: 1, text: "A"),
        .init(id: 2, text: "B"),
        .init(id: 3, text: "C")
    ]

    var body: some View {
        ReorderableHStack(
            items: $chips,
            onReorderEnd: { _ in
                SALog.debug("onReorderEnd")
            },
            onPlaceholderTap: {
                SALog.debug("onPlaceholderTap")
            },
            onDelete: { _ in
                SALog.debug("onDelete")
            },
            onItemTap: { _ in
                SALog.debug("onItemTap")
            },
            placeholder: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
            },
            itemView: { chip in
                Text(chip.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(.gray.opacity(0.4), lineWidth: 1)
                    )
            }
        )
        .padding()
    }
}

#Preview {
    DemoView()
}
