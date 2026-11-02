/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 */

import RxSwift
import XCTest

@testable import SUPLA

final class SwapScenePositionsUseCaseTests: UseCaseTest<Void> {
    private lazy var useCase: SwapScenePositionsUseCase! = SwapScenePositionsUseCaseImpl()
    private lazy var sceneRepository: SceneRepositoryMock! = SceneRepositoryMock()

    override func setUp() {
        DiContainer.shared.register(type: (any SceneRepository).self, sceneRepository!)
    }

    override func tearDown() {
        useCase = nil
        sceneRepository = nil
        super.tearDown()
    }

    func test_shouldReorderAllScenesInMergedLocationSection() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            scene(remoteId: 22, locationId: 2),
            scene(remoteId: 11, locationId: 1),
            scene(remoteId: 33, locationId: 2),
            location(remoteId: 3, caption: "Office"),
            scene(remoteId: 44, locationId: 3)
        ]
        sceneRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.first?.0, [2, 1])
        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.first?.1, [22, 11, 33])
    }

    func test_shouldNotIncludeSeparateSectionWithTheSameLocationCaption() {
        let items = [
            location(remoteId: 1, caption: "Kitchen"),
            scene(remoteId: 11, locationId: 1),
            location(remoteId: 2, caption: "Kitchen"),
            scene(remoteId: 22, locationId: 2)
        ]
        sceneRepository.updatePositionsMock.returns = .single(.just(()))

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.count, 1)
        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.first?.0, [1])
        XCTAssertEqual(sceneRepository.updatePositionsMock.parameters.first?.1, [11])
    }

    func test_shouldNotReorderWhenLocationHeaderIsMissing() {
        let items = [scene(remoteId: 11, locationId: 1)]

        useCase.invoke(items: items, movedItemId: 11).subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events.count, 2)
        sceneRepository.updatePositionsMock.verifyCalls(0)
    }

    private func location(remoteId: Int32, caption: String) -> MainListItem {
        .location(LocationListItem(remoteId: remoteId, profileId: 1, userCaption: caption, collapsed: false))
    }

    private func scene(remoteId: Int32, locationId: Int) -> MainListItem {
        .scene(
            SceneListItem(
                remoteId: remoteId,
                profileId: 1,
                userCaption: "Scene \(remoteId)",
                locationCaption: "Kitchen",
                locationId: locationId,
                status: .scene,
                icon: .suplaIcon(name: ""),
                estimatedTimerEndDate: nil
            )
        )
    }
}
