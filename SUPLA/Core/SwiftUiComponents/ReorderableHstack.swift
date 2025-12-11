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

struct ReorderableHStack<
    Item: Identifiable & Equatable,
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

    @ViewBuilder let placeholder: (_ isDragging: Bool, _ isOver: Bool) -> PlaceholderView
    @ViewBuilder let itemView: (Item) -> ItemView

    @State private var draggingItem: Item? = nil
    @State private var hasReorderedDuringDrag: Bool = false
    @State private var isOverPlaceholder: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                placeholder(draggingItem != nil, isOverPlaceholder)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard enabled, draggingItem == nil else { return }
                        onPlaceholderTap()
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: PlaceholderDropDelegate(
                            items: $items,
                            draggingItem: $draggingItem,
                            isOver: $isOverPlaceholder,
                            onDelete: onDelete,
                            onReorderEnd: onReorderEnd
                        )
                    )
                    .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isOverPlaceholder)

                ForEach(items) { item in
                    itemView(item)
                        .onTapGesture {
                            guard draggingItem == nil else { return }
                            onItemTap(item)
                        }
                        .onDrag {
                            draggingItem = item
                            hasReorderedDuringDrag = false
                            isOverPlaceholder = false
                            let provider = ItemProvider(object: String(describing: item.id) as NSString)
                            provider.didEnd = {
                                Task {
                                    try? await Task.sleep(nanoseconds: 100_000_000)
                                    self.draggingItem = nil
                                }
                            }
                            return provider
                        }
                        .onDrop(
                            of: [UTType.text],
                            delegate: ReorderDropDelegate(
                                item: item,
                                items: $items,
                                draggingItem: $draggingItem,
                                hasReorderedDuringDrag: $hasReorderedDuringDrag,
                                onReorderEnd: onReorderEnd
                            )
                        )
                }
            }
        }
        .onChange(of: draggingItem) { newValue in
            if newValue == nil, hasReorderedDuringDrag {
                onReorderEnd(items)
                hasReorderedDuringDrag = false
            }
        }
    }
}

private class ItemProvider: NSItemProvider {
    var didEnd: (() -> Void)?
    deinit {
        didEnd?()
    }
}

// MARK: - Reorder delegate

private struct ReorderDropDelegate<Item: Identifiable & Equatable>: DropDelegate {
    let item: Item
    @Binding var items: [Item]
    @Binding var draggingItem: Item?
    @Binding var hasReorderedDuringDrag: Bool
    let onReorderEnd: ([Item]) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggingItem,
              draggingItem != item,
              let fromIndex = items.firstIndex(of: draggingItem),
              let toIndex = items.firstIndex(of: item)
        else { return }

        hasReorderedDuringDrag = true

        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            items.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        onReorderEnd(items)
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// MARK: - Placeholder delegate (delete target)

private struct PlaceholderDropDelegate<Item: Identifiable & Equatable>: DropDelegate {
    @Binding var items: [Item]
    @Binding var draggingItem: Item?
    @Binding var isOver: Bool

    let onDelete: (Item) -> Void
    let onReorderEnd: ([Item]) -> Void

    func dropEntered(info: DropInfo) { isOver = true }
    func dropExited(info: DropInfo) { isOver = false }

    func performDrop(info: DropInfo) -> Bool {
        isOver = false

        if let draggingItem,
           let idx = items.firstIndex(of: draggingItem)
        {
            onDelete(items[idx])
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct PreviewItem: Identifiable, Equatable {
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
            placeholder: { _, _ in
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
