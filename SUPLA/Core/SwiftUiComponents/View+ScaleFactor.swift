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

extension EnvironmentValues {
    @Entry var scaleFactor: CGFloat = 1.0
}

extension View {
    func scale(
        _ scaleFactor: CGFloat,
        _ value: CGFloat,
        limit: CellScalingLimit = .none
    ) -> CGFloat {
        internScale(scaleFactor, value, limit: limit)
    }
}

extension CGFloat {
    func scale(
        _ value: CGFloat,
        limit: CellScalingLimit = .none
    ) -> CGFloat {
        return internScale(self, value, limit: limit)
    }
}

private func internScale(
    _ scaleFactor: CGFloat,
    _ value: CGFloat,
    limit: CellScalingLimit = .none
) -> CGFloat {
    var scale = scaleFactor
    switch (limit) {
    case .lower(let val):
        if (scaleFactor < val) { scale = val }
    case .upper(let val):
        if (scaleFactor > val) { scale = val }
    default: break
    }

    return value * scale
}
