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
    
import SharedCore

extension SAChannelState : SharedCore.SuplaChannelStatePrintable {
    
    public var channelId: Int32 { channel?.remote_id ?? 0 }
    public var ipV4: String? { ipv4 }
    
    public var batteryHealthForPrintable: KotlinInt? {
        KotlinInt.from(batteryHealth)
    }
    
    public var batteryLevelForPrintable: KotlinInt? {
        KotlinInt.from(batteryLevel)
    }
    
    public var batteryPoweredForPrintable: KotlinBoolean? {
        KotlinBoolean.from(batteryPowered?.boolValue)
    }
    
    public var bridgeNodeOnlineForPrintable: KotlinBoolean? {
        KotlinBoolean.from(bridgeNodeOnline?.boolValue)
    }
    
    public var bridgeNodeSignalStrengthForPrintable: KotlinInt? {
        KotlinInt.from(bridgeNodeSignalStrength)
    }
    
    public var connectionUptimeForPrintable: KotlinInt? {
        KotlinInt.from(connectionUptime)
    }
    
    public var lastConnectionResetCauseForPrintable: KotlinInt? {
        KotlinInt.from(lastConnectionResetCause)
    }
    
    public var lightSourceLifespanForPrintable: KotlinInt? {
        KotlinInt.from(lightSourceLifespan)
    }
    
    public var lightSourceLifespanLeftForPrintable: KotlinFloat? {
        KotlinFloat.from(lightSourceLifespanLeft)
    }
    
    public var lightSourceOperatingTimeForPrintable: KotlinInt? {
        KotlinInt.from(lightSourceOperatingTime)
    }
    
    public var switchCycleCountForPrintable: KotlinInt? { nil }
    
    public var uptimeForPrintable: KotlinInt? { KotlinInt.from(uptime) }
    
    public var wifiRssiForPrintable: KotlinInt? { KotlinInt.from(wifiRssi) }
    
    public var wifiSignalStrengthForPrintable: KotlinInt? { KotlinInt.from(wifiSignalStrength) }
}
