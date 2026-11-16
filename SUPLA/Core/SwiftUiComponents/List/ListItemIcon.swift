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

let DEFAULT_LIST_ITEM_ICON_WIDTH: CGFloat = 60
let DEFAULT_LIST_ITEM_ICON_HEIGHT: CGFloat = 50

struct ListItemIcon: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat
    
    let iconResult: IconResult?
    
    @ViewBuilder
    var body: some View {
        let iconWidth = scale(scaleFactor, DEFAULT_LIST_ITEM_ICON_WIDTH)
        let iconHeight = scale(scaleFactor, DEFAULT_LIST_ITEM_ICON_HEIGHT)
        
        Image()
            .resizable()
            .scaledToFit()
            .frame(width: iconWidth, height: iconHeight)
    }
    
    private func Image() -> SwiftUI.Image {
        if let iconResult = iconResult {
            iconResult.image
        } else {
            SwiftUI.Image(.Icons.fncUnknown)
        }
    }
}
