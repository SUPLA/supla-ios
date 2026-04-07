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

private let DEFAULT_HEAT_TEMPERATURE: Float = 21
private let DEFAULT_WATER_TEMPERATURE: Float = 40
    
extension ThermostatScheduleDetailFeature {
    class ViewState: ObservableObject {
        @Published var programs: [ScheduleDetailProgram] = []
        @Published var activeProgram: SuplaScheduleProgram? = nil
        @Published var schedule: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [:]
        @Published var currentDay: DayOfWeek? = nil
        @Published var currentHour: Int? = nil
        
        @Published var changing: Bool = false
        @Published var showHelp: Bool = false
        @Published var lastInteractionTime: TimeInterval? = nil
        @Published var channelFunction: Int32? = nil
        @Published var thermostatSubfunction: ThermostatSubfunction? = nil
        @Published var configMin: Float? = nil
        @Published var configMax: Float? = nil
        
        @Published var editProgramState: EditProgramState? = nil
        @Published var editQuartersState: EditQuartersState? = nil
        
        var suplaPrograms: [SuplaWeeklyScheduleProgram] {
            programs.filter { $0.scheduleProgram.program != .off }
                .map { $0.scheduleProgram }
        }
        
        var suplaSchedule: [SuplaWeeklyScheduleEntry] {
            schedule.flatMap { (key, value) in value.suplaScheduleEntries(key) }
        }
        
        var thermostatType: ThermostatType? {
            if (isHeat) {
                return .heat
            } else if (isCool) {
                return .cool
            } else {
                return nil
            }
        }
        
        private var isHvacThermostat: Bool { channelFunction == SUPLA_CHANNELFNC_HVAC_THERMOSTAT }
        private var isHotWater: Bool { channelFunction == SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER }
        
        private var isHeat: Bool { isHvacThermostat && thermostatSubfunction == .heat || isHotWater }
        private var isCool: Bool { isHvacThermostat && thermostatSubfunction == .cool }
        
        init(
            programs: [ScheduleDetailProgram] = [],
            activeProgram: SuplaScheduleProgram? = nil,
            schedule: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [:],
            currentDay: DayOfWeek? = nil,
            currentHour: Int? = nil
        ) {
            self.programs = programs
            self.activeProgram = activeProgram
            self.schedule = schedule
            self.currentDay = currentDay
            self.currentHour = currentHour
        }
        
        func temperature(_ program: SuplaWeeklyScheduleProgram) -> Float? {
            if (isHeat) {
                let suplaTemperature = program.setpointTemperatureHeat?.fromSuplaTemperature()
                return alignTemperature(suplaTemperature)
            } else if (isCool) {
                let suplaTemperature = program.setpointTemperatureCool?.fromSuplaTemperature()
                return alignTemperature(suplaTemperature)
            } else {
                return nil
            }
        }
        
        func temperatureString(_ value: Float) -> String {
            return SharedCore.DefaultValueFormatter.shared.format(value: value)
        }
        
        private func alignTemperature(_ temperature: Float?) -> Float {
            let defaultTemperature = isHotWater ? DEFAULT_WATER_TEMPERATURE : DEFAULT_HEAT_TEMPERATURE
            let temperatureToAlign = temperature ?? defaultTemperature
            
            if let configMin, let configMax {
                return temperatureToAlign.clamped(to: configMin ... configMax)
            } else {
                return temperatureToAlign
            }
        }
    }
}

private extension ThermostatScheduleDetailBoxValue {
    func suplaScheduleEntries(_ key: ScheduleDetailBoxKey) -> [SuplaWeeklyScheduleEntry] {
        QuarterOfHour.allCases
            .map {
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: key.dayOfWeek,
                    hour: UInt8(key.hour),
                    quarterOfHour: $0,
                    program: programForQuarter($0)
                )
            }
    }
}
