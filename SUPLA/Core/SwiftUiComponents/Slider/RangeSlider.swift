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
    struct RangeSlider<LowerThumb: View, UpperThumb: View>: View {
        @Binding var lower: CGFloat
        @Binding var upper: CGFloat
        let thumbSize: CGFloat
        let lowerThumb: () -> LowerThumb
        let upperThumb: () -> UpperThumb
        
        init(
            lower: Binding<CGFloat>,
            upper: Binding<CGFloat>,
            thumbSize: CGFloat,
            lowerThumb: @escaping () -> LowerThumb,
            upperThumb: @escaping () -> UpperThumb
        ) {
            self._lower = lower
            self._upper = upper
            self.thumbSize = thumbSize
            self.lowerThumb = lowerThumb
            self.upperThumb = upperThumb
        }
        
        init(
            lower: Binding<CGFloat>,
            upper: Binding<CGFloat>
        ) where LowerThumb == AnyView, UpperThumb == AnyView {
            self._lower = lower
            self._upper = upper
            self.thumbSize = SuplaCore.DefaultThumb.size
            self.lowerThumb = { AnyView(SuplaCore.DefaultThumb()) }
            self.upperThumb = { AnyView(SuplaCore.DefaultThumb()) }
        }
        
        var body: some View {
            GeometryReader { geo in
                let width = geo.size.width - thumbSize
                        
                ZStack(alignment: .leading) {
                    // track
                    Capsule()
                        .fill(Color.Supla.outline)
                        .padding(.horizontal, thumbSize / 2)
                        .frame(height: 4)
                            
                    // selected range
                    Capsule()
                        .fill(Color.green)
                        .frame(
                            width: max(0, width * (upper - lower)),
                            height: 4
                        )
                        .offset(x: width * lower + thumbSize / 2)
                            
                    // left thumb
                    lowerThumb()
                        .offset(x: width * lower)
                        .gesture(
                            DragGesture().onChanged { g in
                                let val = (g.location.x - (thumbSize / 2)) / width
                                lower = min(max(0, val), upper)
                            }
                        )
                            
                    // right thumb
                    upperThumb()
                        .offset(x: width * upper)
                        .gesture(
                            DragGesture().onChanged { g in
                                let val = (g.location.x - (thumbSize / 2)) / width
                                upper = max(min(1, val), lower)
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
    @Previewable @State var lower: CGFloat = 0.1
    @Previewable @State var upper: CGFloat = 0.6
    VStack {
        SuplaCore.RangeSlider(lower: $lower, upper: $upper)
        SuplaCore.RangeSlider(
            lower: $lower,
            upper: $upper,
            thumbSize: SuplaCore.HeatingThumb.size,
            lowerThumb: { SuplaCore.HeatingThumb() },
            upperThumb: { SuplaCore.CoolingThumb() }
        )
    }
    .padding(Distance.default)
}
