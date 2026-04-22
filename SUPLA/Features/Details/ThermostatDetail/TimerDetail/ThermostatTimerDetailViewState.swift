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

extension ThermostatTimerDetailFeature {
    class ViewState: ObservableObject {
        @Published var isTimerRunning: Bool = false
        @Published var isTimerEditing: Bool = false
        
        @Published var availableModes: [DeviceMode] = []
        @Published var selectedMode: DeviceMode = .off
        @Published var timeSelectionMode: TimeSelectionMode = .timer
        @Published var timerDays: DayPickerItem = 0.asDayPickerItem
        @Published var timerHours: HourPickerItem = 3.asHourPickerItem
        @Published var timerMinutes: NumberPickerItem = 0.asMinutePickerItem
        @Published var calendarDate: Date = Date().shift(days: 7)
        @Published var plusDisabled: Bool = true
        @Published var minusDisabled: Bool = true
        
        @Published var heatValue: CGFloat
        @Published var coolValue: CGFloat
        @Published var setpointInChange: SetpointType
        
        @Published var deviceStateData: DeviceState.Data? = nil
        @Published var timerEndTime: Date? = nil
        
        @Published var loadingState: LoadingState = .init()
        @Published var offline: Bool = true
        
        var configMin: Float = 0
        var configMax: Float = 0
        var heatSetpoint: Float = 0
        var coolSetpoint: Float = 0
        
        init(
            isTimersRunning: Bool = false,
            availableModes: [DeviceMode] = [],
            selectedMode: DeviceMode = .off,
            timeSelectionMode: TimeSelectionMode = .timer,
            timerDays: DayPickerItem = 0.asDayPickerItem,
            timerHours: HourPickerItem = 3.asHourPickerItem,
            timerMinutes: NumberPickerItem = 0.asMinutePickerItem,
            heatValue: CGFloat = 0,
            coolValue: CGFloat = 0,
            setpointInChange: SetpointType = .heat,
            deviceStateData: DeviceState.Data? = nil,
            timerEndTime: Date? = nil,
            loadingState: LoadingState = .init(),
            offline: Bool = true
        ) {
            self.isTimerRunning = isTimersRunning
            self.availableModes = availableModes
            self.selectedMode = selectedMode
            self.timeSelectionMode = timeSelectionMode
            self.timerDays = timerDays
            self.timerHours = timerHours
            self.timerMinutes = timerMinutes
            self.heatValue = heatValue
            self.coolValue = coolValue
            self.setpointInChange = setpointInChange
            self.deviceStateData = deviceStateData
            self.timerEndTime = timerEndTime
            self.loadingState = loadingState
            self.offline = offline
        }
        
        var setpointValue: String {
            switch (selectedMode) {
            case .off: return ""
            case .heating: return heatSetpoint.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
            case .cooling: return coolSetpoint.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
            case .auto:
                let heatString = heatSetpoint.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
                let coolString = coolSetpoint.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
                return "\(heatString) - \(coolString)"
            }
        }
        
        var startDisabled: Bool { offline || getTimerDuration() <= 0 }
        
        var timerInfoText: String {
            let timeDiff = getTimerDuration()
            if (timeDiff < 0) { return "" }
                
            let days = timeDiff.days
            let hours = timeDiff.hoursInDay
            let minutes = timeDiff.minutesInHour
                
            let daysString =
                switch (days) {
                case 0: ""
                case 1: Strings.TimerDetail.dayPattern.arguments(days)
                default: Strings.TimerDetail.daysPattern.arguments(days)
                }
            let hoursString =
                switch (hours) {
                case 0: ""
                case 1: Strings.TimerDetail.hourPattern.arguments(hours)
                default: Strings.TimerDetail.hourPattern.arguments(hours)
                }
            let minutesString = minutes == 0 ? "" : Strings.TimerDetail.minutePattern.arguments(minutes)
            
            let timeString = "\(daysString) \(hoursString) \(minutesString)".trimmingCharacters(in: .whitespaces)
            if (timeString.isEmpty) {
                return ""
            }
                
            switch (selectedMode) {
            case .off:
                return Strings.TimerDetail.infoThermostatOff.arguments(timeString)
            case .heating:
                return Strings.TimerDetail.infoThermostatHeating.arguments(timeString)
            case .cooling:
                return Strings.TimerDetail.infoThermostatCooling.arguments(timeString)
            case .auto:
                return Strings.TimerDetail.infoThermostatAuto.arguments(timeString)
            }
        }
        
        func updateValues() {
            heatValue = CGFloat((heatSetpoint - configMin) / (configMax - configMin)).clamped(to: 0...1)
            coolValue = CGFloat((coolSetpoint - configMin) / (configMax - configMin)).clamped(to: 0...1)
        }
        
        func getTimerDuration(_ date: Date? = nil) -> Int {
            @Singleton<DateProvider> var dateProvider
            let currentDate = if let date { date } else { dateProvider.currentDate() }
            
            return if (timeSelectionMode == .calendar) {
                calendarDate.differenceInSeconds(currentDate)
            } else {
                timerMinutes.id * 60 + timerHours.id * 3600 + timerDays.id * 86_400
            }
        }
    }
    
    enum DeviceMode: Int, PickerItem {
        case off = 0
        
        case auto = 1
        case heating = 2
        case cooling = 3
        
        var id: Int { rawValue }
        
        var label: String {
            switch self {
            case .off: Strings.General.turnOff
            case .auto: "Auto"
            case .heating: Strings.ThermostatDetail.modeHeatingLabel
            case .cooling: Strings.ThermostatDetail.modeCoolingLabel
            }
        }
        
        var hvacMode: SuplaHvacMode {
            switch self {
            case .off: .off
            case .auto: .heatCool
            case .heating: .heat
            case .cooling: .cool
            }
        }
        
        static func modsFor(_ function: Int32, subfunction: ThermostatSubfunction) -> [DeviceMode] {
            switch (function) {
            case SUPLA_CHANNELFNC_HVAC_THERMOSTAT:
                switch (subfunction) {
                case .heat: [.off, .heating]
                case .cool: [.off, .cooling]
                case .notSet: []
                }
            case SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER: [.off, .heating]
            case SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL: [.off, .auto, .heating, .cooling]
            default: []
            }
        }
    }
    
    enum TimeSelectionMode {
        case timer
        case calendar
        
        var alternative: Self {
            switch self {
            case .timer: .calendar
            case .calendar: .timer
            }
        }
        
        var icon: String {
            switch self {
            case .timer: .Icons.timer
            case .calendar: .Icons.schedule
            }
        }
        
        var label: String {
            switch self {
            case .timer: Strings.TimerDetail.counter
            case .calendar: Strings.TimerDetail.calendar
            }
        }
    }
}
