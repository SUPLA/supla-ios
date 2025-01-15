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
    
struct AggregationResult {
    let list: [AggregatedEntity]
    let sum: [Double]
    
    init(list: [AggregatedEntity], sum: [Double]) {
        self.list = list
        self.sum = sum
    }
    
    private var index = 0
    
    mutating func nextSum() -> Double {
        let result = if (index < sum.count) {
            sum[index]
        } else {
            0.0
        }
        index += 1
        
        return result
    }
}
