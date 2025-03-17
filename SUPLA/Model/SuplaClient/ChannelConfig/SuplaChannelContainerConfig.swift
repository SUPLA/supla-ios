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
    
final class SuplaChannelContainerConfig: SuplaChannelConfig {
    let warningAboveLevel: Int32
    let alarmAboveLevel: Int32
    let warningBelowLevel: Int32
    let alarmBelowLevel: Int32
    let muteAlarmSoundWithoutAdditionalAuth: Bool
    let sensors: [SuplaSensorInfo]
    
    init(
        remoteId: Int32,
        channelFunc: Int32?,
        crc32: Int64,
        warningAboveLevel: Int32,
        alarmAboveLevel: Int32,
        warningBelowLevel: Int32,
        alarmBelowLevel: Int32,
        muteAlarmSoundWithoutAdditionalAuth: Bool,
        sensors: [SuplaSensorInfo]
    ) {
        self.warningAboveLevel = warningAboveLevel
        self.alarmAboveLevel = alarmAboveLevel
        self.warningBelowLevel = warningBelowLevel
        self.alarmBelowLevel = alarmBelowLevel
        self.muteAlarmSoundWithoutAdditionalAuth = muteAlarmSoundWithoutAdditionalAuth
        self.sensors = sensors
        super.init(remoteId: remoteId, channelFunc: channelFunc, crc32: crc32)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        warningAboveLevel = try container.decode(Int32.self, forKey: .warningAboveLevel)
        alarmAboveLevel = try container.decode(Int32.self, forKey: .alarmAboveLevel)
        warningBelowLevel = try container.decode(Int32.self, forKey: .warningBelowLevel)
        alarmBelowLevel = try container.decode(Int32.self, forKey: .alarmBelowLevel)
        muteAlarmSoundWithoutAdditionalAuth = try container.decode(Bool.self, forKey: .muteAlarmSoundWithoutAdditionalAuth)
        sensors = try container.decode([SuplaSensorInfo].self, forKey: .sensors)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(warningAboveLevel, forKey: .warningAboveLevel)
        try container.encode(alarmAboveLevel, forKey: .alarmAboveLevel)
        try container.encode(warningBelowLevel, forKey: .warningBelowLevel)
        try container.encode(alarmBelowLevel, forKey: .alarmBelowLevel)
        try container.encode(muteAlarmSoundWithoutAdditionalAuth, forKey: .muteAlarmSoundWithoutAdditionalAuth)
        try container.encode(sensors, forKey: .sensors)
        try super.encode(to: encoder)
    }
    
    func toJson() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        
        return nil
    }
    
    static func from(remoteId: Int32, channelFunc: Int32?, crc32: Int64, suplaConfig: inout TChannelConfig_Container) -> SuplaChannelContainerConfig {
        return SuplaChannelContainerConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            warningAboveLevel: Int32(suplaConfig.WarningAboveLevel),
            alarmAboveLevel: Int32(suplaConfig.AlarmAboveLevel),
            warningBelowLevel: Int32(suplaConfig.WarningBelowLevel),
            alarmBelowLevel: Int32(suplaConfig.AlarmBelowLevel),
            muteAlarmSoundWithoutAdditionalAuth: suplaConfig.MuteAlarmSoundWithoutAdditionalAuth == 1,
            sensors: SuplaSensorInfo.from(suplaConfig: &suplaConfig)
        )
    }
    
    private enum CodingKeys : String, CodingKey {
        case warningAboveLevel
        case alarmAboveLevel
        case warningBelowLevel
        case alarmBelowLevel
        case muteAlarmSoundWithoutAdditionalAuth
        case sensors
    }
}

struct SuplaSensorInfo: Codable, Equatable {
    let fillLevel: Int32
    let channelId: Int32
    
    init (fillLevel: Int32, channelId: Int32) {
        self.fillLevel = fillLevel
        self.channelId = channelId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fillLevel = try container.decode(Int32.self, forKey: .fillLevel)
        channelId = try container.decode(Int32.self, forKey: .channelId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fillLevel, forKey: .fillLevel)
        try container.encode(channelId, forKey: .channelId)
    }
    
    static func from(suplaConfig: inout TChannelConfig_Container) -> [SuplaSensorInfo] {
        let sensorInfoPointer = withUnsafeBytes(of: &suplaConfig.SensorInfo) { rawPointer in
            return rawPointer.baseAddress!.assumingMemoryBound(to: TContainer_SensorInfo.self)
        }
        let sensorInfoBuffer = UnsafeBufferPointer(start: sensorInfoPointer, count: 10)
        
        var result: [SuplaSensorInfo] = []
        for sensor in sensorInfoBuffer {
            result.append(SuplaSensorInfo(fillLevel: Int32(sensor.FillLevel), channelId: sensor.ChannelId))
        }
        return result
    }
    
    private enum CodingKeys : String, CodingKey {
        case fillLevel
        case channelId
    }
}
