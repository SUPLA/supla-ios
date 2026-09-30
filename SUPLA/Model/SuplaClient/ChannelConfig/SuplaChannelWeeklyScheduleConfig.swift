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

import SharedCore

final class SuplaChannelWeeklyScheduleConfig: SuplaChannelConfig {
    
    let programConfigurations: SuplaWeeklyScheduleProgramSet
    let schedule: [SuplaWeeklyScheduleEntry]
    
    init(remoteId: Int32, channelFunc: Int32?, crc32: Int64, programConfigurations: SuplaWeeklyScheduleProgramSet, schedule: [SuplaWeeklyScheduleEntry]) {
        self.programConfigurations = programConfigurations
        self.schedule = schedule
        super.init(remoteId: remoteId, channelFunc: channelFunc, crc32: crc32)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    static func from(remoteId: Int32, channelFunc: Int32?, crc32: Int64, suplaConfig: TChannelConfig_WeeklySchedule) -> SuplaChannelWeeklyScheduleConfig {
        
        let programConfigurations: SuplaWeeklyScheduleProgramSet
        let size = TChannelConfig_WeeklySchedule.programCount
        if channelFunc?.isRelayScheduleFunction == true {
            programConfigurations = .relay((0..<size).map { programId in
                let program = suplaConfig.program(at: programId)
                return SuplaRelayWeeklyScheduleProgram(
                    program: SuplaScheduleProgram.from(value: UInt8(programId + 1)),
                    mode: SuplaRelayMode.companion.from(value: Int32(program.Mode)),
                    modeDurationS: UInt16(program.RelayModeDurationS),
                    oppositeModeDurationS: UInt16(program.RelayOppositeModeDurationS)
                )
            })
        } else {
            programConfigurations = .hvac((0..<size).map { programId in
                let program = suplaConfig.program(at: programId)
                return SuplaHvacWeeklyScheduleProgram(
                    program: SuplaScheduleProgram.from(value: UInt8(programId + 1)),
                    mode: SuplaHvacMode.companion.from(byte: Int32(program.Mode)),
                    setpointTemperatureHeat: program.SetpointTemperatureHeat,
                    setpointTemperatureCool: program.SetpointTemperatureCool
                )
            })
        }
        
        var schedule: [SuplaWeeklyScheduleEntry] = []
        for index in 0..<TChannelConfig_WeeklySchedule.quarterCount {
            let dayOfWeek = index / 4 / 24
            let hour = (index / 4) % 24
            let quarterOfHour = index % 4
            let program = suplaConfig.program(atQuarter: index)

            schedule.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: DayOfWeek.from(value: UInt8(dayOfWeek)),
                    hour: UInt8(hour),
                    quarterOfHour: QuarterOfHour.from(value: UInt8(quarterOfHour + 1)),
                    program: SuplaScheduleProgram.from(value: program)
                )
            )
        }
        
        return SuplaChannelWeeklyScheduleConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: crc32,
            programConfigurations: programConfigurations,
            schedule: schedule
        )
    }
}

protocol SuplaWeeklyScheduleProgramProtocol {
    var program: SuplaScheduleProgram { get }
    var description: String { get }
}

struct SuplaHvacWeeklyScheduleProgram: Equatable, SuplaWeeklyScheduleProgramProtocol {
    let program: SuplaScheduleProgram
    let mode: SuplaHvacMode
    let setpointTemperatureHeat: Int16?
    let setpointTemperatureCool: Int16?

    var description: String {
        let heatTemperature = setpointTemperatureHeat?.fromSuplaTemperature()
        let coolTemperature = setpointTemperatureCool?.fromSuplaTemperature()

        if program == .off {
            return Strings.General.turnOff
        } else if mode == .heat {
            return heatTemperature.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
        } else if mode == .cool {
            return coolTemperature.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
        } else if mode == .heatCool {
            let min = heatTemperature.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
            let max = coolTemperature.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
            return "\(min) - \(max)"
        } else {
            return NO_VALUE_TEXT
        }
    }

