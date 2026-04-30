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


struct TitleButton: View {
    let title: String
    let fullWidth: Bool
    let size: ButtonSize
    let action: () -> Void

    init(
        title: String,
        fullWidth: Bool = false,
        size: ButtonSize = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.fullWidth = fullWidth
        self.size = size
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(action: action) {
            Text(title)
                .fontLabelLarge()
                .padding(size.paddings)
                .if(fullWidth) { $0.frame(maxWidth: .infinity) }
                .frame(minHeight: size.height)
        }
    }
}

extension View {
    func buttonPaddings(
        top: CGFloat = 10,
        leading: CGFloat = Distance.default,
        bottom: CGFloat = 10,
        trailing: CGFloat = Distance.default
    ) -> some View {
        self.padding(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
}

#Preview {
    VStack {
        TitleButton(title: "Title", action: {})
            .borderedButtonStyle()
        TitleButton(title: "Title", action: {})
            .borderedButtonStyle()
            .disabled(true)
        TitleButton(title: "Title", action: {})
            .borderedButtonStyle(colors: .criticalBordered)
    }
}
