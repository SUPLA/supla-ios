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

final class OpenedClosedGroupActivePercentageProvider: GroupActivePercentageProvider {
    func handleFunction(_ function: Int32) -> Bool {
        switch (function) {
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
                 SUPLA_CHANNELFNC_POWERSWITCH,
                 SUPLA_CHANNELFNC_LIGHTSWITCH,
                 SUPLA_CHANNELFNC_STAIRCASETIMER,
                 SUPLA_CHANNELFNC_VALVE_OPENCLOSE: true
            default: false
        }
    }

    func getActivePercentage(_ valueIndex: Int, _ totalValue: GroupTotalValue) -> Int {
        totalValue.values
            .map { $0 as! BoolGroupValue }
            .reduce(0) { result, value in
                value.value ? result + 1 : result
            } * 100 / totalValue.values.count
    }
}
