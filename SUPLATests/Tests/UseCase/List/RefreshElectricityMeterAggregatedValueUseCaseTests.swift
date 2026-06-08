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

final class RefreshElectricityMeterAggregatedValueUseCaseTests: XCTestCase {
    private lazy var useCase: RefreshElectricityMeterAggregatedValue.UseCase! = RefreshElectricityMeterAggregatedValue.Implementation()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var userStateHolder: UserStateHolderMock! = UserStateHolderMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelValueRepository: ChannelValueRepositoryMock! = ChannelValueRepositoryMock()
    private lazy var electricityMeasurementItemRepository: ElectricityMeasurementItemRepositoryMock! = ElectricityMeasurementItemRepositoryMock()
    private lazy var loadElectricityMeterMeasurementsUseCase: LoadElectricityMeterMeasurementsUseCaseMock! = LoadElectricityMeterMeasurementsUseCaseMock()

    override func setUp() {
        super.setUp()

        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelValueRepository).self, channelValueRepository!)
        DiContainer.shared.register(type: (any ElectricityMeasurementItemRepository).self, electricityMeasurementItemRepository!)
        DiContainer.shared.register(type: LoadElectricityMeterMeasurementsUseCase.self, loadElectricityMeterMeasurementsUseCase!)
    }

    override func tearDown() {
        useCase = nil

        dateProvider = nil
        userStateHolder = nil
        profileRepository = nil
        channelValueRepository = nil
        electricityMeasurementItemRepository = nil
        loadElectricityMeterMeasurementsUseCase = nil

        super.tearDown()
    }

    func test_shouldReturnEarlyWhenAggregationIsDisabled() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        userStateHolder.getElectricityMeterSettingsMock.returns = .single(.defaultSettings())

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [])
        XCTAssertEqual(dateProvider.currentDateCalls, 0)
        loadElectricityMeterMeasurementsUseCase.remoteIdMock.verifyCalls(0)
        loadElectricityMeterMeasurementsUseCase.profileMock.verifyCalls(0)
        electricityMeasurementItemRepository.findMeasurementsMock.verifyCalls(0)
        XCTAssertEqual(channelValueRepository.updateAggregatedValueMock.parameters.count, 0)
    }

    func test_shouldStoreNoValueWhenAggregationStartDateCannotBeDetermined() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = makeProfile(id: profileId, serverId: serverId)

        userStateHolder.getElectricityMeterSettingsMock.returns = .single(ElectricityMeterSettings(
            currentMonthBalancing: .defaultValue,
            metricOnList: .activeEnergyBalance,
            metricOnListBalancing: .arithmetic,
            metricOnListAggregation: .noAggregation
        ))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        loadElectricityMeterMeasurementsUseCase.remoteIdMock.verifyCalls(0)
        loadElectricityMeterMeasurementsUseCase.profileMock.verifyCalls(0)
        electricityMeasurementItemRepository.findMeasurementsMock.verifyCalls(0)
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (profileId, remoteId, SUPLA.NO_VALUE_TEXT)
        ])
    }

    func test_shouldRefreshForwardActiveEnergy() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = makeProfile(id: profileId, serverId: serverId)

        userStateHolder.getElectricityMeterSettingsMock.returns = .single(makeSettings(
            metricOnList: .forwardActiveEnergy,
            aggregation: .currentDay
        ))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate
        loadElectricityMeterMeasurementsUseCase.profileMock.returns = .single(.just(
            ElectricityMeasurements(forwardActiveEnergy: 6.5, reverseActiveEnergy: 1.25)
        ))

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        loadElectricityMeterMeasurementsUseCase.remoteIdMock.verifyCalls(0)
        XCTAssertTuples(loadElectricityMeterMeasurementsUseCase.profileMock.parameters, [
            (profileId, remoteId, currentDate.dayStart(), currentDate)
        ])
        electricityMeasurementItemRepository.findMeasurementsMock.verifyCalls(0)
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (
                profileId,
                remoteId,
                formattedElectricityValue(6.5, unit: ElectricityMeterMeasurementType.forwardActiveEnergy.suplaType.unit)
            )
        ])
    }

    func test_shouldRefreshActiveEnergyBalance() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = makeProfile(id: profileId, serverId: serverId)

        userStateHolder.getElectricityMeterSettingsMock.returns = .single(makeSettings(
            metricOnList: .activeEnergyBalance,
            aggregation: .currentDay
        ))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate
        loadElectricityMeterMeasurementsUseCase.profileMock.returns = .single(.just(
            ElectricityMeasurements(forwardActiveEnergy: 8.75, reverseActiveEnergy: 1.25)
        ))

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        loadElectricityMeterMeasurementsUseCase.remoteIdMock.verifyCalls(0)
        XCTAssertTuples(loadElectricityMeterMeasurementsUseCase.profileMock.parameters, [
            (profileId, remoteId, currentDate.dayStart(), currentDate)
        ])
        electricityMeasurementItemRepository.findMeasurementsMock.verifyCalls(0)
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (
                profileId,
                remoteId,
                formattedElectricityValue(7.5, unit: ElectricityMeterMeasurementType.activeEnergyBalance.suplaType.unit)
            )
        ])
    }

    func test_shouldRefreshForwardReactiveEnergy() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let currentDate = Date.create(year: 2026, month: 5, day: 14, hour: 12, minute: 34, second: 56)!
        let profile = makeProfile(id: profileId, serverId: serverId)

        userStateHolder.getElectricityMeterSettingsMock.returns = .single(makeSettings(
            metricOnList: .forwardReactiveEnergy,
            aggregation: .currentDay
        ))
        profileRepository.getProfileWithIdMock.returns = .single(.just(profile))
        dateProvider.currentDateReturns = currentDate
        electricityMeasurementItemRepository.findMeasurementsMock.returns = .single(.just([
            makeMeasurementItem(phase1Fre: 1, phase2Fre: 2, phase3Fre: 3),
            makeMeasurementItem(phase1Fre: 4, phase2Fre: 5, phase3Fre: 6)
        ]))

        // when
        await useCase.invoke(profileId: profileId, remoteId: remoteId)

        // then
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(profileRepository.getProfileWithIdMock.parameters, [profileId])
        XCTAssertEqual(dateProvider.currentDateCalls, 1)
        loadElectricityMeterMeasurementsUseCase.remoteIdMock.verifyCalls(0)
        loadElectricityMeterMeasurementsUseCase.profileMock.verifyCalls(0)
        XCTAssertTuples(electricityMeasurementItemRepository.findMeasurementsMock.parameters, [
            (remoteId, serverId, currentDate.dayStart(), currentDate)
        ])
        XCTAssertTuples(channelValueRepository.updateAggregatedValueMock.parameters, [
            (
                profileId,
                remoteId,
                formattedElectricityValue(21, unit: ElectricityMeterMeasurementType.forwardReactiveEnergy.suplaType.unit)
            )
        ])
    }

    private func makeProfile(id: Int32, serverId: Int32) -> AuthProfileItem {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = id
        profile.server = SAProfileServer.mock(id: serverId)
        return profile
    }

    private func makeSettings(
        metricOnList: ElectricityMeterMeasurementType,
        aggregation: ListValueAggregation
    ) -> ElectricityMeterSettings {
        ElectricityMeterSettings(
            currentMonthBalancing: .defaultValue,
            metricOnList: metricOnList,
            metricOnListBalancing: .arithmetic,
            metricOnListAggregation: aggregation
        )
    }

    private func makeMeasurementItem(phase1Fre: Double, phase2Fre: Double, phase3Fre: Double) -> SAElectricityMeasurementItem {
        let item = SAElectricityMeasurementItem(testContext: nil)
        item.phase1_fre = phase1Fre
        item.phase2_fre = phase2Fre
        item.phase3_fre = phase3Fre
        return item
    }

    private func formattedElectricityValue(_ value: Double, unit: String) -> String {
        ElectricityMeterValueFormatter().format(value: value, format: withUnit(unit: unit, showNoValueText: false))
    }
}
