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

struct ThermostatProgramInfo: Equatable {
    let type: InfoType
    let time: String?
    let icon: UIImage?
    let iconColor: UIColor?
    let description: String?
    let manualActive: Bool
    
    enum InfoType {
        case current, next
        
        func text() -> String {
            switch (self) {
            case .current: return Strings.ThermostatDetail.programCurrent
            case .next: return Strings.ThermostatDetail.programNext
            }
        }
    }
    
    class Builder {
        var config: SuplaChannelWeeklyScheduleConfig? = nil
        var thermostatFlags: [SuplaThermostatFlag]? = nil
        var currentMode: SuplaHvacMode? = nil
        var currentTemperature: Float? = nil
        var channelOnline: Bool? = nil
        
        fileprivate var currentDayOfWeek: DayOfWeek? = nil
        fileprivate var currentHour: Int? = nil
        fileprivate var currentMinute: Int? = nil
        
        fileprivate var foundCurrentProgram: SuplaScheduleProgram? = nil
        fileprivate var foundNextProgram: SuplaScheduleProgram? = nil
        fileprivate var quartersToNextProgram: Int? = nil
    }
}

extension ThermostatProgramInfo.Builder {
    func build() -> [ThermostatProgramInfo] {
        guard let config = config else { fatalError("Config cannot be null") }
        guard let flags = thermostatFlags else { fatalError("Thermostat flags cannot be null") }
        guard let _ = currentMode else { fatalError("Current mode cannot be null") }
        guard let _ = currentTemperature else { fatalError("Current temperature cannot be null") }
        guard let isOnline = channelOnline else { fatalError("Channel online cannot be null") }
        
        @Singleton<DateProvider> var dateProvider
        
        if (!isOnline || config.schedule.isEmpty || config.programConfigurations.isEmpty) {
            return []
        }
        if (!flags.contains(.weeklySchedule)) {
            return []
        }
        if (flags.contains(.clockError)) {
            return clockErrorList()
        }
        
        currentDayOfWeek = dateProvider.currentDayOfWeek()
        currentHour = dateProvider.currentHour()
        currentMinute = dateProvider.currentMinute()
        
        identifyPrograms()
        
        if (quartersToNextProgram == nil || foundNextProgram == nil) {
            return []
        }
        
        return createList()
    }
    
    fileprivate func identifyPrograms() {
        let currentQuarter = QuarterOfHour.from(minute: currentMinute!)
        
        var idx = 0
        while (true) {
            let entry = config!.schedule[idx % config!.schedule.count]
            if (foundCurrentProgram != nil) {
                if (entry.program != foundCurrentProgram) {
                    foundNextProgram = entry.program
                    break
                }
                
                quartersToNextProgram! += 1
            }
            if (entry.dayOfWeek == currentDayOfWeek && entry.hour == currentHour! && entry.quarterOfHour == currentQuarter) {
                foundCurrentProgram = entry.program
                quartersToNextProgram = 0
            }
            
            idx += 1
            if (idx > config!.schedule.count * 2) {
                break
            }
        }
    }
    
    fileprivate func clockErrorList() -> [ThermostatProgramInfo] {
        @Singleton<ValuesFormatter> var valuesFormatter
        
        return [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.clockError,
                icon: currentMode?.icon,
                iconColor: currentMode?.iconColor,
                description: valuesFormatter.temperatureToString(currentTemperature, withUnit: false, withDegree: false),
                manualActive: false
            )
        ]
    }
    
    fileprivate func createList() -> [ThermostatProgramInfo] {
        @Singleton<ValuesFormatter> var valuesFormatter
        
        let minutesToNextProgram = quartersToNextProgram! * 15 + (15 - (currentMinute! % 15))
        let nextScheduleProgram = getProgram(program: foundNextProgram)
        let currentTemperatureString = valuesFormatter.temperatureToString(currentTemperature, withUnit: false, withDegree: false)
        
        return [
            ThermostatProgramInfo(
                type: .current,
                time: Strings.ThermostatDetail.programTime.arguments(
                    valuesFormatter.minutesToString(minutes: minutesToNextProgram)
                ),
                icon: currentMode!.icon,
                iconColor: currentMode!.iconColor,
                description: currentMode == .off ? nil : currentTemperatureString,
                manualActive: thermostatFlags!.contains(.weeklyScheduleTemporalOverride)
            ),
            ThermostatProgramInfo(
                type: .next,
                time: nil,
                icon: nextScheduleProgram?.mode.icon,
                iconColor: nextScheduleProgram?.mode.iconColor,
                description: nextScheduleProgram?.description,
                manualActive: false
            )
        ]
    }
    
    fileprivate func getProgram(program: SuplaScheduleProgram?) -> SuplaWeeklyScheduleProgram? {
        if (program == .off) {
            return SuplaWeeklyScheduleProgram.OFF
        } else {
            return config!.programConfigurations.first { $0.program == program }
        }
    }
}
