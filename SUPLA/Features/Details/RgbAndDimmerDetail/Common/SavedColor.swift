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

struct SavedColor: ReorderableHStackItem {
    var id: Int { Int(idx) }
    
    let idx: Int32
    let color: UIColor
    let brightness: Int32
}

struct SavedColorAction: SwiftUI.View {
    let dragging: Bool
    let over: Bool

    var body: some SwiftUI.View {
        let color: Color = over ? .Supla.error : .Supla.onSurfaceVariant
        let iconSize: CGFloat = dragging ? 16 : 12
        let icon: String = dragging ? .Icons.delete : .Icons.plus

        ZStack {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .tint(color)
                .foregroundColor(color)
        }
        .frame(width: 42, height: 36)
        .overlay(
            RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                .stroke(color, lineWidth: 1)
        )
        .padding(Distance.tiny)
    }
}

struct SavedColorBox: SwiftUI.View {
    let color: UIColor

    var body: some SwiftUI.View {
        RoundedRectangle(cornerRadius: Dimens.radiusSmall)
            .fill(Color(color))
            .frame(width: 42, height: 36)
            .overlay(
                RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                    .stroke(Color.Supla.onSurfaceVariant, lineWidth: 1)
            )
            .padding(Distance.tiny)
    }
}
