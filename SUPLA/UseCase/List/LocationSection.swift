/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import Foundation

struct LocationSection<Item> {
    let items: [Item]
}

extension Array {
    func toLocationSections(
        locationOf: (Element) -> _SALocation?,
        positionOf: (Element) -> Int32
    ) -> [LocationSection<Element>] {
        typealias IndexedItem = (offset: Int, item: Element)
        typealias LocationBucket = (location: _SALocation, items: [IndexedItem])

        var buckets: [LocationBucket] = []

        for (offset, item) in enumerated() {
            guard let location = locationOf(item) else { continue }
            let indexedItem = (offset: offset, item: item)

            if let lastIndex = buckets.indices.last,
               buckets[lastIndex].location.location_id == location.location_id
            {
                buckets[lastIndex].items.append(indexedItem)
            } else {
                buckets.append((location: location, items: [indexedItem]))
            }
        }

        guard let firstBucket = buckets.first else { return [] }

        var sections: [LocationSection<Element>] = []
        var previousLocation = firstBucket.location
        var sectionItems = firstBucket.items

        for bucket in buckets.dropFirst() {
            if previousLocation.caption == bucket.location.caption {
                sectionItems.append(contentsOf: bucket.items)
            } else {
                sections.append(section(from: sectionItems, positionOf: positionOf))
                sectionItems = bucket.items
            }

            previousLocation = bucket.location
        }

        sections.append(section(from: sectionItems, positionOf: positionOf))
        return sections
    }

    private func section(
        from indexedItems: [(offset: Int, item: Element)],
        positionOf: (Element) -> Int32
    ) -> LocationSection<Element> {
        LocationSection(
            items: indexedItems
                .sorted { lhs, rhs in
                    let lhsPosition = positionOf(lhs.item)
                    let rhsPosition = positionOf(rhs.item)
                    return lhsPosition == rhsPosition
                        ? lhs.offset < rhs.offset
                        : lhsPosition < rhsPosition
                }
                .map(\.item)
        )
    }
}
