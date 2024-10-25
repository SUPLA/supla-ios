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

protocol IntValueParser {}

extension IntValueParser {
    func asIntValue(_ channelValue: SAChannelValue?, startingFromByte: Int = 0) -> Int? {
        return asIntValue(channelValue?.dataValue(), startingFromByte: startingFromByte)
    }
    
    func asIntValue(_ data: Data?, startingFromByte: Int = 0) -> Int? {
        if let value = data,
           value.count >= MemoryLayout<Int32>.size + startingFromByte
        {
            var result = 0
            for i in 0 ..< MemoryLayout<Int32>.size {
                let current = Int(value[startingFromByte + i])
                result |= current << (i*8)
            }
            
            return result
        }

        return nil
    }
}
