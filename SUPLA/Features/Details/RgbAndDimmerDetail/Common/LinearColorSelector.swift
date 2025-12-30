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

struct LinearColorSelector: View {
    let value: CGFloat?
    let selectedColor: UIColor?
    let valueMarkers: [CGFloat]
    let enabled: Bool
    let startColor: Color
    let endColor: Color
    let onValueChangeStarted: () -> Void
    let onValueChanging: (CGFloat) -> Void
    let onValueChanged: () -> Void

    @State private var didStartDrag = false

    init(
        value: CGFloat?,
        selectedColor: UIColor?,
        valueMarkers: [CGFloat] = [],
        enabled: Bool = true,
        startColor: Color = .white,
        endColor: Color = .black,
        onValueChangeStarted: @escaping () -> Void = {},
        onValueChanging: @escaping (CGFloat) -> Void = { _ in },
        onValueChanged: @escaping () -> Void = {}
    ) {
        self.value = value
        self.selectedColor = selectedColor
        self.valueMarkers = valueMarkers
        self.enabled = enabled
        self.startColor = startColor
        self.endColor = endColor
        self.onValueChangeStarted = onValueChangeStarted
        self.onValueChanging = onValueChanging
        self.onValueChanged = onValueChanged
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let verticalMargin = SELECTOR_SHADOW_RADIUS - SELECTOR_RADIUS - OUTER_SURFACE_WIDTH
            let outerMargin = OUTER_SURFACE_WIDTH
            let sliderWidth = max(0, size.width - outerMargin * 2)
            let sliderHeight = max(0, size.height - outerMargin * 2 - verticalMargin * 2)
            let outerRect = CGRect(
                x: 0,
                y: verticalMargin,
                width: size.width,
                height: size.height - verticalMargin * 2
            )
            let innerRect = CGRect(
                x: outerMargin,
                y: outerMargin + verticalMargin,
                width: sliderWidth,
                height: sliderHeight
            )

            Canvas { context, _ in
                let surfacePath = RoundedRectangle(cornerRadius: 9).path(in: outerRect)
                context.fill(surfacePath, with: .color(Color(.systemBackground)))

                let gradient = Gradient(colors: [startColor, endColor])
                let shading = GraphicsContext.Shading.linearGradient(
                    gradient,
                    startPoint: CGPoint(x: innerRect.midX, y: innerRect.minY),
                    endPoint: CGPoint(x: innerRect.midX, y: innerRect.maxY)
                )

                let sliderPath = RoundedRectangle(cornerRadius: 5).path(in: innerRect)
                context.fill(sliderPath, with: shading)

                for m in valueMarkers {
                    let y = selectorY(
                        value: m,
                        outerMargin: outerMargin + verticalMargin,
                        sliderHeight: sliderHeight,
                        selectorRadius: SELECTOR_RADIUS
                    )
                    let p = CGPoint(x: size.width / 2, y: y)
                    drawMarkerPoint(context: &context, position: p)
                }

                if enabled, let v = value, let color = selectedColor {
                    let y = selectorY(
                        value: v,
                        outerMargin: outerMargin + verticalMargin,
                        sliderHeight: sliderHeight,
                        selectorRadius: SELECTOR_RADIUS
                    )
                    let p = CGPoint(x: size.width / 2, y: y)
                    drawSelectorPoint(context: &context, position: p, color: Color(color))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        guard enabled else { return }

                        if !didStartDrag {
                            didStartDrag = true
                            onValueChangeStarted()
                        }

                        let newVal = valueFromTouch(
                            y: g.location.y,
                            height: size.height
                        )
                        onValueChanging(newVal)
                    }
                    .onEnded { g in
                        guard enabled else {
                            didStartDrag = false
                            return
                        }

                        let newVal = valueFromTouch(
                            y: g.location.y,
                            height: size.height
                        )
                        onValueChanging(newVal)
                        onValueChanged()
                        didStartDrag = false
                    }
            )
        }
    }
}

// MARK: - Geometry helpers

private func valueFromTouch(y: CGFloat, height: CGFloat) -> CGFloat {
    guard height > 0 else { return 0 }
    let t = (y / height).clamped(to: 0...1)
    return 1 - t
}

private func selectorY(
    value: CGFloat,
    outerMargin: CGFloat,
    sliderHeight: CGFloat,
    selectorRadius: CGFloat
) -> CGFloat {
    let v = value.clamped(to: 0...1)
    let available = max(0, sliderHeight - selectorRadius * 2)
    return outerMargin + selectorRadius + (1 - v) * available
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearColorSelector(
            value: 1, selectedColor: UIColor.red
        )
        .frame(width: 40, height: 300)
    }
    .background(Color.mint)
}
