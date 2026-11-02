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

struct ListItemDot: View {
    let onlineState: ListOnlineState
    let withButton: Bool

    init(onlineState: ListOnlineState, withButton: Bool = false) {
        self.onlineState = onlineState
        self.withButton = withButton
    }

    var body: some View {
        if (onlineState == .partiallyOnline && withButton) {
            ZStack {
                partialDotHalf(color: .Supla.primary, half: .top)
                partialDotHalf(color: .Supla.error, half: .bottom)
            }
            .frame(
                width: Dimens.ListItem.statusIndicatorSize,
                height: Dimens.ListItem.statusIndicatorSize
            )
        } else {
            Circle()
                .stroke(color, lineWidth: 1)
                .background(withButton ? Circle().fill(color) : Circle().fill(Color.clear))
                .frame(
                    width: Dimens.ListItem.statusIndicatorSize,
                    height: Dimens.ListItem.statusIndicatorSize
                )
        }
    }

    private var color: Color {
        switch (onlineState) {
        case .online, .partiallyOnline: .Supla.primary
        case .updating: .Supla.secondary
        case .unknown: .Supla.onSurfaceVariant
        case .offline: .Supla.error
        }
    }

    private func partialDotHalf(color: Color, half: DotHalf) -> some View {
        Circle()
            .fill(color)
            .frame(
                width: Dimens.ListItem.statusIndicatorSize,
                height: Dimens.ListItem.statusIndicatorSize
            )
            .mask(
                VStack(spacing: 0) {
                    if (half == .bottom) {
                        Spacer(minLength: 0)
                    }
                    Rectangle()
                        .frame(height: Dimens.ListItem.statusIndicatorSize / 2)
                    if (half == .top) {
                        Spacer(minLength: 0)
                    }
                }
            )
    }

    private enum DotHalf {
        case top, bottom
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Distance.tiny) {
        ListItemDot(onlineState: .online, withButton: true)
        ListItemDot(onlineState: .online)
        ListItemDot(onlineState: .offline, withButton: true)
        ListItemDot(onlineState: .offline)
        ListItemDot(onlineState: .partiallyOnline, withButton: true)
        ListItemDot(onlineState: .partiallyOnline)
        ListItemDot(onlineState: .updating, withButton: true)
        ListItemDot(onlineState: .updating)
        ListItemDot(onlineState: .unknown, withButton: true)
        ListItemDot(onlineState: .unknown)
    }
    .padding()
    .background(Color.Supla.background)
}
