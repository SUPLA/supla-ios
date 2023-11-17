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

class SuplaDeviceConfigTests: XCTestCase {
    
    func test_shouldParseDeviceConfig_allFields() {
        // given
        let config = SuplaConfigIntegrator.mockDeviceConfig(withUserInterfaceField: true)
        
        // when
        let result = SuplaDeviceConfig(config: config)
        
        // then
        XCTAssertEqual(result.deviceId, 123456)
        XCTAssertEqual(result.availableFields, SuplaFieldType.allCases)
        XCTAssertEqual(result.fields.map { $0.type }, [
            .statusLed, .screenBrightness,
            .buttonVolume, .disableUserInterface,
            .automaticTimeSync, .homeScreenOffDelay,
            .homeScreenContent
        ])
        for field in result.fields {
            if let field = field as? SuplaLedStatusField {
                XCTAssertEqual(field, SuplaLedStatusField(ledStatus: .offWhenConnected))
            }
            if let field = field as? SuplaScreenBrightnessField {
                XCTAssertEqual(field, SuplaScreenBrightnessField(automatic: true, level: 50, adjustmentForAutomatic: 10))
            }
            if let field = field as? SuplaButtonVolumeField {
                XCTAssertEqual(field, SuplaButtonVolumeField(volume: 80))
            }
            if let field = field as? SuplaDisableUserInterfaceField {
                XCTAssertEqual(field, SuplaDisableUserInterfaceField(disabled: .partial, minAllowedTemperature: 1200, maxAllowedTemperature: 2500))
            }
            if let field = field as? SuplaAutomaticTimeSyncField {
                XCTAssertEqual(field, SuplaAutomaticTimeSyncField(enabled: true))
            }
            if let field = field as? SuplaHomeScreenOffDelayField {
                XCTAssertEqual(field, SuplaHomeScreenOffDelayField(enabled: true, seconds: 10))
            }
            if let field = field as? SuplaHomeScreenContentField {
                XCTAssertEqual(field, SuplaHomeScreenContentField(available: SuplaHomeScreenContent.allCases, content: .temperatureAndHumidity))
            }
        }
    }
    
    func test_shouldParseDeviceConfig_notAllFields() {
        // given
        let config = SuplaConfigIntegrator.mockDeviceConfig(withUserInterfaceField: false)
        
        // when
        let result = SuplaDeviceConfig(config: config)
        
        // then
        XCTAssertEqual(result.deviceId, 123456)
        XCTAssertEqual(result.availableFields, SuplaFieldType.allCases)
        XCTAssertEqual(result.fields.map { $0.type }, [
            .statusLed, .screenBrightness,
            .buttonVolume,
            .automaticTimeSync, .homeScreenOffDelay,
            .homeScreenContent
        ])
        for field in result.fields {
            if let field = field as? SuplaLedStatusField {
                XCTAssertEqual(field, SuplaLedStatusField(ledStatus: .offWhenConnected))
            }
            if let field = field as? SuplaScreenBrightnessField {
                XCTAssertEqual(field, SuplaScreenBrightnessField(automatic: true, level: 50, adjustmentForAutomatic: 10))
            }
            if let field = field as? SuplaButtonVolumeField {
                XCTAssertEqual(field, SuplaButtonVolumeField(volume: 80))
            }
            if let field = field as? SuplaAutomaticTimeSyncField {
                XCTAssertEqual(field, SuplaAutomaticTimeSyncField(enabled: true))
            }
            if let field = field as? SuplaHomeScreenOffDelayField {
                XCTAssertEqual(field, SuplaHomeScreenOffDelayField(enabled: true, seconds: 10))
            }
            if let field = field as? SuplaHomeScreenContentField {
                XCTAssertEqual(field, SuplaHomeScreenContentField(available: SuplaHomeScreenContent.allCases, content: .temperatureAndHumidity))
            }
        }
    }
}
