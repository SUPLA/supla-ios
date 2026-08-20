//
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
import CoreFoundation

extension Font {
    enum Supla {
        static let displayLarge: Font = .custom(FontName.OpenSans.Light, size: FontSize.displayLarge)
        static let displayMedium: Font = .custom(FontName.OpenSans.Regular, size: FontSize.displayMedium)
        static let displaySmall: Font = .custom(FontName.OpenSans.Regular, size: FontSize.displaySmall)

        static let headlineLarge: Font = .custom(FontName.OpenSans.Regular, size: FontSize.headlineLarge)
        static let headlineMedium: Font = .custom(FontName.OpenSans.Regular, size: FontSize.headlineMedium)
        static let headlineSmall: Font = .custom(FontName.OpenSans.Regular, size: FontSize.headlineSmall)

        static let titleLarge: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.titleLarge)
        static let titleMedium: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.titleMedium)
        static let titleSmall: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.titleSmall)

        static let bodyLarge: Font = .custom(FontName.OpenSans.Regular, size: FontSize.bodyLarge)
        static let bodyMedium: Font = .custom(FontName.OpenSans.Regular, size: FontSize.bodyMedium)
        static let bodySmall: Font = .custom(FontName.OpenSans.Regular, size: FontSize.bodySmall)
        static let bodySmallBold: Font = .custom(FontName.OpenSans.Bold, size: FontSize.bodySmall)
        static let bodySmallSemiBold: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.bodySmall)

        static let labelLarge: Font = .custom(FontName.OpenSans.Medium, size: FontSize.labelLarge)
        static let labelMedium: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.labelMedium)
        static let labelSmall: Font = .custom(FontName.OpenSans.SemiBold, size: FontSize.labelSmall)

        static let captionSmall: Font = .custom(FontName.OpenSans.Regular, size: 9)

        static func bodyMedium(_ scale: CGFloat, limit: CellScalingLimit = .none) -> Font {
            .custom(FontName.OpenSans.Regular, size: scale.scale(FontSize.bodyMedium, limit: limit))
        }

        static func listItemCaption(_ scale: CGFloat) -> Font {
            .custom(FontName.OpenSans.Bold, size: scale.scale(Dimens.Fonts.caption, limit: .lower(1)))
        }

        static func listItemValue(_ scale: CGFloat) -> Font {
            .custom(FontName.OpenSans.Regular, size: scale.scale(Dimens.Fonts.value, limit: .lower(1)))
        }
    }
}
