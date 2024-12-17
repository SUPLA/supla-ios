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
    
    func fontLabelSmall() -> some View {
        font(.Supla.labelSmall)
    }
    
    func fontLabelMedium() -> some View {
        font(.Supla.labelMedium)
    }
    
    func fontLabelLarge() -> some View {
        font(.Supla.labelLarge)
    }
    
    func fontBodySmall() -> some View {
        font(.Supla.bodySmall)
    }
    
    func fontBodyMedium() -> some View {
        font(.Supla.bodyMedium)
    }
    
    func fontBodyLarge() -> some View {
        font(.Supla.bodyLarge)
    }
    
    func fontTitleMedium() -> some View {
        font(.Supla.titleMedium)
    }
    
    func fontHeadlineSmall() -> some View {
        font(.Supla.headlineSmall)
    }
    
    func fontHeadlineLarge() -> some View {
        font(.Supla.headlineLarge)
    }
    
    func fontPickerLabel() -> some View {
        font(.Supla.bodySmall)
            .foregroundColor(Color.Supla.onSurfaceVariant)
    }
}

struct CellValue: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat
    
    var text: String
    
    var body: some View {
        SwiftUI.Text(text)
            .font(Font.Supla.cellValue(scaleFactor, limit: .lower(1)))
            .foregroundColor(Color.Supla.onBackground)
    }
}

struct CellCaption: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat
    
    var text: String
    
    var body: some View {
        SwiftUI.Text(text)
            .lineLimit(1)
            .font(Font.Supla.cellCaption(scaleFactor, limit: .lower(1)))
            .foregroundColor(Color.Supla.onBackground)
    }
}

struct CellSubValue: View {
    @Environment(\.scaleFactor) var scaleFactor: CGFloat
    
    var text: String
    
    var body: some View {
        SwiftUI.Text(text)
            .font(Font.Supla.cellSubValue(scaleFactor, limit: .lower(1)))
            .foregroundColor(Color.Supla.onBackground)
    }
}
