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

enum SuplaRollerShutterFlag: Int16, CaseIterable, Equatable {
    case tiltIsSet = 0
    case calibrationFailed = 1
    case calibrationLost = 2
    case motorProblem = 3
    case calibrationInProgress = 4

    var value: Int16 { 1 << rawValue }
    
    var issueIconType: IssueIconType? {
        switch (self) {
        case .motorProblem: .error
        case .calibrationLost, .calibrationFailed: .warning
        default: nil
        }
    }
    
    var issueDescription: String? {
        switch (self) {
        case .motorProblem: Strings.RollerShutterDetail.motorProblem
        case .calibrationLost: Strings.RollerShutterDetail.calibrationLost
        case .calibrationFailed: Strings.RollerShutterDetail.calibrationFailed
        default: nil
        }
    }
    
    var issueFlag: Bool {
        switch (self) {
        case .motorProblem, .calibrationLost, .calibrationFailed: true
        default: false
        }
    }
    
    static func from(flags: Int16) -> [SuplaRollerShutterFlag] {
        var result: [SuplaRollerShutterFlag] = []
        
        for flag in SuplaRollerShutterFlag.allCases {
            if (flag.value & flags > 0) {
                result.append(flag)
            }
        }
        
        return result
    }
}
