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

@testable import SUPLA

extension SuplaChannelContainerConfig {
    static func mock(
        remoteId: Int32 = 1,
        channelFunc: Int32? = SUPLA_CHANNELFNC_CONTAINER,
        crc32: Int64 = 0,
        warningAboveLevel: Int32 = 80,
        alarmAboveLevel: Int32 = 90,
        warningBelowLevel: Int32 = 20,
        alarmBelowLevel: Int32 = 10,
        muteAlarmSoundWithoutAdditionalAuth: Bool = false,
        sensors: [SuplaSensorInfo] = []
    ) -> SuplaChannelContainerConfig {
        SuplaChannelContainerConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            warningAboveLevel: warningAboveLevel,
            alarmAboveLevel: alarmAboveLevel,
            warningBelowLevel: warningBelowLevel,
            alarmBelowLevel: alarmBelowLevel,
            muteAlarmSoundWithoutAdditionalAuth: muteAlarmSoundWithoutAdditionalAuth,
            sensors: sensors
        )
    }
}
