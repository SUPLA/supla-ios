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

enum LockIconType {
    case closed
    case opened
    case temporaryClosed

    var assetName: String {
        switch self {
        case .closed: "icon_lock_closed"
        case .opened: "icon_lock_open_right"
        case .temporaryClosed: "icon_lock_temporary"
        }
    }
}

struct LockSuplaButton: View {
    let pressed: Bool
    let type: LockIconType
    let onClick: () -> Void

    init(
        disabled: Bool = false,
        pressed: Bool = false,
        type: LockIconType = .closed,
        onClick: @escaping () -> Void
    ) {
        self.pressed = pressed
        self.type = type
        self.onClick = onClick
    }

    var body: some View {
        SuplaButton(
            colors: .primaryColors.copy(borderDisabledAndPressed: .Supla.primary),
            active: pressed,
            padding: roundedPadding,
            action: onClick,
        ) {
            Image(type.assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
        }
    }
}

#Preview {
    HStack(spacing: Distance.default) {
        LockSuplaButton(type: .closed, onClick: {})
        LockSuplaButton(pressed: true, type: .opened, onClick: {})
        LockSuplaButton(type: .temporaryClosed, onClick: {})
        LockSuplaButton(type: .closed, onClick: {}).disabled(true)
        LockSuplaButton(pressed: true, type: .closed, onClick: {}).disabled(true)
    }
    .padding(Distance.default)
}
