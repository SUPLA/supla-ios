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

@testable import SUPLA
import XCTest

final class UpdateChannelGroupTotalValueUseCaseTests: UseCaseTest<[Int32]> {
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    
    private lazy var channelGroupRelationRepository: ChannelGroupRelationRepositoryMock! = ChannelGroupRelationRepositoryMock()
    
    private lazy var useCase: UpdateChannelGroupTotalValueUseCase! = UpdateChannelGroupTotalValueUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.register((any ProfileRepository).self, profileRepository!)
        DiContainer.register((any ChannelGroupRelationRepository).self, channelGroupRelationRepository!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        profileRepository = nil
        channelGroupRelationRepository = nil
        useCase = nil
    }
    
    func testIfTotalStringIsCreated() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
        
        let secondGroup = SAChannelGroup(testContext: nil)
        secondGroup.remote_id = 22
        secondGroup.func = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        
        let thirdGroup = SAChannelGroup(testContext: nil)
        thirdGroup.remote_id = 33
        thirdGroup.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
        thirdGroup.online = 100
        thirdGroup.total_value = GroupTotalValue(values: [RollerShutterGroupValue(position: 10, closedSensorActive: false)])
        
        let firstGroupRelation1 = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation1.group = firstGroup
        firstGroupRelation1.value = SAChannelValue.mockRollerShutter(position: 18)
        
        let firstGroupRelation2 = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation2.group = firstGroup
        firstGroupRelation2.value = SAChannelValue.mockRollerShutter(position: 25)
        
        let firstGroupRelationOffline = SAChannelGroupRelation(testContext: nil)
        firstGroupRelationOffline.group = firstGroup
        firstGroupRelationOffline.value = SAChannelValue.mockRollerShutter(online: false, position: 25)
        
        let secondGroupRelation = SAChannelGroupRelation(testContext: nil)
        secondGroupRelation.group = secondGroup
        secondGroupRelation.value = SAChannelValue.mockFacadeBlind(position: 10, tilt: 20)
        
        let thirdGroupRelation = SAChannelGroupRelation(testContext: nil)
        thirdGroupRelation.group = thirdGroup
        thirdGroupRelation.value = SAChannelValue.mockRollerShutter(position: 10)
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([
            firstGroupRelation1,
            firstGroupRelation2,
            firstGroupRelationOffline,
            secondGroupRelation,
            thirdGroupRelation
        ])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 66)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? RollerShutterGroupValue,
           let secondRelationValue = groupTotalValue.values[1] as? RollerShutterGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 2)
            XCTAssertEqual(firstRelationValue.position, 18)
            XCTAssertEqual(secondRelationValue.position, 25)
        } else {
            XCTFail("First group total value not created!")
        }
        
        XCTAssertEqual(secondGroup.online, 100)
        XCTAssertTrue(secondGroup.total_value is GroupTotalValue)
        if let groupTotalValue = secondGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? FacadeBlindGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.position, 10)
            XCTAssertEqual(firstRelationValue.tilt, 20)
        } else {
            XCTFail("First group total value not created!")
        }
        assertEvents([
            .next([11, 22]), // in third group there are no changes so it should not be present here.
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForGate() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.sub_value = NSData(data: Data([1,0,0,0,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? BoolGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.value, true)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForPowerSwitch() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_POWERSWITCH
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([1,0,0,0,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? BoolGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.value, true)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForValvePercentage() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_VALVE_PERCENTAGE
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([12,0,0,0,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? IntegerGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.value, 12)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForDimmer() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_DIMMER
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([15,0,0,0,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? IntegerGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.value, 15)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForRgbLighting() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_RGBLIGHTING
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([0,15,81,209,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? RgbLightingGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.color, UIColor.primaryVariant)
            XCTAssertEqual(firstRelationValue.brightness, 15)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForDimmerAndRgbLighting() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([22,15,81,209,0,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? DimmerAndRgbLightingGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.color, UIColor.primaryVariant)
            XCTAssertEqual(firstRelationValue.brightness, 22)
            XCTAssertEqual(firstRelationValue.colorBrightness, 15)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
    
    func testIfTotalStringIsCreatedForHeatpolThermostat() {
        // given
        let firstGroup = SAChannelGroup(testContext: nil)
        firstGroup.remote_id = 11
        firstGroup.func = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        let firstGroupRelation = SAChannelGroupRelation(testContext: nil)
        firstGroupRelation.group = firstGroup
        firstGroupRelation.value = SAChannelValue(testContext: nil)
        firstGroupRelation.value?.online = true
        firstGroupRelation.value?.value = NSData(data: Data([1,0,100,0,120,0,0,0]))
        
        channelGroupRelationRepository.getAllVisibleRelationsForActiveProfileReturns = .just([firstGroupRelation])
        channelGroupRelationRepository.saveObservable = .just(())
        
        // when
        useCase.invoke().subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(firstGroup.online, 100)
        XCTAssertTrue(firstGroup.total_value is GroupTotalValue)
        if let groupTotalValue = firstGroup.total_value as? GroupTotalValue,
           let firstRelationValue = groupTotalValue.values[0] as? HeatpolThermostatGroupValue
        {
            XCTAssertEqual(groupTotalValue.values.count, 1)
            XCTAssertEqual(firstRelationValue.on, true)
            XCTAssertEqual(firstRelationValue.measuredTemperature, 1)
            XCTAssertEqual(firstRelationValue.presetTemperature, 1.2)
        } else {
            XCTFail("First group total value not created!")
        }
        
        assertEvents([
            .next([11]),
            .completed
        ])
    }
}
