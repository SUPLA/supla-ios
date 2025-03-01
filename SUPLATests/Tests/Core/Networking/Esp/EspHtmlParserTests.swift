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
@testable import SUPLA

class EspHtmlParserTests: XCTestCase {
    
    private lazy var fileDataThermostat: Data! = {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "arduino", withExtension: "html")!
        return try! Data(contentsOf: file)
    }()
    
    private lazy var documentThermostat: TFHpple! = {
        return TFHpple(htmlData: fileDataThermostat)
    }()
    
    private lazy var fileDataDiy: Data! = {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "7.8.17", withExtension: "html")!
        return try! Data(contentsOf: file)
    }()
    
    private lazy var parser: EspHtmlParser! = {
        EspHtmlParser()
    }()
    
    override func tearDown() {
        documentThermostat = nil
        parser = nil
    }
    
    func test_shouldLoadInputs() {
        // when
        let inputs = parser.findInputs(document: documentThermostat)
        
        // then
        XCTAssertEqual(inputs.keys.count, 37)
        // no input without names
        XCTAssertEqual(inputs.keys.filter({ $0.isEmpty }).count, 0)
        // no checkboxes without checked attribute
        XCTAssertEqual(inputs.keys.filter({ $0 == "set_time_toggle" }).count, 0)
        // checkboxes with checked attribute
        XCTAssertEqual(inputs.keys.filter({ $0 == "0_t_chng_keeps" }).count, 1)
    }
    
    func test_shouldLoadDeviceConfig() {
        // given
        let html = String(decoding: fileDataThermostat, as: UTF8.self)
        let inputs = parser.findInputs(document: documentThermostat)
        
        // when
        let result = parser.prepareResult(document: html)
        result.needsCloudConfig = parser.needsCloudConfig(fieldMap: inputs)
        
        // then
        XCTAssertEqual(result.resultCode, .failed)
        XCTAssertEqual(result.name, "Basic thermostat")
        XCTAssertEqual(result.state, "Config mode (145), Registered and ready (3)")
        XCTAssertEqual(result.version, "SDK 23.12.02-dev")
        XCTAssertEqual(result.guid, "9F22CD27D5D799FFCE7AA50BCFD539E8")
        XCTAssertEqual(result.mac, "58:BF:25:31:9F:04")
        XCTAssertFalse(result.needsCloudConfig)
    }
    
    func test_shouldLoadDeviceConfig_withNeedsCloudConfig() {
        // given
        var inputs = parser.findInputs(document: documentThermostat)
        inputs["no_visible_channels"] = "1"
        
        // when
        let needsCloudConfig = parser.needsCloudConfig(fieldMap: inputs)
        
        // then
        XCTAssertTrue(needsCloudConfig)
    }
    
    func test_shouldLoadDiyDeviceParameters() {
        // given
        let html = String(decoding: fileDataDiy, as: UTF8.self)
        
        // when
        let result = parser.prepareResult(document: html)
        
        // then
        XCTAssertEqual(result.resultCode, .failed)
        XCTAssertEqual(result.name, "YoDeCo - Sonoff MINIR4")
        XCTAssertEqual(result.state, "Zainicjowany")
        XCTAssertEqual(result.version, "SuplaDevice GG v7.8.17")
        XCTAssertEqual(result.guid, "C85A6230A251518F61CFDE8704B6A7D8")
        XCTAssertEqual(result.mac, "30:C9:22:D2:BE:E8")
    }
}
