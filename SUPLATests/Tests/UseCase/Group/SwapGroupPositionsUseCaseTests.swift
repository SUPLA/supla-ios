/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import RxSwift
import SharedCore
import XCTest

@testable import SUPLA

final class SwapGroupPositionsUseCaseTests: UseCaseTest<Void> {
    private lazy var useCase: SwapGroupPositionsUseCase! = SwapGroupPositionsUseCaseImpl()
    private lazy var groupRepository: GroupRepositoryMock! = GroupRepositoryMock()

    override func setUp() {
        DiContainer.shared.register(type: (any GroupRepository).self, groupRepository!)
    }

    override func tearDown() {
        useCase = nil
        groupRepository = nil
        super.tearDown()
    }

    func test_shouldReorderAllGroupsInMergedLocationSection() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            group(remoteId: 22, locationId: 2),
            group(remoteId: 11, locationId: 1),
            group(remoteId: 33, locationId: 2),
            location(remoteId: 3, caption: "Office"),
            group(remoteId: 44, locationId: 3)
        ]
        groupRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.first?.0, [2, 1])
        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.first?.1, [22, 11, 33])
    }

    func test_shouldNotIncludeSeparateSectionWithTheSameLocationCaption() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            group(remoteId: 11, locationId: 1),
            location(remoteId: 2, caption: "Kitchen"),
            group(remoteId: 22, locationId: 2)
        ]
        groupRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.first?.0, [1])
        XCTAssertEqual(groupRepository.updatePositionsMock.parameters.first?.1, [11])
    }

    func test_shouldNotReorderWhenLocationHeaderIsMissing() {
        let items = [group(remoteId: 11, locationId: 1)]

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        groupRepository.updatePositionsMock.verifyCalls(0)
    }

    private func location(remoteId: Int32, caption: String) -> MainListItem {
        .location(LocationListItem(remoteId: remoteId, profileId: 1, userCaption: caption, collapsed: false))
    }

    private func group(remoteId: Int32, locationId: Int32) -> MainListItem {
        .default(
            DefaultListItem(
                remoteId: remoteId,
                profileId: 1,
                userCaption: "Group \(remoteId)",
                function: SuplaFunction.companion.from(value: SUPLA_CHANNELFNC_LIGHTSWITCH),
                locationCaption: "Kitchen",
                locationId: locationId,
                status: .group(onlinePercentage: 1, activePercentage: 0),
                title: "Group \(remoteId)",
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }
}
