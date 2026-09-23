/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import XCTest
import SharedCore

@testable import SUPLA

final class MainListItemSectionTests: XCTestCase {
    func test_shouldReturnItemsFromMergedLocationSection() {
        let first = item(remoteId: 11, locationId: 1)
        let second = item(remoteId: 22, locationId: 2)
        let items = [location("Kitchen"), first, second, location("Office"), item(remoteId: 33, locationId: 3)]

        let sectionItems = items.reorderableSectionItems(movedItemId: 22, isItem: \.draggable)

        XCTAssertEqual(sectionItems, [first, second])
    }

    func test_shouldDistinguishSectionsWithTheSameCaption() {
        let first = item(remoteId: 11, locationId: 1)
        let second = item(remoteId: 22, locationId: 2)
        let items = [location("Kitchen"), first, location("Kitchen"), second]

        let sectionItems = items.reorderableSectionItems(movedItemId: 11, isItem: \.draggable)

        XCTAssertEqual(sectionItems, [first])
    }

    func test_shouldAllowMovingOnlyItemsUnderTheSameHeader() {
        let items = [
            location("Kitchen"),
            item(remoteId: 11, locationId: 1),
            item(remoteId: 22, locationId: 2),
            location("Kitchen"),
            item(remoteId: 33, locationId: 3)
        ]

        XCTAssertTrue(items.canMoveItemWithinSection(from: 1, to: 2, isItem: \.draggable))
        XCTAssertFalse(items.canMoveItemWithinSection(from: 1, to: 4, isItem: \.draggable))
        XCTAssertFalse(items.canMoveItemWithinSection(from: 1, to: 3, isItem: \.draggable))
    }

    func test_shouldRejectMovingWhenHeaderIsMissingOrIndexIsInvalid() {
        let items = [item(remoteId: 11, locationId: 1), item(remoteId: 22, locationId: 1)]

        XCTAssertFalse(items.canMoveItemWithinSection(from: 0, to: 1, isItem: \.draggable))
        XCTAssertFalse(items.canMoveItemWithinSection(from: 0, to: 2, isItem: \.draggable))
        XCTAssertNil(items.reorderableSectionItems(movedItemId: 11, isItem: \.draggable))
    }

    func test_shouldReturnNilWhenMovedItemIsMissing() {
        let items = [location("Kitchen"), item(remoteId: 11, locationId: 1)]

        XCTAssertNil(items.reorderableSectionItems(movedItemId: 22, isItem: \.draggable))
    }

    private func location(_ caption: String) -> MainListItem {
        .location(LocationListItem(remoteId: 1, profileId: 1, userCaption: caption, collapsed: false))
    }

    private func item(remoteId: Int32, locationId: Int32) -> MainListItem {
        .default(
            DefaultListItem(
                remoteId: remoteId,
                profileId: 1,
                userCaption: "Item \(remoteId)",
                function: SuplaFunction.companion.from(value: SUPLA_CHANNELFNC_LIGHTSWITCH),
                locationCaption: "Kitchen",
                locationId: locationId,
                status: .channel(.online),
                title: "Item \(remoteId)",
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }
}
