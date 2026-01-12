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

    @ViewBuilder let placeholder: (_ isDragging: Bool, _ isOver: Bool) -> PlaceholderView
    @ViewBuilder let itemView: (Item) -> ItemView

    @State private var draggingId: Int? = nil
    @State private var pressingId: Int? = nil
    @State private var dragX: CGFloat = 0
    @State private var overItemId: Int? = nil

    @State private var itemCorrections: [Int: CGFloat] = [:]
    @State private var itemFrames: [Int: CGRect] = [:]

    var body: some View {
        HStack(spacing: spacing) {
            placeholder(draggingId != nil, overItemId == PLACEHOLDER_ID)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard enabled, draggingId == nil else { return }
                    onPlaceholderTap()
                }
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { itemFrames[PLACEHOLDER_ID] = geo.frame(in: .named(SPACE_NAME)) }
                    }
                )

            ForEach(items) { item in
                let isDragging = (draggingId == item.id)
                let isPressing = (pressingId == item.id)

                itemView(item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard draggingId == nil else { return }
                        onItemTap(item)
                    }
                    .onLongPressGesture(
                        minimumDuration: 0.15,
                        pressing: {
                            pressingId = $0 ? item.id : nil
                        },
                        perform: {}
                    )
                    .simultaneousGesture(enabled ? dragGesture(for: item) : nil)
                    .offset(x: isDragging ? dragX : itemCorrections[item.id] ?? 0, y: 0)
                    .zIndex(isDragging ? 1 : 0)
                    .opacity(isPressing || isDragging ? 0.8 : 1.0)
                    .scaleEffect(isPressing || isDragging ? 1.2 : 1)
                    .shadow(radius: isPressing || isDragging ? 8 : 0)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    itemFrames[item.id] = geo.frame(in: .named(SPACE_NAME))
                                }
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .coordinateSpace(name: SPACE_NAME)
        .onChange(of: items) { _ in
            dragX = 0
            for (id, _) in itemFrames {
                itemCorrections[id] = 0
            }
        }
    }

    private func dragGesture(for item: Item) -> some Gesture {
        DragGesture(coordinateSpace: .named(SPACE_NAME))
            .onChanged { value in
                if draggingId == nil {
                    draggingId = item.id
                }
                guard draggingId == item.id else { return }

                dragX = value.translation.width

                guard let draggingItemFrame = itemFrames[item.id] else { return }

                for (id, frame) in itemFrames {
                    if (value.location.x > frame.minX && value.location.x < frame.maxX) {
                        overItemId = id
                    }
                }

                guard let overItemId else { return }

                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    for (id, _) in itemFrames {
                        if (id < item.id && id >= overItemId) {
                            itemCorrections[id] = draggingItemFrame.width
                        } else if (id > item.id && id <= overItemId) {
                            itemCorrections[id] = -draggingItemFrame.width
                        } else {
                            itemCorrections[id] = 0
                        }
                    }
                }
            }
            .onEnded { _ in
                if (overItemId == PLACEHOLDER_ID) {
                    onDelete(item)
                    draggingId = nil
                    overItemId = nil

                    return
                }

                guard let fromIndex = items.firstIndex(of: item),
                      let overId = overItemId,
                      let toItem = items.first(where: { $0.id == overId }),
                      let toIndex = items.firstIndex(of: toItem)
                else {
                    draggingId = nil
                    overItemId = nil
                    return
                }

                var itemsCopy = items
                itemsCopy.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)

                onReorderEnd(itemsCopy)

                draggingId = nil
                overItemId = nil
            }
    }
}

private extension View {
    @ViewBuilder
    func compatibleScrollBounce(dragging: Bool) -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(dragging ? .basedOnSize : .always)
        } else if #available(iOS 16.0, *) {
            self.scrollDisabled(dragging ? true : false)
        } else {
            self
        }
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
