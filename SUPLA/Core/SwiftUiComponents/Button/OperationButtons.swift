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

protocol OperationButtonsDelegate {
    func onManual()
    func onWeekly()
    func onAuto()
}

struct OperationButtons: View {
    let manualAllowed: Bool
    let manualActive: Bool
    let weeklyAllowed: Bool
    let weeklyActive: Bool
    let autoAllowed: Bool
    let autoActive: Bool

    let delegate: OperationButtonsDelegate?

    var body: some View {
        HStack(spacing: Distance.tiny) {
            if (manualAllowed) {
                SuplaButton(
                    Strings.ThermostatDetail.modeManual,
                    colors: .primaryColors,
                    active: manualActive,
                    fullWidth: true,
                    padding: roundedPadding,
                    action: { delegate?.onManual() }
                )
            }

            if (weeklyAllowed) {
                SuplaButton(
                    Strings.ThermostatDetail.modeWeeklySchedule,
                    colors: .primaryColors,
                    active: weeklyActive,
                    fullWidth: true,
                    padding: roundedPadding,
                    action: { delegate?.onWeekly() }
                )
            }

            if (autoAllowed) {
                SuplaButton(
                    Strings.RelaySchedule.modeAutomatic,
                    colors: .primaryColors,
                    active: autoActive,
                    fullWidth: true,
                    padding: roundedPadding,
                    action: { delegate?.onAuto() }
                )
            }
        }
        .padding([.leading, .trailing], Distance.default)
    }
}

#Preview {
    OperationButtons(
        manualAllowed: true,
        manualActive: true,
        weeklyAllowed: true,
        weeklyActive: false,
        autoAllowed: true,
        autoActive: false,
        delegate: nil
    )
}
