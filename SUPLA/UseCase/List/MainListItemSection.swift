/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import Foundation

extension Array where Element == MainListItem {
    var distinctLocationIds: [Int32] {
        compactMap(\.locationId).reduce(into: []) { result, locationId in
            if !result.contains(locationId) {
                result.append(locationId)
            }
        }
    }

    func reorderableSectionItems(
        movedItemId: Int32,
        isItem: (MainListItem) -> Bool
    ) -> [MainListItem]? {
        guard let movedItemIndex = firstIndex(where: { isItem($0) && $0.remoteId == movedItemId }) else {
            return nil
        }
        guard let headerIndex = locationHeaderIndex(for: movedItemIndex) else { return nil }

        let endIndex = ((headerIndex + 1) ..< count)
            .first(where: { self[$0].isLocation }) ?? count

        return self[(headerIndex + 1) ..< endIndex].filter(isItem)
    }

    func canMoveItemWithinSection(
        from sourceIndex: Int,
        to destinationIndex: Int,
        isItem: (MainListItem) -> Bool
    ) -> Bool {
        guard
            indices.contains(sourceIndex),
            indices.contains(destinationIndex),
            isItem(self[sourceIndex]),
            isItem(self[destinationIndex])
        else {
            return false
        }

        guard let sourceHeaderIndex = locationHeaderIndex(for: sourceIndex) else { return false }
        return sourceHeaderIndex == locationHeaderIndex(for: destinationIndex)
    }

    private func locationHeaderIndex(for itemIndex: Int) -> Int? {
        stride(from: itemIndex, through: 0, by: -1)
            .first(where: { self[$0].isLocation })
    }
}

private extension MainListItem {
    var isLocation: Bool {
        if case .location = self { true } else { false }
    }
}
