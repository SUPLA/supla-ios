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

final class DimmerAndRgbGroupActivePercentageProvider: GroupActivePercentageProvider {
    func handleFunction(_ function: Int32) -> Bool {
        function == SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
    }
    
    func getActivePercentage(_ valueIndex: Int, _ totalValue: GroupTotalValue) -> Int {
        return totalValue.values
            .map { $0 as! DimmerAndRgbLightingGroupValue }
            .reduce(0) { result, value in
                var sum = result
                if (valueIndex == 0 || valueIndex == 1) {
                    sum = value.colorBrightness > 0 ? sum + 1 : sum
                }
                if (valueIndex == 0 || valueIndex == 2) {
                    sum = value.brightness > 0 ? sum + 1 : sum
                }
                return sum
            } * 100 / (valueIndex == 0 ? totalValue.values.count * 2 : totalValue.values.count)
    }
}
