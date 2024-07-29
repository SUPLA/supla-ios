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

extension SuplaChannelFacadeBlindConfig {
    static func mock(
        remoteId: Int32 = 0,
        channelFunc: Int32? = nil,
        crc32: Int64 = 0,
        closingTimeMs: Int32 = 0,
        openingTimeMs: Int32 = 0,
        motorUpsideDown: Bool = false,
        buttonUpsideDown: Bool = false,
        timeMargin: Int8 = 0,
        tiltingTimeMs: Int32 = 0,
        tilt0Angle: UInt16 = 0,
        tilt100Angle: UInt16 = 0,
        type: SuplaTiltControlType = .unknown
    ) -> SuplaChannelFacadeBlindConfig {
        SuplaChannelFacadeBlindConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            closingTimeMs: closingTimeMs,
            openingTimeMs: openingTimeMs,
            motorUpsideDown: motorUpsideDown,
            buttonUpsideDown: buttonUpsideDown,
            timeMargin: timeMargin,
            tiltingTimeMs: tiltingTimeMs,
            tilt0Angle: tilt0Angle,
            tilt100Angle: tilt100Angle,
            type: type
        )
    }
}
