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

struct ButtonSize {
    let height: CGFloat
    let paddings: EdgeInsets
    
    private init(height: CGFloat, paddings: EdgeInsets) {
        self.height = height
        self.paddings = paddings
    }
    
    static let `default` = ButtonSize(height: Dimens.buttonHeight, paddings: .buttonDefault)
    static let small = ButtonSize(height: Dimens.buttonSmallHeight, paddings: .buttonSmall)
    static let icon = ButtonSize(height: Dimens.buttonHeight, paddings: .buttonIcon)
    static let iconSmall = ButtonSize(height: Dimens.buttonSmallHeight, paddings: .buttonIcon)
}

extension EdgeInsets {
    static let buttonDefault: EdgeInsets = .init(
        top: 10,
        leading: Distance.default,
        bottom: 10,
        trailing: Distance.default
    )
    
    static let buttonSmall: EdgeInsets = .init(
        top: 4,
        leading: Distance.default,
        bottom: 4,
        trailing: Distance.default
    )
    
    static let buttonIcon: EdgeInsets = .init(
        top: 8,
        leading: 8,
        bottom: 8,
        trailing: 8
    )
    
    static let buttonIconSmall: EdgeInsets = .init(
        top: 4,
        leading: 4,
        bottom: 4,
        trailing: 4
    )
}
