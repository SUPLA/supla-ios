/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import XCTest

@testable import SUPLA

final class LocationSectionTests: XCTestCase {
    func test_shouldMergeAdjacentLocationsWithTheSameCaptionAndSortTheirItems() {
        let firstLocation = location(remoteId: 1, caption: "Home", sortOrder: 4)
        let secondLocation = location(remoteId: 2, caption: "Home", sortOrder: 6)
        let items = [
            Item(id: 1, position: 1, location: firstLocation),
            Item(id: 2, position: 3, location: firstLocation),
            Item(id: 3, position: 2, location: secondLocation)
        ]

        let sections = items.toLocationSections(
            locationOf: { $0.location },
            positionOf: { $0.position }
        )

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].items.map(\.id), [1, 3, 2])
    }

    func test_shouldNotMergeLocationsWithTheSameCaptionWhenTheyAreNotAdjacent() {
        let firstLocation = location(remoteId: 1, caption: "Home", sortOrder: 1)
        let middleLocation = location(remoteId: 2, caption: "Office", sortOrder: 2)
        let lastLocation = location(remoteId: 3, caption: "Home", sortOrder: 3)
        let items = [
            Item(id: 1, position: 1, location: firstLocation),
            Item(id: 2, position: 1, location: middleLocation),
            Item(id: 3, position: 1, location: lastLocation)
        ]

        let sections = items.toLocationSections(
            locationOf: { $0.location },
            positionOf: { $0.position }
        )

        XCTAssertEqual(sections.map { $0.items.map(\.id) }, [[1], [2], [3]])
    }

    func test_shouldPreserveInputOrderWhenPositionsAreEqual() {
        let firstLocation = location(remoteId: 1, caption: "Home", sortOrder: 1)
        let secondLocation = location(remoteId: 2, caption: "Home", sortOrder: 2)
        let items = [
            Item(id: 1, position: 0, location: firstLocation),
            Item(id: 2, position: 0, location: secondLocation)
        ]

        let sections = items.toLocationSections(
            locationOf: { $0.location },
            positionOf: { $0.position }
        )

        XCTAssertEqual(sections[0].items.map(\.id), [1, 2])
    }

    func test_shouldReturnEmptyListForEmptyInput() {
        let items: [Item] = []

        let sections = items.toLocationSections(
            locationOf: { $0.location },
            positionOf: { $0.position }
        )

        XCTAssertTrue(sections.isEmpty)
    }

    func test_shouldSkipItemsWithoutLocation() {
        let location = location(remoteId: 1, caption: "Home", sortOrder: 1)
        let items = [
            OptionalLocationItem(id: 1, position: 1, location: nil),
            OptionalLocationItem(id: 2, position: 2, location: location)
        ]

        let sections = items.toLocationSections(
            locationOf: { $0.location },
            positionOf: { $0.position }
        )

        XCTAssertEqual(sections.map { $0.items.map(\.id) }, [[2]])
    }

    private func location(remoteId: Int32, caption: String, sortOrder: Int32) -> _SALocation {
        let location = _SALocation(testContext: nil)
        location.location_id = NSNumber(value: remoteId)
        location.caption = caption
        location.sortOrder = NSNumber(value: sortOrder)
        return location
    }

    private struct Item {
        let id: Int
        let position: Int32
        let location: _SALocation
    }

    private struct OptionalLocationItem {
        let id: Int
        let position: Int32
        let location: _SALocation?
    }
}
