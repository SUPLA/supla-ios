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

enum ListItemRectColors {
    case online, active

    var top: Color {
        switch (self) {
        case .online: .Supla.error
        case .active: .Supla.surface
        }
    }

    var bottom: Color {
        .Supla.primary
    }
}

struct ListItemRect: View {
    let percentage: CGFloat
    let colors: ListItemRectColors

    var body: some View {
        let boundedPercentage = min(max(percentage, 0), 1)
        GeometryReader { geometry in
            VStack(spacing: 0) {
                colors.top
                    .frame(height: geometry.size.height * (1 - boundedPercentage))
                colors.bottom
                    .frame(height: geometry.size.height * boundedPercentage)
            }
        }
        .frame(width: 6, height: 25)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.Supla.onBackground, lineWidth: 0.5)
        )
    }
}

#Preview {
    HStack(spacing: Distance.tiny) {
        ListItemRect(percentage: 0, colors: .active)
        ListItemRect(percentage: 0.25, colors: .active)
        ListItemRect(percentage: 1, colors: .active)
        ListItemRect(percentage: 0, colors: .online)
        ListItemRect(percentage: 0.25, colors: .online)
        ListItemRect(percentage: 1, colors: .online)
    }
    .padding()
    .background(Color.Supla.background)
}
