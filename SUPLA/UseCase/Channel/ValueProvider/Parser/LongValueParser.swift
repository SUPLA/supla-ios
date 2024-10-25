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
    
protocol LongValueParser {}

extension LongValueParser {
    func asLongValue(_ channelValue: SAChannelValue?, startingFromByte: Int = 0) -> Int64? {
        return asLongValue(channelValue?.dataValue(), startingFromByte: startingFromByte)
    }
    
    func asLongValue(_ data: Data?, startingFromByte: Int = 0) -> Int64? {
        if let value = data,
           value.count >= MemoryLayout<Int64>.size + startingFromByte
        {
            var result: Int64 = 0
            for i in 0 ..< MemoryLayout<Int64>.size {
                let current = Int64(value[startingFromByte + i])
                result |= current << (i*8)
            }
            
            return result
        }

        return nil
    }
}
