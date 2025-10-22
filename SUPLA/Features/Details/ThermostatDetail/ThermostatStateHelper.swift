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
    
enum ThermostatStateHelper {
    static func endDateText(_ timerEndDate: Date?) -> String {
        guard let date = timerEndDate else { return "" }
        
        @Singleton<ValuesFormatter> var formatter
        let dateString = formatter.getFullDateString(date: date) ?? ""
        return Strings.TimerDetail.stateLabelForTimerDays.arguments(dateString)
    }
    
    static func currentStateIcon(_ mode: SuplaHvacMode?) -> String? { mode?.icon }
    
    static func currentStateIconColor(_ mode: SuplaHvacMode?) -> UIColor { mode?.iconColor ?? .disabled }
    
    static func currentStateValue(_ mode: SuplaHvacMode?, heatSetpoint: Float?, coolSetpoint: Float?) -> String {
        return switch (mode) {
        case .off: "OFF"
        case .heat: heatSetpoint.toTemperatureString()
        case .cool: coolSetpoint.toTemperatureString()
        default: ""
        }
    }
}
