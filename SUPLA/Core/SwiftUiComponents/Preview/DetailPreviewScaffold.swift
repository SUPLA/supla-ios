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

struct DetailPreviewScaffold<Content: SwiftUI.View>: SwiftUI.View {
    private let content: Content
    private let mainTabBarWidth: CGFloat = 84
    private let mainTabBarHeight: CGFloat = 56

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some SwiftUI.View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Color.Supla.primary
                    .frame(height: SuplaCore.TopBar.height)

                if (geometry.size.width > geometry.size.height) {
                    HStack(spacing: 0) {
                        Color.Supla.surface
                            .frame(width: mainTabBarWidth)

                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Color.Supla.surface
                            .frame(height: mainTabBarHeight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
