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

enum ListValueAggregation: Int, PickerItem, CaseIterable, Codable {
    case noAggregation
    case last24Hours
    case last7Days
    case last30Days
    case last90Days
    case last365Days
    case currentHour
    case currentDay
    case currentWeek
    case currentMonth
    case currentYear
    
    var id: Int { rawValue }

    var label: String {
        switch self {
        case .noAggregation: Strings.ImpulseCounter.counterStatus
        case .last24Hours: Strings.Charts.lastDay
        case .last7Days: Strings.Charts.lastWeek
        case .last30Days: Strings.Charts.last30Days
        case .last90Days: Strings.Charts.last90Days
        case .last365Days: Strings.Charts.last365Days
        case .currentHour: Strings.General.currentHour
        case .currentDay: Strings.General.currentDay
        case .currentWeek: Strings.General.currentWeek
        case .currentMonth: Strings.General.currentMonth
        case .currentYear: Strings.General.currentYear
        }
    }

    func aggregationStartDate(currentDate: Date) -> Date? {
        let calendar = Calendar.current

        switch self {
        case .last24Hours:
            let date = calendar.date(byAdding: .hour, value: -23, to: currentDate)!
            return calendar.date(
                bySettingHour: calendar.component(.hour, from: date),
                minute: 0,
                second: 0,
                of: date
            )
        case .last7Days:
            return calendar.date(byAdding: .day, value: -6, to: currentDate)?.dayStart()
        case .last30Days:
            return calendar.date(byAdding: .day, value: -29, to: currentDate)?.dayStart()
        case .last90Days:
            return calendar.date(byAdding: .day, value: -89, to: currentDate)?.dayStart()
        case .last365Days:
            return calendar.date(byAdding: .day, value: -364, to: currentDate)?.dayStart()
        case .currentHour:
            return calendar.date(
                bySettingHour: calendar.component(.hour, from: currentDate),
                minute: 0,
                second: 0,
                of: currentDate
            )
        case .currentDay:
            return currentDate.dayStart()
        case .currentWeek:
            return currentDate.weekStart()
        case .currentMonth:
            return currentDate.monthStart()
        case .currentYear:
            return currentDate.yearStart()
        case .noAggregation:
            return nil
        }
    }
}
