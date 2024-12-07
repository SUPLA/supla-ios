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

extension View {
    func textColor(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            return foregroundStyle(color)
        } else {
            return foregroundColor(color)
        }
    }
    
    func fontCaptionSmall() -> some View {
        font(.Supla.captionSmall)
            .textCase(.uppercase)
    }
    
    func fontBodyMedium() -> some View {
        font(.Supla.bodyMedium)
    }
}

struct Text {
    protocol SuplaText: View {}
    
    struct HeadlineLarge: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.headlineLarge)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.headlineLarge)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct HeadlineSmall: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.headlineSmall)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.headlineSmall)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct TitleMedium: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.titleMedium)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.titleMedium)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodyLarge: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodyLarge)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodyLarge)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodyMedium: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodyMedium)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodyMedium)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct BodySmall: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.bodySmall)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.bodySmall)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct LabelLarge: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.labelLarge)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.labelLarge)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct LabelMedium: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.labelMedium)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.labelMedium)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct LabelSmall: SuplaText {
        var text: String
        var alignment: SwiftUI.TextAlignment = .center
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(.Supla.labelSmall)
                    .multilineTextAlignment(alignment)
            } else {
                SwiftUI.Text(text)
                    .font(.Supla.labelSmall)
                    .multilineTextAlignment(alignment)
            }
        }
    }
    
    struct CellValue: SuplaText {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat
        
        var text: String
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(Font.Supla.cellValue(scaleFactor, limit: .lower(1)))
                    .foregroundStyle(Color.Supla.onBackground)
            } else {
                SwiftUI.Text(text)
                    .font(Font.Supla.cellValue(scaleFactor, limit: .lower(1)))
                    .foregroundColor(Color.Supla.onBackground)
            }
        }
    }
    
    struct CellCaption: SuplaText {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat
        
        var text: String
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .lineLimit(1)
                    .font(Font.Supla.cellCaption(scaleFactor, limit: .lower(1)))
                    .foregroundStyle(Color.Supla.onBackground)
            } else {
                SwiftUI.Text(text)
                    .lineLimit(1)
                    .font(Font.Supla.cellCaption(scaleFactor, limit: .lower(1)))
                    .foregroundColor(Color.Supla.onBackground)
            }
        }
    }
    
    struct CellSubValue: SuplaText {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat
        
        var text: String
        
        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text)
                    .font(Font.Supla.cellSubValue(scaleFactor, limit: .lower(1)))
                    .foregroundStyle(Color.Supla.onBackground)
            } else {
                SwiftUI.Text(text)
                    .font(Font.Supla.cellSubValue(scaleFactor, limit: .lower(1)))
                    .foregroundColor(Color.Supla.onBackground)
            }
        }
    }
    
    struct PickerLabel: SuplaText {
        var text: String

        var body: some View {
            if #available(iOS 15.0, *) {
                SwiftUI.Text(text.uppercased())
                    .font(.Supla.bodySmall)
                    .textColor(Color.Supla.onSurfaceVariant)
            } else {
                SwiftUI.Text(text.uppercased())
                    .font(.Supla.bodySmall)
                    .textColor(Color.Supla.onSurfaceVariant)
            }
        }
    }
}
