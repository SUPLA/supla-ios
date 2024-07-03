//
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

struct Text {
    protocol SuplaText: View {}
    
    struct HeadlineSmall: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        var color: Color = Color.Supla.onBackground
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.headlineSmall)
                    .foregroundStyle(color)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.headlineSmall)
                    .foregroundColor(color)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodyLarge: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        var color: Color = Color.Supla.onBackground

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodyLarge)
                    .foregroundStyle(color)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodyLarge)
                    .foregroundColor(color)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodyMedium: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        var color: Color = Color.Supla.onBackground

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodyMedium)
                    .foregroundStyle(color)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodyMedium)
                    .foregroundColor(color)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodySmall: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        var color: Color = Color.Supla.onBackground

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodySmall)
                    .foregroundStyle(color)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodySmall)
                    .foregroundColor(color)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct LabelLarge: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        var color: Color = Color.Supla.onPrimary
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.labelLarge)
                    .foregroundStyle(color)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.labelLarge)
                    .foregroundColor(color)
                    .multilineTextAlignment(alignment)
            }
        }
    }
}
