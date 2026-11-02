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

final class SwapChannelPositionsUseCaseTests: UseCaseTest<Void> {
    private lazy var useCase: SwapChannelPositionsUseCase! = SwapChannelPositionsUseCaseImpl()
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()

    override func setUp() {
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
    }

    override func tearDown() {
        useCase = nil
        channelRepository = nil
        super.tearDown()
    }

    func test_shouldReorderAllChannelsInMergedLocationSection() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            channel(remoteId: 22, locationId: 2),
            channel(remoteId: 11, locationId: 1),
            channel(remoteId: 33, locationId: 2),
            location(remoteId: 3, caption: "Office"),
            channel(remoteId: 44, locationId: 3)
        ]
        channelRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.first?.0, [2, 1])
        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.first?.1, [22, 11, 33])
    }

    func test_shouldNotIncludeSeparateSectionWithTheSameLocationCaption() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            channel(remoteId: 11, locationId: 1),
            location(remoteId: 2, caption: "Kitchen"),
            channel(remoteId: 22, locationId: 2)
        ]
        channelRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.first?.0, [1])
        XCTAssertEqual(channelRepository.updatePositionsMock.parameters.first?.1, [11])
    }

    func test_shouldNotReorderWhenLocationHeaderIsMissing() {
        let items = [channel(remoteId: 11, locationId: 1)]

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        channelRepository.updatePositionsMock.verifyCalls(0)
    }

    private func location(remoteId: Int32, caption: String) -> MainListItem {
        .location(LocationListItem(remoteId: remoteId, profileId: 1, userCaption: caption, collapsed: false))
    }

    private func channel(remoteId: Int32, locationId: Int32) -> MainListItem {
        .default(
            DefaultListItem(
                remoteId: remoteId,
                profileId: 1,
                userCaption: "Channel \(remoteId)",
                function: SuplaFunction.companion.from(value: SUPLA_CHANNELFNC_LIGHTSWITCH),
                locationCaption: "Kitchen",
                locationId: locationId,
                status: .channel(.online),
                title: "Channel \(remoteId)",
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }
}
