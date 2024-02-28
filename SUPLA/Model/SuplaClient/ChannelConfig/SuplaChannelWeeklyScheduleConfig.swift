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

final class SuplaChannelWeeklyScheduleConfig: SuplaChannelConfig {
    
    let programConfigurations: [SuplaWeeklyScheduleProgram]
    let schedule: [SuplaWeeklyScheduleEntry]
    
    init(remoteId: Int32, channelFunc: Int32?, programConfigurations: [SuplaWeeklyScheduleProgram], schedule: [SuplaWeeklyScheduleEntry]) {
        self.programConfigurations = programConfigurations
        self.schedule = schedule
        super.init(remoteId: remoteId, channelFunc: channelFunc)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    static func from(remoteId: Int32, channelFunc: Int32?, suplaConfig: TChannelConfig_WeeklySchedule) -> SuplaChannelWeeklyScheduleConfig {
        
        var programConfigurations: [SuplaWeeklyScheduleProgram] = []
        let size = SUPLA_WEEKLY_SCHEDULE_PROGRAMS_MAX_SIZE
        for programId in 0..<size {
            let program = SuplaConfigIntegrator.getProgramWith(programId, fromConfig: suplaConfig)
            programConfigurations.append(
                SuplaWeeklyScheduleProgram(
                    program: SuplaScheduleProgram.from(value: UInt8(programId + 1)),
                    mode: SuplaHvacMode.from(hvacMode: program.Mode),
                    setpointTemperatureHeat: program.SetpointTemperatureHeat,
                    setpointTemperatureCool: program.SetpointTemperatureCool
                )
            )
        }
        
        var schedule: [SuplaWeeklyScheduleEntry] = []
        for index in 0..<SuplaConfigIntegrator.suplaWeeklyScheduleValuesSize(suplaConfig) {
            let dayOfWeek = (index / 2 / 24) % 7
            let hour = (index / 2) % 24
            let quarterOfHour = (index % 2) * 2
            let program = SuplaConfigIntegrator.getQuarterProgram(for: index, inConfig: suplaConfig)
            
            schedule.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: DayOfWeek.from(value: UInt8(dayOfWeek)),
                    hour: UInt8(hour),
                    quarterOfHour: QuarterOfHour.from(value: UInt8(quarterOfHour + 1)),
                    program: SuplaScheduleProgram.from(value: program & 0xF)
                )
            )
            schedule.append(
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: DayOfWeek.from(value: UInt8(dayOfWeek)),
                    hour: UInt8(hour),
                    quarterOfHour: QuarterOfHour.from(value: UInt8(quarterOfHour + 2)),
                    program: SuplaScheduleProgram.from(value: (program & 0xF0) >> 4)
                )
            )
        }
        
        return SuplaChannelWeeklyScheduleConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            programConfigurations: programConfigurations,
            schedule: schedule
        )
    }
}

struct SuplaWeeklyScheduleProgram: Equatable {
    let program: SuplaScheduleProgram
    let mode: SuplaHvacMode
    let setpointTemperatureHeat: Int16?
    let setpointTemperatureCool: Int16?
    
    var description: String {
        get {
            @Singleton<ValuesFormatter> var valuesFormatter
            let heatTemperature = setpointTemperatureHeat?.fromSuplaTemperature()
            let coolTemperature = setpointTemperatureCool?.fromSuplaTemperature()
            
            if (program == .off) {
                return Strings.General.turnOff
            } else if (mode == .heat) {
                return valuesFormatter.temperatureToString(heatTemperature, withUnit: false)
            } else if (mode == .cool) {
                return valuesFormatter.temperatureToString(coolTemperature, withUnit: false)
            } else if (mode == .auto) {
                let min = valuesFormatter.temperatureToString(heatTemperature, withUnit: false)
                let max = valuesFormatter.temperatureToString(coolTemperature, withUnit: false)
                return "\(min) - \(max)"
            } else {
                return NO_VALUE_TEXT
            }
        }
    }
    
    func copy(newHeatTemperature: Int16? = nil, newCoolTemperature: Int16? = nil) -> SuplaWeeklyScheduleProgram {
        return SuplaWeeklyScheduleProgram(
            program: program,
            mode: mode,
            setpointTemperatureHeat: newHeatTemperature == nil ? setpointTemperatureHeat : newHeatTemperature,
            setpointTemperatureCool: newCoolTemperature == nil ? setpointTemperatureCool : newCoolTemperature
        )
    }
    
    static var OFF: SuplaWeeklyScheduleProgram {
        get {
            SuplaWeeklyScheduleProgram(
                program: .off,
                mode: .off,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: nil
            )
        }
    }
}

struct SuplaWeeklyScheduleEntry: Equatable {
    let dayOfWeek: DayOfWeek
    let hour: UInt8
    let quarterOfHour: QuarterOfHour
    let program: SuplaScheduleProgram
}
