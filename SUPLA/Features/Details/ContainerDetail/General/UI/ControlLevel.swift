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
    
import SwiftUI

enum ControlLevel {
    case alarm(level: CGFloat, levelString: String, type: ControlLevelType)
    case warning(level: CGFloat, levelString: String, type: ControlLevelType)
    
    var color: Color {
        switch self {
        case .alarm: Color.Supla.error
        case .warning: Color(UIColor(argb: 0xFFE3A400))
        }
    }
    
    var level: CGFloat {
        switch self {
        case let .alarm(level, _, _): level
        case let .warning(level, _, _): level
        }
    }
    
    var type: ControlLevelType {
        switch self {
        case let .alarm(_, _, type): type
        case let .warning(_, _, type): type
        }
    }
    
    var levelString: String {
        switch self {
        case let .alarm(_, levelString, _): levelString
        case let .warning(_, levelString, _): levelString
        }
    }
    
    var isAlarm: Bool {
        switch self {
        case .alarm: true
        case .warning: false
        }
    }
    
    var isWarning: Bool {
        switch self {
        case .alarm: false
        case .warning: true
        }
    }
    
    var isUpper: Bool {
        switch self {
        case let .alarm(_, _, type): type == .upper
        case let .warning(_, _, type): type == .upper
        }
    }
    
    var isLower: Bool {
        switch self {
        case let .alarm(_, _, type): type == .lower
        case let .warning(_, _, type): type == .lower
        }
    }
}

enum ControlLevelType {
    case upper, lower
}
