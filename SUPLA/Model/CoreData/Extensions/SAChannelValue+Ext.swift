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
import SharedCore

extension SAChannelValue {
    @objc var status: SuplaChannelAvailabilityStatus {
        SuplaChannelAvailabilityStatus.companion.from(value: online)
    }
    
    func asThermostatValue() -> ThermostatValue {
        ThermostatValue.companion.from(status: status, bytes: KotlinByteArray.from(data: dataValue()))
    }
    
    func asRollerShutterValue() -> RollerShutterValue {
        RollerShutterValue.companion.from(status: status, bytes: KotlinByteArray.from(data: dataValue()))
    }
    
    func asFacadeBlindValue() -> FacadeBlindValue {
        FacadeBlindValue.companion.from(status: status, bytes: KotlinByteArray.from(data: dataValue()))
    }
    
    func asHeatpolThermostatValue() -> HeatpolThermostatValue {
        HeatpolThermostatValue.from(dataValue(), online: online == SUPLA_CHANNEL_ONLINE_FLAG_ONLINE)
    }
    
    func asContainerValue() -> ContainerValue {
        ContainerValue.companion.from(status: status, bytes: KotlinByteArray.from(data: dataValue()))
    }
    
    func asValveValue() -> ValveValue {
        ValveValue.companion.from(status: status, bytes: KotlinByteArray.from(data: rawDataValue()))
    }
    
    func asRelayValue() -> RelayValue {
        RelayValue.companion.from(status: status, bytes: KotlinByteArray.from(data: rawDataValue()))
    }
    
    @objc func isThermostatSubfunctionHeat() -> Bool {
        asThermostatValue().subfunction == .heat
    }
}
