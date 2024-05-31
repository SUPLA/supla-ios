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

import Foundation

@testable import SUPLA
import XCTest

class GroupTotalValueTest: XCTestCase {
    
    func testShouldArchiveGroupTotalValue() {
        let totalValue = GroupTotalValue(values: [
            RollerShutterGroupValue(position: 10, closedSensorActive: false),
            RollerShutterGroupValue(position: 30, closedSensorActive: true),
            ShadowingBlindGroupValue(position: 10, tilt: 20),
            IntegerGroupValue(value: 33),
            RgbLightingGroupValue(color: .background, brightness: 88),
            DimmerAndRgbLightingGroupValue(color: .channelCell, colorBrightness: 32, brightness: 92),
            HeatpolThermostatGroupValue(on: true, measuredTemperature: 10.3, presetTemperature: 12.5)
        ])

        let archive = try! NSKeyedArchiver.archivedData(withRootObject: totalValue, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: GroupTotalValue.self, from: archive)
        
        XCTAssertEqual(totalValue.values, result?.values)
    }
    
    func testShouldArchiveRollerShutterGroupValue() {
        let value = RollerShutterGroupValue(position: 10, closedSensorActive: true)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: RollerShutterGroupValue.self, from: archive)
        
        XCTAssertEqual(value.position, result?.position)
        XCTAssertEqual(value.closedSensorActive, result?.closedSensorActive)
    }
    
    func testShouldArchiveFacadeBlindGroupValue() {
        let value = ShadowingBlindGroupValue(position: 10, tilt: 55)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ShadowingBlindGroupValue.self, from: archive)
        
        XCTAssertEqual(value.position, result?.position)
        XCTAssertEqual(value.tilt, result?.tilt)
    }
    
    func testShouldArchiveIntegerGroupValue() {
        let value = IntegerGroupValue(value: 10)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: IntegerGroupValue.self, from: archive)
        
        XCTAssertEqual(value.value, result?.value)
    }
    
    func testShouldArchiveBoolGroupValue() {
        let value = BoolGroupValue(value: true)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: BoolGroupValue.self, from: archive)
        
        XCTAssertEqual(value.value, result?.value)
    }
    
    func testShouldArchiveRgbLightingGroupValue() {
        let value = RgbLightingGroupValue(color: .chartGpm, brightness: 55)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: RgbLightingGroupValue.self, from: archive)
        
        XCTAssertEqual(value.color, result?.color)
        XCTAssertEqual(value.brightness, result?.brightness)
    }
    
    func testShouldArchiveDimmerAndRgbLightingGroupValue() {
        let value = DimmerAndRgbLightingGroupValue(color: .chartGpm, colorBrightness: 22, brightness: 55)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: DimmerAndRgbLightingGroupValue.self, from: archive)
        
        XCTAssertEqual(value.color, result?.color)
        XCTAssertEqual(value.colorBrightness, result?.colorBrightness)
        XCTAssertEqual(value.brightness, result?.brightness)
    }
    
    func testShouldArchiveHeatpolThermostatGroupValue() {
        let value = HeatpolThermostatGroupValue(on: true, measuredTemperature: 14.3, presetTemperature: 15.1)
        
        let archive = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        let result = try! NSKeyedUnarchiver.unarchivedObject(ofClass: HeatpolThermostatGroupValue.self, from: archive)
        
        XCTAssertEqual(value.on, result?.on)
        XCTAssertEqual(value.measuredTemperature, result?.measuredTemperature)
        XCTAssertEqual(value.presetTemperature, result?.presetTemperature)
    }
}
