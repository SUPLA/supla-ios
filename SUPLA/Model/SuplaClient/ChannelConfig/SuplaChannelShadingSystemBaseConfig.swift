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

class SuplaChannelShadingSystemBaseConfig: SuplaChannelConfig {
    let closingTimeMs: Int32
    let openingTimeMs: Int32
    let motorUpsideDown: Bool
    let buttonUpsideDown: Bool
    let timeMargin: Int8
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        crc32: Int64,
        closingTimeMs: Int32,
        openingTimeMs: Int32,
        motorUpsideDown: Bool,
        buttonUpsideDown: Bool,
        timeMargin: Int8
    ) {
        self.closingTimeMs = closingTimeMs
        self.openingTimeMs = openingTimeMs
        self.motorUpsideDown = motorUpsideDown
        self.buttonUpsideDown = buttonUpsideDown
        self.timeMargin = timeMargin
        super.init(remoteId: remoteId, channelFunc: channelFunc, crc32: crc32)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closingTimeMs = try container.decode(Int32.self, forKey: .closingTimeMs)
        openingTimeMs = try container.decode(Int32.self, forKey: .openingTimeMs)
        motorUpsideDown = try container.decode(Bool.self, forKey: .motorUpsideDown)
        buttonUpsideDown = try container.decode(Bool.self, forKey: .buttonUpsideDown)
        timeMargin = try container.decode(Int8.self, forKey: .timeMargin)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(closingTimeMs, forKey: .closingTimeMs)
        try container.encode(openingTimeMs, forKey: .openingTimeMs)
        try container.encode(motorUpsideDown, forKey: .motorUpsideDown)
        try container.encode(buttonUpsideDown, forKey: .buttonUpsideDown)
        try container.encode(timeMargin, forKey: .timeMargin)
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys : String, CodingKey {
        case closingTimeMs
        case openingTimeMs
        case motorUpsideDown
        case buttonUpsideDown
        case timeMargin
    }
}
