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

extension AddWizardFeature {
    struct AddWizardWifiNotice<Content: SwiftUI.View>: SwiftUI.View {
        let content: Content
        
        private let padding: EdgeInsets?

        init(padding: EdgeInsets? = nil, @ViewBuilder content: () -> Content) {
            self.padding = padding
            self.content = content()
        }

        var body: some SwiftUI.View {
            content
                .textColor(.Supla.onPrimaryContainer)
                .padding(padding ?? defaultPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Supla.surface.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault))
        }
        
        private let defaultPadding: EdgeInsets = .init(
            top: Distance.small,
            leading: Distance.default,
            bottom: Distance.small, trailing:
                Distance.default
        )
    }
}
