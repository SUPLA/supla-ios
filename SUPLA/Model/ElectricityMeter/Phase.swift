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

enum Phase: UInt8, CaseIterable {
    case phase1 = 1
    case phase2 = 2
    case phase3 = 3

    var disabledFlag: Int64 {
        switch (self) {
        case .phase1: return Int64(SUPLA_CHANNEL_FLAG_PHASE1_UNSUPPORTED)
        case .phase2: return Int64(SUPLA_CHANNEL_FLAG_PHASE2_UNSUPPORTED)
        case .phase3: return Int64(SUPLA_CHANNEL_FLAG_PHASE3_UNSUPPORTED)
        }
    }

    var label: String {
        switch (self) {
        case .phase1: return Strings.ElectricityMeter.phase1
        case .phase2: return Strings.ElectricityMeter.phase2
        case .phase3: return Strings.ElectricityMeter.phase3
        }
    }
}
