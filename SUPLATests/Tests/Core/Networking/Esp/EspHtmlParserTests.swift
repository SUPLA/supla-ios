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
import SwiftSoup
import XCTest

class EspHtmlParserTests: XCTestCase {
    private lazy var fileDataThermostat: Data! = {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "arduino", withExtension: "html")!
        return try! Data(contentsOf: file)
    }()
    
    private lazy var documentThermostat: SwiftSoup.Document! = try! SwiftSoup.parse(String(data: fileDataThermostat, encoding: .utf8)!)
    
    private lazy var fileDataDiy: Data! = {
        let testBundle = Bundle(for: type(of: self))
        let file = testBundle.url(forResource: "7.8.17", withExtension: "html")!
        return try! Data(contentsOf: file)
    }()
    
    private lazy var documentDiy: SwiftSoup.Document! = try! SwiftSoup.parse(String(data: fileDataDiy, encoding: .utf8)!)
    
    private lazy var parser: EspHtmlParser! = EspHtmlParser()
    
    override func tearDown() {
        documentThermostat = nil
        documentDiy = nil
        parser = nil
    }
    
    func test_shouldLoadInputs() {
        // when
        let inputs = parser.findInputs(document: documentThermostat)
        
        // then
        XCTAssertEqual(inputs.keys.count, 37)
        for (key, value) in inputsMapThermostat {
            XCTAssertEqual(inputs[key], value, "Failed by key: \(key)")
        }
        // no input without names
        XCTAssertEqual(inputs.keys.filter { $0.isEmpty }.count, 0)
        // no checkboxes without checked attribute
        XCTAssertEqual(inputs.keys.filter { $0 == "set_time_toggle" }.count, 0)
        // checkboxes with checked attribute
        XCTAssertEqual(inputs.keys.filter { $0 == "0_t_chng_keeps" }.count, 1)
    }
    
    func test_shouldLoadInputsDiy() {
        // when
        let inputs = parser.findInputs(document: documentDiy)
        
        // then
        XCTAssertEqual(inputs.keys.count, 7)
        for (key, value) in inputsMapDiy {
            XCTAssertEqual(inputs[key], value, "Failed by key: \(key)")
        }
        // no input without names
        XCTAssertEqual(inputs.keys.filter { $0.isEmpty }.count, 0)
    }
    
    func test_shouldLoadDeviceConfig() {
        // given
        let html = String(decoding: fileDataThermostat, as: UTF8.self)
        let inputs = parser.findInputs(document: documentThermostat)
        
        // when
        let result = parser.prepareResult(document: html, fieldMap: inputs)
        
        // then
        XCTAssertEqual(result.name, "Basic thermostat")
        XCTAssertEqual(result.state, "Config mode (145), Registered and ready (3)")
        XCTAssertEqual(result.version, "SDK 23.12.02-dev")
        XCTAssertEqual(result.guid, "9F22CD27D5D799FFCE7AA50BCFD539E8")
        XCTAssertEqual(result.mac, "58:BF:25:31:9F:04")
        XCTAssertFalse(result.needsCloudConfig)
    }
    
    func test_shouldLoadDeviceConfig_withNeedsCloudConfig() {
        // given
        let html = String(decoding: fileDataThermostat, as: UTF8.self)
        var inputs = parser.findInputs(document: documentThermostat)
        inputs["no_visible_channels"] = "1"
        
        // when
        let result = parser.prepareResult(document: html, fieldMap: inputs)
        
        // then
        XCTAssertTrue(result.needsCloudConfig)
    }
    
    func test_shouldLoadDiyDeviceParameters() {
        // given
        let html = String(decoding: fileDataDiy, as: UTF8.self)
        var inputs = parser.findInputs(document: documentDiy)
        
        // when
        let result = parser.prepareResult(document: html, fieldMap: inputs)
        
        // then
        XCTAssertEqual(result.name, "YoDeCo - Sonoff MINIR4")
        XCTAssertEqual(result.state, "Zainicjowany")
        XCTAssertEqual(result.version, "SuplaDevice GG v7.8.17")
        XCTAssertEqual(result.guid, "C85A6230A251518F61CFDE8704B6A7D8")
        XCTAssertEqual(result.mac, "30:C9:22:D2:BE:E8")
    }
    
    private let inputsMapThermostat: [String: String] = [
        "mqtttls": "0",
        "mqttprefix": "",
        "date_time_value": "",
        "0_algorithm": "1",
        "0_t_freeze": "",
        "0_t_aux_min": "",
        "0_min_on_s": "0",
        "sec": "0",
        "0_subfnc": "1",
        "timesync_auto": "on",
        "protocol_supla": "1",
        "0_fnc": "420",
        "rbt": "0",
        "mqttserver": "",
        "0_t_aux_max": "",
        "0_t_heat": "",
        "mqttport": "1883",
        "mqttqos": "0",
        "mqttauth": "1",
        "0_t_hister": "0.4",
        "mqttretain": "0",
        "0_t_aux": "2",
        "0_error_val": "0",
        "0_min_off_s": "0",
        "protocol_mqtt": "0",
        "mqttpasswd": "",
        "svr": "beta-cloud.supla.org",
        "mqttuser": "",
        "sid": "truskawka_IoT",
        "wpw": "",
        "led": "0",
        "0_t_main": "1",
        "0_t_max": "",
        "0_hvac_mode": "2",
        "0_t_aux_type": "2",
        "0_t_chng_keeps": "on",
        "eml": "krz.lewandowski@gmail.com"
    ]
    
    private let inputsMapDiy: [String: String] = [
        "mps": "pass",
        "mlg": "admin",
        "shn": "YoDeCo - Sonoff MINIR4",
        "svr": "svrxx.supla.org",
        "wpw": "",
        "eml": "xxx.xxxxx@gmail.com",
        "sid": "XYZ",
    ]
}
