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

extension SAChannelValue {
    
    static func mockThermostat(
        mode: SuplaHvacMode = .heat,
        setpointHeat: Int16 = 0,
        setpointCool: Int16 = 0,
        flags: [SuplaThermostatFlag] = [],
        online: Bool = true
    ) -> SAChannelValue {
        var flagsInt = 0
        flags.forEach { flagsInt ^= 1 << $0.rawValue }
        
        var hvacValue = THVACValue(
            IsOn: 1,
            Mode: mode.rawValue,
            SetpointTemperatureHeat: setpointHeat,
            SetpointTemperatureCool: setpointCool,
            Flags: UInt16(flagsInt)
        )
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(bytes: &hvacValue, length: MemoryLayout<THVACValue>.size)
        channelValue.online = true
        
        return channelValue
    }
}
