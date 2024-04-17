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

final class SuplaChannelRollerShutterConfig: SuplaChannelShadingSystemBaseConfig {
    static func from(_ config: TChannelConfig_RollerShutter, remoteId: Int32, channelFunc: Int32?, crc32: Int64) -> SuplaChannelRollerShutterConfig {
        return SuplaChannelRollerShutterConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            closingTimeMs: config.ClosingTimeMS,
            openingTimeMs: config.OpeningTimeMS,
            motorUpsideDown: config.MotorUpsideDown > 0,
            buttonUpsideDown: config.ButtonsUpsideDown > 0,
            timeMargin: config.TimeMargin
        )
    }
}
