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

class SuplaChannelContainerConfigTest: XCTestCase {
    
    func test_shouldConvertToJsonAndBack() {
        // given
        let config = SuplaChannelContainerConfig(
            remoteId: 123,
            channelFunc: SUPLA_CHANNELFNC_CONTAINER,
            crc32: 234,
            warningAboveLevel: 80,
            alarmAboveLevel: 90,
            warningBelowLevel: 20,
            alarmBelowLevel: 10,
            muteAlarmSoundWithoutAdditionalAuth: true,
            sensors: [
                SuplaSensorInfo(fillLevel: 80, channelId: 2),
                SuplaSensorInfo(fillLevel: 90, channelId: 3)
            ]
        )
        
        // when
        let jsonString = config.toJson()
        let result = try! JSONDecoder().decode(SuplaChannelContainerConfig.self, from: (jsonString?.data(using: .utf8))!)
        
        // then
        XCTAssertEqual(config.remoteId, result.remoteId)
        XCTAssertEqual(config.channelFunc, result.channelFunc)
        XCTAssertEqual(config.crc32, result.crc32)
        XCTAssertEqual(config.warningAboveLevel, result.warningAboveLevel)
        XCTAssertEqual(config.alarmAboveLevel, result.alarmAboveLevel)
        XCTAssertEqual(config.warningBelowLevel, result.warningBelowLevel)
        XCTAssertEqual(config.alarmBelowLevel, result.alarmBelowLevel)
        XCTAssertEqual(config.muteAlarmSoundWithoutAdditionalAuth, result.muteAlarmSoundWithoutAdditionalAuth)
        XCTAssertEqual(config.sensors.count, result.sensors.count)
        XCTAssertEqual(config.sensors, result.sensors)
    }
}
