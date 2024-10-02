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

extension Font {
    enum Supla {
        static let displayLarge: Font = .custom("OpenSans-Light", size: 60)
        static let displayMedium: Font = .custom("OpenSans", size: 48)
        static let displaySmall: Font = .custom("OpenSans", size: 34)

        static let headlineLarge: Font = .custom("OpenSans", size: 34)
        static let headlineMedium: Font = .custom("OpenSans", size: 24)
        static let headlineSmall: Font = .custom("OpenSans", size: 17)

        static let titleLarge: Font = .custom("OpenSans", size: 22)
        static let titleMedium: Font = .custom("OpenSans-SemiBold", size: 16)
        static let titleSmall: Font = .custom("OpenSans-SemiBold", size: 14)

        static let bodyLarge: Font = .custom("OpenSans", size: 16)
        static let bodyMedium: Font = .custom("OpenSans", size: 14)
        static let bodySmall: Font = .custom("OpenSans", size: 12)

        static let labelLarge: Font = .custom("OpenSans-Medium", size: 17)
        static let labelMedium: Font = .custom("OpenSans-SemiBold", size: 14)
        static let labelSmall: Font = .custom("OpenSans-SemiBold", size: 10)

        static func cellValue(_ scale: CGFloat, limit: CellScalingLimit = .none) -> Font {
            .custom("Quicksand-Regular", size: scale.scale(Dimens.Fonts.value, limit: limit))
        }

        static func cellSubValue(_ scale: CGFloat, limit: CellScalingLimit = .none) -> Font {
            .custom("OpenSans", size: scale.scale(Dimens.Fonts.label, limit: limit))
        }

        static func cellCaption(_ scale: CGFloat, limit: CellScalingLimit = .none) -> Font {
            .custom("OpenSans-Bold", size: scale.scale(Dimens.Fonts.caption, limit: limit))
        }
    }
}
