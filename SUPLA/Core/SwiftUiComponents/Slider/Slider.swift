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
    struct Slider<Thumb: View>: View {
        @Binding var value: CGFloat // 0...1
        let thumbSize: CGFloat
        let thumb: () -> Thumb
        
        init(value: Binding<CGFloat>, thumbSize: CGFloat, thumb: @escaping () -> Thumb) {
            self._value = value
            self.thumbSize = thumbSize
            self.thumb = thumb
        }
        
        init(value: Binding<CGFloat>) where Thumb == AnyView {
            self._value = value
            self.thumbSize = SuplaCore.DefaultThumb.size
            self.thumb = { AnyView(SuplaCore.DefaultThumb()) }
        }
        
        var body: some View {
            GeometryReader { geo in
                let width = geo.size.width - thumbSize
                
                ZStack(alignment: .leading) {
                    
                    // Track
                    Capsule()
                        .fill(Color.Supla.outline)
                        .padding(.horizontal, thumbSize / 2)
                        .frame(height: 4)
                    
                    // Thumb
                    thumb()
                        .offset(x: width * value)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    let newValue = (gesture.location.x - (thumbSize / 2)) / width
                                    value = min(max(0, newValue), 1)
                                }
                        )
                }
            }
            .frame(height: thumbSize)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var value: CGFloat = 0
    VStack {
        SuplaCore.Slider(value: $value)
        SuplaCore.Slider(
            value: $value,
            thumbSize: SuplaCore.HeatingThumb.size,
            thumb: { SuplaCore.HeatingThumb() }
        )
        SuplaCore.Slider(
            value: $value,
            thumbSize: SuplaCore.CoolingThumb.size,
            thumb: { SuplaCore.CoolingThumb() }
        )
    }
    .padding(Distance.default)
}
