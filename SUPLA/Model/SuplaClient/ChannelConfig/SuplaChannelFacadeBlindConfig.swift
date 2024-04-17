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

class SuplaChannelFacadeBlindConfig: SuplaChannelShadingSystemBaseConfig {
    let tiltingTimeMs: Int32
    let tilt0Angle: UInt16
    let tilt100Angle: UInt16
    let type: SuplaTiltControlType
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        crc32: Int64,
        closingTimeMs: Int32,
        openingTimeMs: Int32,
        motorUpsideDown: Bool,
        buttonUpsideDown: Bool,
        timeMargin: Int8,
        tiltingTimeMs: Int32,
        tilt0Angle: UInt16,
        tilt100Angle: UInt16,
        type: SuplaTiltControlType
    ) {
        self.tiltingTimeMs = tiltingTimeMs
        self.tilt0Angle = tilt0Angle
        self.tilt100Angle = tilt100Angle
        self.type = type
        super.init(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            closingTimeMs: closingTimeMs,
            openingTimeMs: openingTimeMs,
            motorUpsideDown: motorUpsideDown,
            buttonUpsideDown: buttonUpsideDown,
            timeMargin: timeMargin
        )
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    static func from(_ config: TChannelConfig_FacadeBlind, remoteId: Int32, channelFunc: Int32?, crc32: Int64) -> SuplaChannelFacadeBlindConfig {
        return SuplaChannelFacadeBlindConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            closingTimeMs: config.ClosingTimeMS,
            openingTimeMs: config.OpeningTimeMS,
            motorUpsideDown: config.MotorUpsideDown > 0,
            buttonUpsideDown: config.ButtonsUpsideDown > 0,
            timeMargin: config.TimeMargin,
            tiltingTimeMs: config.TiltingTimeMS,
            tilt0Angle: config.Tilt0Angle,
            tilt100Angle: config.Tilt100Angle,
            type: SuplaTiltControlType.from(config.TiltControlType)
        )
    }
}
