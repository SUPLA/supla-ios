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

import Combine

extension RecuperatorGeneralFeature {
    final class ViewState: ObservableObject {
        @Published var isOff: Bool = false
        @Published var mode: WorkingMode? = nil
        @Published var supplyOutsideTemperature: String = ""
        @Published var supplyInsideTemperature: String = ""
        @Published var exhaustOutsideTemperature: String = ""
        @Published var exhaustInsideTemperature: String = ""
        @Published var supplyPowerPercent: String = ""
        @Published var exhaustPowerPercent: String = ""
        @Published var currentSpeed: Int = 0
        
        init(
            isOff: Bool = false,
            mode: WorkingMode? = nil,
            supplyOutsideTemperature: String = "",
            supplyInsideTemperature: String = "",
            exhaustOutsideTemperature: String = "",
            exhaustInsideTemperature: String = "",
            supplyPowerPercent: String = "",
            exhaustPowerPercent: String = ""
        ) {
            self.isOff = isOff
            self.mode = mode
            self.supplyOutsideTemperature = supplyOutsideTemperature
            self.supplyInsideTemperature = supplyInsideTemperature
            self.exhaustOutsideTemperature = exhaustOutsideTemperature
            self.exhaustInsideTemperature = exhaustInsideTemperature
            self.supplyPowerPercent = supplyPowerPercent
            self.exhaustPowerPercent = exhaustPowerPercent
        }
    }

    enum WorkingMode {
        case manual
        case program
    }
}
