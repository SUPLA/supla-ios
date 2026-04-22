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
    
extension SuplaCore {
    struct DefaultThumb: View {
        var body: some View {
            Circle()
                .fill(Color.white)
                .frame(width: DefaultThumb.size, height: DefaultThumb.size)
                .shadow(radius: 4, y: 2)
        }
        
        static let size: CGFloat = 24
    }
    
    struct HeatingThumb: View {
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.Supla.error.opacity(0.4))
                    .frame(width: HeatingThumb.size, height: HeatingThumb.size)
                Circle()
                    .fill(Color.Supla.error)
                    .frame(width: HeatingThumb.internSize, height: HeatingThumb.internSize)
                Image(.Icons.heat)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
            }
        }
        
        static let size: CGFloat = 32
        private static let internSize: CGFloat = 24
    }
    
    struct CoolingThumb: View {
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.Supla.secondary.opacity(0.4))
                    .frame(width: CoolingThumb.size, height: CoolingThumb.size)
                Circle()
                    .fill(Color.Supla.secondary)
                    .frame(width: CoolingThumb.internSize, height: CoolingThumb.internSize)
                Image(.Icons.cool)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
            }
        }
        
        static let size: CGFloat = 32
        private static let internSize: CGFloat = 24
    }
}
