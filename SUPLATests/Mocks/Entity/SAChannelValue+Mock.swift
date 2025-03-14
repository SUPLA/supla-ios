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
import SharedCore

extension SAChannelValue {
    
    static func mock(status: SuplaChannelAvailabilityStatus = .offline, value: NSObject? = nil) -> SAChannelValue {
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = status.rawValue
        channelValue.value = value
        return channelValue
    }
    
    static func mockThermostat(
        mode: SuplaHvacMode = .heat,
        setpointHeat: Int16 = 0,
        setpointCool: Int16 = 0,
        flags: [SuplaThermostatFlag] = [],
        online: Bool = true
    ) -> SAChannelValue {
        var flagsInt = 0
        flags.forEach { flagsInt ^= 1 << $0.value }
        
        var hvacValue = THVACValue(
            IsOn: 1,
            Mode: UInt8(mode.value),
            SetpointTemperatureHeat: setpointHeat,
            SetpointTemperatureCool: setpointCool,
            Flags: UInt16(flagsInt)
        )
        
        let value = NSData(bytes: &hvacValue, length: MemoryLayout<THVACValue>.size)
        return SAChannelValue.mock(status: .online, value: value)
    }
    
    static func mockRollerShutter(
        status: SuplaChannelAvailabilityStatus = .online,
        position: Int = 0,
        bottomPosition: Int = 100,
        flags: [SuplaShadingSystemFlag] = []
    ) -> SAChannelValue {
        var flagsInt = 0
        flags.forEach { flagsInt ^= 1 << $0.value }
        
        var rollerShutterValue = TDSC_RollerShutterValue(
            position: Int8(position),
            reserved1: 0,
            bottom_position: Int8(bottomPosition),
            flags: Int16(flagsInt),
            reserved2: 0,
            reserved3: 0,
            reserved4: 0
        )
        
        let value = NSData(bytes: &rollerShutterValue, length: MemoryLayout<TDSC_RollerShutterValue>.size)
        return SAChannelValue.mock(status: status, value: value)
    }
    
    static func mockFacadeBlind(
        status: SuplaChannelAvailabilityStatus = .online,
        position: Int = 0,
        tilt: Int = 100,
        flags: [SuplaShadingSystemFlag] = []
    ) -> SAChannelValue {
        var flagsInt = 0
        flags.forEach { flagsInt ^= 1 << $0.value }
        
        var facadeBlindValue = TDSC_FacadeBlindValue(
            position: Int8(position),
            tilt: Int8(tilt),
            reserved: 0,
            flags: Int16(flagsInt),
            reserved2: (0, 0, 0)
        )
        
        let value = NSData(bytes: &facadeBlindValue, length: MemoryLayout<TDSC_FacadeBlindValue>.size)
        return SAChannelValue.mock(status: status, value: value)
    }
    
    static func mockValve(
        status: SuplaChannelAvailabilityStatus = .online,
        open: Bool = true,
        flags: [SuplaValveFlag] = []
    ) -> SAChannelValue {
        var flagsInt: Int32 = 0
        flags.forEach { flagsInt ^= $0.value }
        
        var valveValue = TValve_Value(TValve_Value.__Unnamed_union___Anonymous_field0(closed: open ? 1 : 0), flags: UInt8(flagsInt))
        let value = NSData(bytes: &valveValue, length: MemoryLayout<TValve_Value>.size)
        return SAChannelValue.mock(status: status, value: value)
    }
}
