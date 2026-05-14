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

import RxSwift
import SharedCore
import XCTest

@testable import SUPLA

final class RefreshImpulseCounterAggregatedValueUseCaseTests: XCTestCase {
    private lazy var useCase: RefreshImpulseCounterAggregatedValue.UseCase! = RefreshImpulseCounterAggregatedValue.Implementation()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var userStateHolder: UserStateHolderMock! = UserStateHolderMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelValueRepository: ChannelValueRepositoryMock! = ChannelValueRepositoryMock()
    private lazy var channelExtendedValueRepository: ChannelExtendedValueRepositorMock! = ChannelExtendedValueRepositorMock()
    private lazy var impulseCounterMeasurementItemRepository: ImpulseCounterMeasurementItemRepositoryMock! = ImpulseCounterMeasurementItemRepositoryMock()

    override func setUp() {
        super.setUp()

        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelValueRepository).self, channelValueRepository!)
        DiContainer.shared.register(type: (any ChannelExtendedValueRepository).self, channelExtendedValueRepository!)
        DiContainer.shared.register(type: (any ImpulseCounterMeasurementItemRepository).self, impulseCounterMeasurementItemRepository!)
    }

    override func tearDown() {
        useCase = nil

        dateProvider = nil
        userStateHolder = nil
        profileRepository = nil
        channelValueRepository = nil
        channelExtendedValueRepository = nil
        impulseCounterMeasurementItemRepository = nil

        super.tearDown()
    }

    func test_shouldReturnEarlyWhenAggregationIsDisabled() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings.defaultSettings())

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [])
        XCTAssertEqual(dateProvider.currentDateCalls, 0)
        XCTAssertEqual(impulseCounterMeasurementItemRepository.findMeasurementsMock.parameters.count, 0)
        XCTAssertEqual(channelExtendedValueRepository.getChannelValueMock.parameters.count, 0)
        XCTAssertEqual(channelValueRepository.updateAggregatedValueMock.parameters.count, 0)
    }

    func test_shouldStoreNoValueWhenThereAreNoEntries() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)

        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings(showOnList: .currentDay))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate
        impulseCounterMeasurementItemRepository.findMeasurementsMock.returns = .single(.just([]))

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        XCTAssertTuples(impulseCounterMeasurementItemRepository.findMeasurementsMock.parameters, [
            (remoteId, serverId, currentDate.dayStart(), currentDate)
        ])
        XCTAssertEqual(channelExtendedValueRepository.getChannelValueMock.parameters.count, 0)
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (profileId, remoteId, SUPLA.NO_VALUE_TEXT)
        ])
    }

    func test_shouldRefreshAggregatedValue() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)

        let measurements = [
            measurement(1.5),
            measurement(2.5)
        ]

        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings(showOnList: .currentDay))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate
        impulseCounterMeasurementItemRepository.findMeasurementsMock.returns = .single(.just(measurements))
        channelExtendedValueRepository.getChannelValueMock.returns = .single(.just(makeImpulseCounterExtendedValue()))

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        XCTAssertTuples(impulseCounterMeasurementItemRepository.findMeasurementsMock.parameters, [
            (remoteId, serverId, currentDate.dayStart(), currentDate)
        ])
        XCTAssertTuples(channelExtendedValueRepository.getChannelValueMock.parameters, [(profile, remoteId)])
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (
                profileId,
                remoteId,
                "4.000 "
            )
        ])
    }

    private func measurement(_ calculatedValue: Double) -> SAImpulseCounterMeasurementItem {
        let measurement = SAImpulseCounterMeasurementItem(testContext: nil)
        measurement.calculated_value = calculatedValue
        return measurement
    }

    private func makeImpulseCounterExtendedValue() -> SAChannelExtendedValue {
        var impulseCounterValue = TSC_ImpulseCounter_ExtendedValue()
        impulseCounterValue.impulses_per_unit = 1
        impulseCounterValue.counter = 0
        impulseCounterValue.calculated_value = 0

        var suplaExtendedValue = TSuplaChannelExtendedValue()
        suplaExtendedValue.type = CChar(EV_TYPE_IMPULSE_COUNTER_DETAILS_V1)
        suplaExtendedValue.size = UInt32(MemoryLayout<TSC_ImpulseCounter_ExtendedValue>.size)
        _ = withUnsafeMutablePointer(to: &suplaExtendedValue.value) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<TSC_ImpulseCounter_ExtendedValue>.size) { ptr in
                memcpy(ptr, &impulseCounterValue, MemoryLayout<TSC_ImpulseCounter_ExtendedValue>.size)
            }
        }

        let extendedValue = SAChannelExtendedValue(testContext: nil)
        extendedValue.setValueSwift(suplaExtendedValue)
        return extendedValue
    }
}
