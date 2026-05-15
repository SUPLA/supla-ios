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
import XCTest

@testable import SUPLA

final class TriggerLogHistoryDownloadUseCaseTests: XCTestCase {
    private lazy var useCase: TriggerLogHistoryDownload.UseCase! = TriggerLogHistoryDownload.Implementation()

    private lazy var dateProvider: DateProviderMock! = DateProviderMock()
    private lazy var userStateHolder: UserStateHolderMock! = UserStateHolderMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()
    private lazy var downloadChannelMeasurementsUseCase: DownloadChannelMeasurementsUseCaseMock! = DownloadChannelMeasurementsUseCaseMock()
    private lazy var impulseCounterMeasurementItemRepository: ImpulseCounterMeasurementItemRepositoryMock! = ImpulseCounterMeasurementItemRepositoryMock()
    private lazy var electricityMeasurementItemRepository: ElectricityMeasurementItemRepositoryMock! = ElectricityMeasurementItemRepositoryMock()

    override func setUp() {
        super.setUp()

        DiContainer.shared.register(type: DateProvider.self, dateProvider!)
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
        DiContainer.shared.register(type: (any ProfileRepository).self, profileRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: DownloadChannelMeasurementsUseCase.self, downloadChannelMeasurementsUseCase!)
        DiContainer.shared.register(type: (any ImpulseCounterMeasurementItemRepository).self, impulseCounterMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ElectricityMeasurementItemRepository).self, electricityMeasurementItemRepository!)
    }

    override func tearDown() {
        useCase = nil

        dateProvider = nil
        userStateHolder = nil
        profileRepository = nil
        channelRepository = nil
        downloadChannelMeasurementsUseCase = nil
        impulseCounterMeasurementItemRepository = nil
        electricityMeasurementItemRepository = nil

        super.tearDown()
    }

    func test_shouldReturnWithoutActiveProfile() async {
        // given
        profileRepository.activeProfileObservable = .empty()

        // when
        await useCase.invoke()

        // then
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.count, 0)
        XCTAssertEqual(userStateHolder.getImpulseCounterSettingsMock.parameters.count, 0)
        XCTAssertEqual(impulseCounterMeasurementItemRepository.findOldestEntityMock.parameters.count, 0)
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.count, 0)
    }

    func test_shouldSkipChannelsWithNoAggregation() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(profileId: profileId, serverId: serverId, remoteId: remoteId)

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings.defaultSettings())
        userStateHolder.impulseCounterSettingExistsMock.returns = .single(true)
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel))

        // when
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 8))
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(dateProvider.currentDateCalls, 0)
        XCTAssertEqual(impulseCounterMeasurementItemRepository.findOldestEntityMock.parameters.count, 0)
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.count, 0)
    }

    func test_shouldDownloadWhenEntriesAreMissingAndSkipRepeatedInvokeWithinLogsInterval() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let firstDate = Date(timeIntervalSince1970: 1_000_000)
        let secondDate = firstDate.addingTimeInterval(60)
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(profileId: profileId, serverId: serverId, remoteId: remoteId)

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings(showOnList: .currentDay))
        userStateHolder.impulseCounterSettingExistsMock.returns = .single(true)
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel, repeatedInvocations: 2))
        impulseCounterMeasurementItemRepository.findOldestEntityMock.returns = .single(.empty())
        dateProvider.currentDateReturns = firstDate

        // when
        await useCase.invoke()
        dateProvider.currentDateReturns = secondDate
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 16))
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertEqual(dateProvider.currentDateCalls, 2)
        XCTAssertTuples(impulseCounterMeasurementItemRepository.findOldestEntityMock.parameters, [
            (remoteId, serverId),
            (remoteId, serverId)
        ])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.map(\.remoteId), [remoteId])
    }

    func test_shouldDownloadWhenEntriesAreStaleAndSkipRepeatedInvokeWithinRefreshInterval() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let firstDate = Date(timeIntervalSince1970: 1_000_000)
        let secondDate = firstDate.addingTimeInterval(60)
        let staleMeasurement = makeImpulseCounterMeasurement(date: firstDate.addingTimeInterval(-3601))
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(
            profileId: profileId,
            serverId: serverId,
            remoteId: remoteId,
            flags: Int64(SUPLA_CHANNEL_FLAG_OCR)
        )

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.getImpulseCounterSettingsMock.returns = .single(ImpulseCounterSettings(showOnList: .currentDay))
        userStateHolder.impulseCounterSettingExistsMock.returns = .single(true)
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel, repeatedInvocations: 2))
        impulseCounterMeasurementItemRepository.findOldestEntityMock.returns = .single(.just(staleMeasurement))
        dateProvider.currentDateReturns = firstDate

        // when
        await useCase.invoke()
        dateProvider.currentDateReturns = secondDate
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 16))
        XCTAssertTuples(userStateHolder.getImpulseCounterSettingsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertEqual(dateProvider.currentDateCalls, 2)
        XCTAssertTuples(impulseCounterMeasurementItemRepository.findOldestEntityMock.parameters, [
            (remoteId, serverId),
            (remoteId, serverId)
        ])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.map(\.remoteId), [remoteId])
    }

    func test_shouldSkipElectricityMeterChannelsWithNoAggregation() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(
            profileId: profileId,
            serverId: serverId,
            remoteId: remoteId,
            function: SuplaFunction.electricityMeter.value
        )

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.electricityMeterSettingExistsMock.returns = .single(true)
        userStateHolder.getElectricityMeterSettingsMock.returns = .single(ElectricityMeterSettings.defaultSettings())
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel))

        // when
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 8))
        XCTAssertTuples(userStateHolder.electricityMeterSettingExistsMock.parameters, [(profileId, remoteId)])
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [(profileId, remoteId)])
        XCTAssertEqual(dateProvider.currentDateCalls, 0)
        XCTAssertEqual(electricityMeasurementItemRepository.findOldestEntityMock.parameters.count, 0)
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.count, 0)
    }

    func test_shouldDownloadElectricityMeterWhenEntriesAreMissingAndSkipRepeatedInvokeWithinLogsInterval() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let firstDate = Date(timeIntervalSince1970: 1_000_000)
        let secondDate = firstDate.addingTimeInterval(60)
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(
            profileId: profileId,
            serverId: serverId,
            remoteId: remoteId,
            function: SuplaFunction.electricityMeter.value
        )

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.electricityMeterSettingExistsMock.returns = .single(true)
        userStateHolder.getElectricityMeterSettingsMock.returns = .single(makeElectricityMeterSettings())
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel, repeatedInvocations: 2))
        electricityMeasurementItemRepository.findOldestEntityMock.returns = .single(.empty())
        dateProvider.currentDateReturns = firstDate

        // when
        await useCase.invoke()
        dateProvider.currentDateReturns = secondDate
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 16))
        XCTAssertTuples(userStateHolder.electricityMeterSettingExistsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertEqual(dateProvider.currentDateCalls, 2)
        XCTAssertTuples(electricityMeasurementItemRepository.findOldestEntityMock.parameters, [
            (remoteId, serverId),
            (remoteId, serverId)
        ])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.map(\.remoteId), [remoteId])
    }

    func test_shouldDownloadElectricityMeterWhenEntriesAreStaleAndSkipRepeatedInvokeWithinRefreshInterval() async {
        // given
        let profileId: Int32 = 11
        let remoteId: Int32 = 22
        let serverId: Int32 = 33
        let firstDate = Date(timeIntervalSince1970: 1_000_000)
        let secondDate = firstDate.addingTimeInterval(60)
        let staleMeasurement = makeElectricityMeterMeasurement(date: firstDate.addingTimeInterval(-3601))
        let profile = makeProfile(id: profileId)
        let channel = makeChannel(
            profileId: profileId,
            serverId: serverId,
            remoteId: remoteId,
            flags: Int64(SUPLA_CHANNEL_FLAG_OCR),
            function: SuplaFunction.electricityMeter.value
        )

        profileRepository.activeProfileObservable = .just(profile)
        userStateHolder.electricityMeterSettingExistsMock.returns = .single(true)
        userStateHolder.getElectricityMeterSettingsMock.returns = .single(makeElectricityMeterSettings())
        channelRepository.findChannelsByMock.returns = .many(makeChannelFetchReturns(channel: channel, repeatedInvocations: 2))
        electricityMeasurementItemRepository.findOldestEntityMock.returns = .single(.just(staleMeasurement))
        dateProvider.currentDateReturns = firstDate

        // when
        await useCase.invoke()
        dateProvider.currentDateReturns = secondDate
        await useCase.invoke()

        // then
        XCTAssertEqual(channelRepository.findChannelsByMock.parameters.map { $0.0 }, Array(repeating: profileId, count: 16))
        XCTAssertTuples(userStateHolder.electricityMeterSettingExistsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertTuples(userStateHolder.getElectricityMeterSettingsMock.parameters, [
            (profileId, remoteId),
            (profileId, remoteId)
        ])
        XCTAssertEqual(dateProvider.currentDateCalls, 2)
        XCTAssertTuples(electricityMeasurementItemRepository.findOldestEntityMock.parameters, [
            (remoteId, serverId),
            (remoteId, serverId)
        ])
        XCTAssertEqual(downloadChannelMeasurementsUseCase.parameters.map(\.remoteId), [remoteId])
    }

    private func makeProfile(id: Int32) -> AuthProfileItem {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = id
        return profile
    }

    private func makeChannel(profileId: Int32, serverId: Int32, remoteId: Int32, flags: Int64 = 0, function: Int32 = SuplaFunction.icHeatMeter.value) -> SAChannel {
        let channel = SAChannel.mock(remoteId)
        channel.profile.id = profileId
        channel.profile.server = SAProfileServer.mock(id: serverId)
        channel.flags = flags
        channel.func = function
        return channel
    }

    private func makeChannelFetchReturns(channel: SAChannel, repeatedInvocations: Int = 1) -> [[SAChannel]] {
        let singleRun: [[SAChannel]] = [[channel], [], [], [], [], [], []]
        return Array(repeating: singleRun, count: repeatedInvocations).flatMap { $0 }
    }

    private func makeImpulseCounterMeasurement(date: Date) -> SAImpulseCounterMeasurementItem {
        let measurement = SAImpulseCounterMeasurementItem(testContext: nil)
        measurement.date = date
        return measurement
    }
    
    private func makeElectricityMeterMeasurement(date: Date) -> SAElectricityMeasurementItem {
        let measurement = SAElectricityMeasurementItem(testContext: nil)
        measurement.date = date
        return measurement
    }

    private func makeElectricityMeterSettings() -> ElectricityMeterSettings {
        ElectricityMeterSettings(
            currentMonthBalancing: .defaultValue,
            metricOnList: .forwardActiveEnergy,
            metricOnListBalancing: .arithmetic,
            metricOnListAggregation: .currentDay
        )
    }
}
