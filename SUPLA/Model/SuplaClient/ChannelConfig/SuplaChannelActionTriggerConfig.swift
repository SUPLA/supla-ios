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

final class SuplaChannelActionTriggerConfig: SuplaChannelConfig {
    let temporaryUnlockDurationSec: UInt32

    init(remoteId: Int32, channelFunc: Int32?, crc32: Int64, temporaryUnlockDurationSec: UInt32) {
        self.temporaryUnlockDurationSec = temporaryUnlockDurationSec
        super.init(remoteId: remoteId, channelFunc: channelFunc, crc32: crc32)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        temporaryUnlockDurationSec = try container.decode(UInt32.self, forKey: .temporaryUnlockDurationSec)
        try super.init(from: decoder)
    }

    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(temporaryUnlockDurationSec, forKey: .temporaryUnlockDurationSec)
        try super.encode(to: encoder)
    }

    func toJson() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private enum CodingKeys: String, CodingKey {
        case temporaryUnlockDurationSec
    }
}
