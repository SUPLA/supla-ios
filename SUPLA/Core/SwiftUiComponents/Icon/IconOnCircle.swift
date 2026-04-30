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

extension Icon {
    struct OnCircle {
        enum IconType {
            case warning
            case error
            case info
            case timeout

            var resource: String {
                switch (self) {
                case .warning: .Icons.warningTemplate
                case .error: .Icons.warningTemplate
                case .info: .Icons.checkFilled
                case .timeout: .Icons.hourglass
                }
            }

            var color: Color {
                switch (self) {
                case .warning: .Supla.tertiary
                case .error: .Supla.error
                case .info, .timeout: .Supla.primary
                }
            }

            var background: Color {
                switch (self) {
                case .warning: .Supla.tertiaryContainer
                case .error: .Supla.errorContainer
                case .info, .timeout: .Supla.surfaceVariant
                }
            }
        }

        struct View: SwiftUI.View {
            let type: IconType

            var body: some SwiftUI.View {
                ZStack {
                    Circle()
                        .fill(type.background)

                    Image(type.resource)
                        .renderingMode(.template)
                        .foregroundColor(type.color)
                }
                .frame(width: 80, height: 80)
            }
        }
    }
}
