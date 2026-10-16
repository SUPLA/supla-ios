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

enum OperationButtonsStyle: Equatable {
    case text
    case icons
}

private let automaticModePadding = EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)

struct OperationButtons: View {
    let manualAllowed: Bool
    let manualActive: Bool
    let weeklyAllowed: Bool
    let weeklyActive: Bool
    let autoAllowed: Bool
    let autoActive: Bool
    var style: OperationButtonsStyle = .text

    let delegate: OperationButtonsDelegate?

    var body: some View {
        HStack(spacing: Distance.tiny) {
            if (manualAllowed) {
                OperationButton(
                    style: style,
                    text: Strings.ThermostatDetail.modeManual,
                    icon: .suplaIcon(name: .Icons.manual),
                    active: manualActive,
                    action: { delegate?.onManual() }
                )
            }

            if (weeklyAllowed) {
                OperationButton(
                    style: style,
                    text: Strings.ThermostatDetail.modeWeeklySchedule,
                    icon: .suplaIcon(name: .Icons.schedule),
                    active: weeklyActive,
                    action: { delegate?.onWeekly() }
                )
            }

            if (autoAllowed) {
                OperationButton(
                    style: style,
                    text: Strings.RelaySchedule.modeAutomatic,
                    iconLabel: "A",
                    active: autoActive,
                    action: { delegate?.onAuto() }
                )
            }
        }
    }
}

struct OperationButton: View {
    let style: OperationButtonsStyle
    let text: String
    var icon: IconResult? = nil
    var iconLabel: String? = nil
    let active: Bool
    let action: () -> Void

    var body: some View {
        if (style == .icons), let icon {
            SuplaButton(
                icon,
                colors: .primaryColors,
                active: active,
                action: action
            )
        } else {
            SuplaButton(
                style == .icons ? (iconLabel ?? "A") : text,
                colors: .primaryColors,
                active: active,
                fullWidth: style == .text,
                padding: style == .icons ? automaticModePadding : roundedPadding,
                action: action
            )
        }
    }
}

#Preview {
    VStack {
        OperationButtons(
            manualAllowed: true,
            manualActive: true,
            weeklyAllowed: true,
            weeklyActive: false,
            autoAllowed: true,
            autoActive: false,
            delegate: nil
        )

        OperationButtons(
            manualAllowed: true,
            manualActive: true,
            weeklyAllowed: true,
            weeklyActive: false,
            autoAllowed: true,
            autoActive: false,
            style: .icons,
            delegate: nil
        )
    }
}
