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
    struct Divider: View {
        let orientation: Orientation
        
        init(_ orientation: Orientation = .horizontal) {
            self.orientation = orientation
        }
        
        var body: some View {
            SwiftUI.Divider()
                .frame(width: orientation.width, height: orientation.height)
                .overlay(Color.Supla.outline)
        }
        
        func color(_ color: Color) -> some View {
            self.foregroundColor(color)
        }
        
        func color(_ color: UIColor) -> some View {
            self.foregroundColor(Color(color))
        }
        
        enum Orientation {
            case horizontal, vertical
            
            var width: CGFloat? {
                switch self {
                case .horizontal: return nil
                case .vertical: return 1
                }
            }
            
            var height: CGFloat? {
                switch self {
                case .horizontal: return 1
                case .vertical: return nil
                }
            }
        }
    }
}
