//
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

final class ElectricityMeterValueProviderTest: XCTestCase {
    
    private lazy var provider: ElectricityMeterValueProvider! = ElectricityMeterValueProviderImpl()
    
    private lazy var userStateHolder: UserStateHolderMock! = UserStateHolderMock()
    
    override func setUp() {
        DiContainer.shared.register(type: UserStateHolder.self, userStateHolder!)
    }
    
    override func tearDown() {
        provider = nil
        userStateHolder = nil
    }
    
    func test_shouldGetValueFromChannelValue() {
        // given
        userStateHolder.getElectricityMeterSettingsReturns = ElectricityMeterSettings(
            showOnList: .forwardActiveEnergy,
            balancing: .defaultValue
        )
        
        var intValue: Int32 = 3310
        var tmp: UInt8 = 0
        
        var data = Data()
        data.append(&tmp, count: 1)
        data.append(withUnsafeBytes(of: &intValue) { Data($0) })
        data.append(&tmp, count: 1)
        data.append(&tmp, count: 1)
        data.append(&tmp, count: 1)
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = data as NSData
        
        let channel = SAChannel(testContext: nil)
        channel.value = channelValue
        
        
        // when
        let value = provider.value(channel, valueType: .first)
        
        // then
        XCTAssertEqual(value as! Double, 33.1)
    }
}
