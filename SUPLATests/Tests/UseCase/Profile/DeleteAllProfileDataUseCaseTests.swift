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
import RxTest
import XCTest

@testable import SUPLA

final class DeleteAllProfileDataUseCaseTests: UseCaseTest<Void> {
    private lazy var useCase: DeleteAllProfileDataUseCase! = DeleteAllProfileDataUseCaseImpl()

    private lazy var channelExtendedValueRepository: ChannelExtendedValueRepositorMock! = ChannelExtendedValueRepositorMock()

    private lazy var channelValueRepository: ChannelValueRepositoryMock! = ChannelValueRepositoryMock()

    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()

    private lazy var groupRepository: GroupRepositoryMock! = GroupRepositoryMock()

    private lazy var electricityMeasurementItemRepository: ElectricityMeasurementItemRepositoryMock! = ElectricityMeasurementItemRepositoryMock()

    private lazy var impulseCounterMeasurementItemRepository: ImpulseCounterMeasurementItemRepositoryMock! = ImpulseCounterMeasurementItemRepositoryMock()

    private lazy var locationRepository: LocationRepositoryMock! = LocationRepositoryMock()

    private lazy var sceneRepository: SceneRepositoryMock! = SceneRepositoryMock()

    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = TemperatureMeasurementItemRepositoryMock()

    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = TempHumidityMeasurementItemRepositoryMock()

    private lazy var userIconRepository: UserIconRepositoryMock! = UserIconRepositoryMock()

    private lazy var thermostatMeasurementItemRepository: ThermostatMeasurementItemRepositoryMock! = ThermostatMeasurementItemRepositoryMock()

    private lazy var generalPurposeMeterItemRepository: GeneralPurposeMeterItemRepositoryMock! = GeneralPurposeMeterItemRepositoryMock()

    private lazy var generalPurposeMeasurementItemRepository: GeneralPurposeMeasurementItemRepositoryMock! = GeneralPurposeMeasurementItemRepositoryMock()

    private lazy var channelConfigRepository: ChannelConfigRepositoryMock! = ChannelConfigRepositoryMock()
    
    private lazy var channelStateRepository: ChannelStateRepositoryMock! = ChannelStateRepositoryMock()

    override func setUp() {
        DiContainer.shared.register(type: (any ChannelExtendedValueRepository).self, channelExtendedValueRepository!)
        DiContainer.shared.register(type: (any ChannelValueRepository).self, channelValueRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, channelRepository!)
        DiContainer.shared.register(type: (any GroupRepository).self, groupRepository!)
        DiContainer.shared.register(type: (any ElectricityMeasurementItemRepository).self, electricityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ImpulseCounterMeasurementItemRepository).self, impulseCounterMeasurementItemRepository!)
        DiContainer.shared.register(type: (any LocationRepository).self, locationRepository!)
        DiContainer.shared.register(type: (any SceneRepository).self, sceneRepository!)
        DiContainer.shared.register(type: (any TemperatureMeasurementItemRepository).self, temperatureMeasurementItemRepository!)
        DiContainer.shared.register(type: (any TempHumidityMeasurementItemRepository).self, tempHumidityMeasurementItemRepository!)
        DiContainer.shared.register(type: (any UserIconRepository).self, userIconRepository!)
        DiContainer.shared.register(type: (any ThermostatMeasurementItemRepository).self, thermostatMeasurementItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeterItemRepository).self, generalPurposeMeterItemRepository!)
        DiContainer.shared.register(type: (any GeneralPurposeMeasurementItemRepository).self, generalPurposeMeasurementItemRepository!)
        DiContainer.shared.register(type: (any ChannelConfigRepository).self, channelConfigRepository!)
        DiContainer.shared.register(type: (any ChannelStateRepository).self, channelStateRepository!)
    }

    override func tearDown() {
        useCase = nil

        channelExtendedValueRepository = nil
        channelValueRepository = nil
        channelRepository = nil
        groupRepository = nil
        electricityMeasurementItemRepository = nil
        impulseCounterMeasurementItemRepository = nil
        locationRepository = nil
        sceneRepository = nil
        temperatureMeasurementItemRepository = nil
        tempHumidityMeasurementItemRepository = nil
        userIconRepository = nil
        thermostatMeasurementItemRepository = nil
        generalPurposeMeterItemRepository = nil
        generalPurposeMeasurementItemRepository = nil
        channelConfigRepository = nil
        channelStateRepository = nil

        super.tearDown()
    }

    func test() {
        // given
        let serverId: Int32 = 2
        let profile = AuthProfileItem(testContext: nil)
        profile.server = SAProfileServer.mock(id: serverId)
        channelExtendedValueRepository.deleteAllObservable = .just(())
        channelValueRepository.deleteAllObservable = .just(())
        channelRepository.deleteAllObservable = .just(())
        groupRepository.deleteAllObservable = .just(())
        electricityMeasurementItemRepository.deleteAllObservable = .just(())
        impulseCounterMeasurementItemRepository.deleteAllObservable = .just(())
        locationRepository.deleteAllObservable = .just(())
        sceneRepository.deleteAllObservable = .just(())
        temperatureMeasurementItemRepository.deleteAllForProfileReturns = .just(())
        tempHumidityMeasurementItemRepository.deleteAllForProfileReturns = .just(())
        userIconRepository.deleteAllObservable = .just(())
        thermostatMeasurementItemRepository.deleteAllObservable = .just(())
        generalPurposeMeterItemRepository.deleteAllForProfileReturns = .just(())
        generalPurposeMeasurementItemRepository.deleteAllForProfileReturns = .just(())
        channelConfigRepository.deleteAllForProfileReturns = .just(())
        channelStateRepository.deleteAllMock.returns = .single(.just(()))

        // when
        useCase.invoke(profile: profile).subscribe(observer).disposed(by: disposeBag)

        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(channelExtendedValueRepository.deleteAllCounter, 1)
        XCTAssertEqual(channelValueRepository.deleteAllCounter, 1)
        XCTAssertEqual(channelRepository.deleteAllCounter, 1)
        XCTAssertEqual(groupRepository.deleteAllCounter, 1)
        XCTAssertEqual(electricityMeasurementItemRepository.deleteAllCounter, 1)
        XCTAssertEqual(impulseCounterMeasurementItemRepository.deleteAllCounter, 1)
        XCTAssertEqual(locationRepository.deleteAllCounter, 1)
        XCTAssertEqual(sceneRepository.deleteAllCounter, 1)
        XCTAssertEqual(temperatureMeasurementItemRepository.deleteAllForProfileParameters, [serverId])
        XCTAssertEqual(tempHumidityMeasurementItemRepository.deleteAllForProfileParameters, [serverId])
        XCTAssertEqual(userIconRepository.deleteAllCounter, 1)
        XCTAssertEqual(thermostatMeasurementItemRepository.deleteAllCounter, 1)
        XCTAssertEqual(generalPurposeMeterItemRepository.deleteAllForProfileParameters, [serverId])
        XCTAssertEqual(generalPurposeMeasurementItemRepository.deleteAllForProfileParameters, [serverId])
        XCTAssertEqual(channelConfigRepository.deleteAllForProfileParameters, [profile])
        XCTAssertEqual(channelStateRepository.deleteAllMock.parameters, [profile])
    }
}
