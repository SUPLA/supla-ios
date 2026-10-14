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

struct SuplaButtonColors {
    static let buttonColors = SuplaButtonColors(
        border: .Supla.outline,
        borderPressed: .Supla.primary,
        borderDisabled: Color(UIColor.outlineVariant),
        borderDisabledAndPressed: Color(UIColor.outlineVariant),
        content: .Supla.onBackground,
        contentPressed: .Supla.onBackground,
        contentDisabled: .Supla.outline,
        shadow: .black,
        shadowPressed: .Supla.primary
    )

    static let primaryColors = SuplaButtonColors(
        border: .Supla.outline,
        borderPressed: .Supla.primary,
        borderDisabled: Color(UIColor.outlineVariant),
        borderDisabledAndPressed: Color(UIColor.outlineVariant),
        content: .Supla.onBackground,
        contentPressed: .Supla.primary,
        contentDisabled: .Supla.outline,
        shadow: .black,
        shadowPressed: .Supla.primary
    )

    static let errorColors = SuplaButtonColors(
        border: .Supla.outline,
        borderPressed: .Supla.error,
        borderDisabled: Color(UIColor.outlineVariant),
        borderDisabledAndPressed: Color(UIColor.outlineVariant),
        content: .Supla.onBackground,
        contentPressed: .Supla.error,
        contentDisabled: .Supla.outline,
        shadow: .black,
        shadowPressed: .Supla.error
    )

    static let secondaryColors = SuplaButtonColors(
        border: .Supla.outline,
        borderPressed: .Supla.secondary,
        borderDisabled: Color(UIColor.outlineVariant),
        borderDisabledAndPressed: Color(UIColor.outlineVariant),
        content: .Supla.onBackground,
        contentPressed: .Supla.secondary,
        contentDisabled: .Supla.outline,
        shadow: .black,
        shadowPressed: .Supla.secondary
    )

    let border: Color
    let borderPressed: Color
    let borderDisabled: Color
    let borderDisabledAndPressed: Color
    let content: Color
    let contentPressed: Color
    let contentDisabled: Color
    let shadow: Color
    let shadowPressed: Color

    func copy(
        border: Color? = nil,
        borderPressed: Color? = nil,
        borderDisabled: Color? = nil,
        borderDisabledAndPressed: Color? = nil,
        content: Color? = nil,
        contentPressed: Color? = nil,
        contentDisabled: Color? = nil,
        shadow: Color? = nil,
        shadowPressed: Color? = nil
    ) -> SuplaButtonColors {
        SuplaButtonColors(
            border: border ?? self.border,
            borderPressed: borderPressed ?? self.borderPressed,
            borderDisabled: borderDisabled ?? self.borderDisabled,
            borderDisabledAndPressed: borderDisabledAndPressed ?? self.borderDisabledAndPressed,
            content: content ?? self.content,
            contentPressed: contentPressed ?? self.contentPressed,
            contentDisabled: contentDisabled ?? self.contentDisabled,
            shadow: shadow ?? self.shadow,
            shadowPressed: shadowPressed ?? self.shadowPressed
        )
    }

    func border(active: Bool, disabled: Bool) -> Color {
        switch (disabled, active) {
        case (true, true): return borderDisabledAndPressed
        case (true, false): return borderDisabled
        case (false, true): return borderPressed
        case (false, false): return border
        }
    }

    func content(active: Bool, disabled: Bool) -> Color {
        if (disabled) {
            return contentDisabled
        } else if (active) {
            return contentPressed
        } else {
            return content
        }
    }
}
