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

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

final class DeleteAllProfileDataUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: DeleteAllProfileDataUseCase! = { DeleteAllProfileDataUseCaseImpl() }()
    
    private lazy var channelExtendedValueRepository: ChannelExtendedValueRepositorMock! = {
        ChannelExtendedValueRepositorMock()
    }()
    private lazy var channelValueRepository: ChannelValueRepositoryMock! = {
        ChannelValueRepositoryMock()
    }()
    private lazy var channelRepository: ChannelRepositoryMock! = {
        ChannelRepositoryMock()
    }()
    private lazy var groupRepository: GroupRepositoryMock! = {
        GroupRepositoryMock()
    }()
    private lazy var electricityMeasurementItemRepository: ElectricityMeasurementItemRepositoryMock! = {
        ElectricityMeasurementItemRepositoryMock()
    }()
    private lazy var impulseCounterMeasurementItemRepository: ImpulseCounterMeasurementItemRepositoryMock! = {
        ImpulseCounterMeasurementItemRepositoryMock()
    }()
    private lazy var locationRepository: LocationRepositoryMock! = {
        LocationRepositoryMock()
    }()
    private lazy var sceneRepository: SceneRepositoryMock! = {
        SceneRepositoryMock()
    }()
    private lazy var temperatureMeasurementItemRepository: TemperatureMeasurementItemRepositoryMock! = {
        TemperatureMeasurementItemRepositoryMock()
    }()
    private lazy var tempHumidityMeasurementItemRepository: TempHumidityMeasurementItemRepositoryMock! = {
        TempHumidityMeasurementItemRepositoryMock()
    }()
    private lazy var userIconRepository: UserIconRepositoryMock! = {
        UserIconRepositoryMock()
    }()
    private lazy var thermostatMeasurementItemRepository: ThermostatMeasurementItemRepositoryMock! = {
        ThermostatMeasurementItemRepositoryMock()
    }()
    
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
        
        super.tearDown()
    }
    
    func test() {
        // given
        let profile = AuthProfileItem(testContext: nil)
        channelExtendedValueRepository.deleteAllObservable = Observable.just(())
        channelValueRepository.deleteAllObservable = Observable.just(())
        channelRepository.deleteAllObservable = Observable.just(())
        groupRepository.deleteAllObservable = Observable.just(())
        electricityMeasurementItemRepository.deleteAllObservable = Observable.just(())
        impulseCounterMeasurementItemRepository.deleteAllObservable = Observable.just(())
        locationRepository.deleteAllObservable = Observable.just(())
        sceneRepository.deleteAllObservable = Observable.just(())
        temperatureMeasurementItemRepository.deleteAllObservable = Observable.just(())
        tempHumidityMeasurementItemRepository.deleteAllObservable = Observable.just(())
        userIconRepository.deleteAllObservable = Observable.just(())
        thermostatMeasurementItemRepository.deleteAllObservable = Observable.just(())
        
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
        XCTAssertEqual(temperatureMeasurementItemRepository.deleteAllCounter, 1)
        XCTAssertEqual(tempHumidityMeasurementItemRepository.deleteAllCounter, 1)
        XCTAssertEqual(userIconRepository.deleteAllCounter, 1)
        XCTAssertEqual(thermostatMeasurementItemRepository.deleteAllCounter, 1)
        
    }
}