    func copy(
        mode: SuplaHvacMode? = nil,
        newHeatTemperature: Int16? = nil,
        newCoolTemperature: Int16? = nil
    ) -> SuplaHvacWeeklyScheduleProgram {
        SuplaHvacWeeklyScheduleProgram(
            program: program,
            mode: mode ?? self.mode,
            setpointTemperatureHeat: newHeatTemperature ?? setpointTemperatureHeat,
            setpointTemperatureCool: newCoolTemperature ?? setpointTemperatureCool
        )
    }

    static var OFF: SuplaHvacWeeklyScheduleProgram {
        SuplaHvacWeeklyScheduleProgram(program: .off, mode: .off, setpointTemperatureHeat: nil, setpointTemperatureCool: nil)
    }
}

struct SuplaRelayWeeklyScheduleProgram: Equatable, SuplaWeeklyScheduleProgramProtocol {
    let program: SuplaScheduleProgram
    let mode: SuplaRelayMode
    let modeDurationS: UInt16
    let oppositeModeDurationS: UInt16

    var description: String {
        if program == .off { return Strings.Schedule.programDefault }
        return mode.scheduleDescription(duration: modeDurationS, oppositeDuration: oppositeModeDurationS)
    }

    func copy(mode: SuplaRelayMode? = nil, modeDurationS: UInt16? = nil, oppositeModeDurationS: UInt16? = nil) -> SuplaRelayWeeklyScheduleProgram {
        SuplaRelayWeeklyScheduleProgram(
            program: program,
            mode: mode ?? self.mode,
            modeDurationS: modeDurationS ?? self.modeDurationS,
            oppositeModeDurationS: oppositeModeDurationS ?? self.oppositeModeDurationS
        )
    }

    static func `default`() -> SuplaRelayWeeklyScheduleProgram {
        SuplaRelayWeeklyScheduleProgram(program: .off, mode: .notSet, modeDurationS: 0, oppositeModeDurationS: 0)
    }
}

enum SuplaWeeklyScheduleProgramSet: Equatable {
    case hvac([SuplaHvacWeeklyScheduleProgram])
    case relay([SuplaRelayWeeklyScheduleProgram])

    var isEmpty: Bool {
        switch self {
        case .hvac(let programs): programs.isEmpty
        case .relay(let programs): programs.isEmpty
        }
    }

    var hvacPrograms: [SuplaHvacWeeklyScheduleProgram]? {
        guard case .hvac(let programs) = self else { return nil }
        return programs
    }

    var relayPrograms: [SuplaRelayWeeklyScheduleProgram]? {
        guard case .relay(let programs) = self else { return nil }
        return programs
    }
}

private extension SuplaRelayMode {
    func scheduleDescription(duration: UInt16?, oppositeDuration: UInt16?) -> String {
        switch self {
        case .notSet: NO_VALUE_TEXT
        case .startOn: relayDescription(Strings.General.turnOn, duration: duration, oppositeDuration: oppositeDuration)
        case .startOff: relayDescription(Strings.General.turnOff, duration: duration, oppositeDuration: oppositeDuration)
        case .forcedOn: Strings.Schedule.programForceOn
        case .forcedOff: Strings.Schedule.programForceOff
        case .automatic: Strings.RelaySchedule.modeAutomatic
        case .cmdWeeklySchedule, .cmdSwitchToManual: NO_VALUE_TEXT
        }
    }

    private func relayDescription(_ defaultValue: String, duration: UInt16?, oppositeDuration: UInt16?) -> String {
        let duration = duration ?? 0
        let oppositeDuration = oppositeDuration ?? 0
        if duration > 0 && oppositeDuration > 0 {
            return Strings.Schedule.programCycle
        }
        if duration > 0 {
            let format = self == .startOn ? Strings.Schedule.programTurnOnSeconds : Strings.Schedule.programTurnOffSeconds
            return format.arguments(Int(duration))
        }
        return defaultValue
    }
}

private extension Int32 {
    var isRelayScheduleFunction: Bool {
        switch self {
        case SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER,
             SUPLA_CHANNELFNC_PUMPSWITCH,
             SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
             SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            true
        default:
            false
        }
    }
}

struct SuplaWeeklyScheduleEntry: Equatable {
    let dayOfWeek: DayOfWeek
    let hour: UInt8
    let quarterOfHour: QuarterOfHour
    let program: SuplaScheduleProgram
}
