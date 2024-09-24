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

enum ThermostatIndicatorIcon {
    case cooling, heating, forcedOffBySensor, standby, off, offline
    
    private var index: Int {
        switch(self) {
        case .cooling, .heating: 0
        case .forcedOffBySensor: 1
        case .standby: 2
        case .off: 3
        case .offline: 4
        }
    }
    
    var resource: UIImage? {
        switch(self) {
        case .cooling: .iconCooling
        case .heating: .iconHeating
        case .forcedOffBySensor: .iconSensorAlert
        case .standby: .iconStandby
        default: nil
        }
    }
    
    var resourceName: String? {
        switch(self) {
        case .cooling: .Icons.cooling
        case .heating: .Icons.heating
        case .forcedOffBySensor: .Icons.sensorAlert
        case .standby: .Icons.standby
        default: nil
        }
    }
    
    func mergeWith(_ other: ThermostatIndicatorIcon?) -> ThermostatIndicatorIcon {
        guard let other = other else { return self }
        return index < other.index ? self : other
    }
    
    func moreImportantThan(_ other: ThermostatIndicatorIcon) -> Bool {
        index > other.index
    }
}
