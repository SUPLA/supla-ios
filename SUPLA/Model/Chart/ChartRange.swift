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

enum ChartRange: CaseIterable, Codable {
    case lastDay
    case lastWeek
    case lastMonth
    case lastQuarter
    
    case day
    case week
    case month
    case quarter
    case year
    
    case custom
    case allHistory
    
    var roundedDaysCount: Int {
        get {
            switch (self) {
            case .lastDay, .day: 1
            case .lastWeek, .week: 7
            case .lastMonth, .month: 30
            case .lastQuarter, .quarter: 90
            case .year: 365
            case .custom, .allHistory: -1
            }
        }
    }
    
    var label: String {
        get {
            switch (self) {
            case .lastDay: Strings.Charts.lastDay
            case .lastWeek: Strings.Charts.lastWeek
            case .lastMonth: Strings.Charts.last30Days
            case .lastQuarter: Strings.Charts.last90Days
                
            case .day: Strings.Charts.day
            case .week: Strings.Charts.week
            case .month: Strings.Charts.month
            case .quarter: Strings.Charts.quarter
            case .year: Strings.Charts.year
                
            case .custom: Strings.Charts.custom
            case .allHistory: Strings.Charts.allHistory
            }
        }
    }
}
