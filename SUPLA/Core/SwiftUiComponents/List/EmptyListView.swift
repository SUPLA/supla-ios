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

struct EmptyListView: View {
    let size: SizeClass
    
    init(size: SizeClass = .normal) {
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(String.Icons.empty)
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .frame(width: size.iconSize, height: size.iconSize)
                .foregroundColor(Color.Supla.onSurfaceVariant)
            Text(Strings.Main.noEntries)
                .if(size == .normal) { $0.fontHeadlineLarge() }
                .if(size == .small) { $0.fontTitleLarge() }
        }
    }
    
    enum SizeClass {
        case normal
        case small
    }
}

private extension EmptyListView.SizeClass {
    var iconSize: CGFloat {
        switch (self) {
        case .normal: 64
        case .small: 32
        }
    }
}

#Preview {
    VStack {
        EmptyListView()
        EmptyListView(size: .small)
    }
}
