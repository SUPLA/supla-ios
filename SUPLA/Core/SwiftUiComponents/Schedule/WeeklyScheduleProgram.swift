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

struct WeeklyScheduleProgram: Equatable, Changeable, Identifiable {
    var id: UInt8 { program.rawValue }

    let program: SuplaScheduleProgram
    let label: String
    var icon: String?

    var text: String { label }

    init(program: SuplaScheduleProgram, label: String, icon: String? = nil) {
        self.program = program
        self.label = label
        self.icon = icon
    }

    init(program: any SuplaWeeklyScheduleProgramProtocol, icon: String? = nil, label: String? = nil) {
        self.init(program: program.program, label: label ?? program.description, icon: icon)
    }

    func buttonState(_ activeProgram: SuplaScheduleProgram?) -> ScheduleProgramButtonState {
        if program == activeProgram {
            return .active(color: program.color, label: text, icon: icon)
        }
        return .default(color: program.color, label: text, icon: icon)
    }
}
