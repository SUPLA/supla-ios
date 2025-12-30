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

let OUTER_SURFACE_WIDTH: CGFloat = 5

struct ColorPickerView: View {
    let currentColor: UIColor?
    let currentSaturation: CGFloat?
    let currentHue: CGFloat?
    let enabled: Bool
    let markers: [HsvColor]
    let onDragStart: () -> Void
    let onDrag: (CGFloat, CGFloat) -> Void
    let onDragEnd: () -> Void

    @State private var didStartDrag = false

    init(
        currentColor: UIColor?,
        currentSaturation: CGFloat?,
        currentHue: CGFloat?,
        enabled: Bool = true,
        markers: [HsvColor] = [],
        onDragStart: @escaping () -> Void = {},
        onDrag: @escaping (CGFloat, CGFloat) -> Void = { _, _ in },
        onDragEnd: @escaping () -> Void = {}
    ) {
        self.currentColor = currentColor
        self.currentSaturation = currentSaturation
        self.currentHue = currentHue
        self.enabled = enabled
        self.markers = markers
        self.onDragStart = onDragStart
        self.onDrag = onDrag
        self.onDragEnd = onDragEnd
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let margin = SELECTOR_SHADOW_RADIUS - OUTER_SURFACE_WIDTH
            let minSide = min(size.width, size.height) / 2 - margin
            let radius = minSide - OUTER_SURFACE_WIDTH

            Canvas { context, _ in
                // 1) Surface around
                let surfacePath = Path(ellipseIn: CGRect(
                    x: center.x - minSide,
                    y: center.y - minSide,
                    width: minSide * 2,
                    height: minSide * 2
                ))
                context.fill(surfacePath, with: .color(Color(.systemBackground)))

                // 2) Hue wheel (Angular / sweep gradient)
                let hueGradient = Gradient(colors: [
                    .red, .yellow, .green, .cyan, .blue, Color(UIColor.magenta), .red
                ])
                let hueShading = GraphicsContext.Shading.conicGradient(
                    hueGradient,
                    center: center,
                    angle: .degrees(0)
                )

                let wheelRect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                let wheelPath = Path(ellipseIn: wheelRect)
                context.fill(wheelPath, with: hueShading)

                // 3) Saturation overlay (white -> transparent radial)
                let satGradient = Gradient(colors: [.white, .clear])
                let satShading = GraphicsContext.Shading.radialGradient(
                    satGradient,
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )
                context.fill(wheelPath, with: satShading)

                for m in markers {
                    let p = pointFor(
                        hue: m.hue,
                        saturation: m.saturation,
                        center: center,
                        radius: radius
                    )
                    drawMarkerPoint(context: &context, position: p)
                }

                if enabled,
                   let sat = currentSaturation,
                   let hue = currentHue,
                   let color = currentColor {

                    let p = pointFor(
                        hue: hue,
                        saturation: sat,
                        center: center,
                        radius: radius
                    )
                    drawSelectorPoint(context: &context, position: p, color: Color(color))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard enabled else { return }

                        if !didStartDrag {
                            didStartDrag = true
                            onDragStart()
                        }

                        let (h, s) = calculateHueAndSaturation(
                            point: value.location,
                            center: center,
                            radius: radius
                        )
                        onDrag(h, s)
                    }
                    .onEnded { value in
                        guard enabled else {
                            didStartDrag = false
                            return
                        }

                        let (h, s) = calculateHueAndSaturation(
                            point: value.location,
                            center: center,
                            radius: radius
                        )
                        onDrag(h, s)
                        onDragEnd()
                        didStartDrag = false
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private func pointFor(
    hue: CGFloat,
    saturation: CGFloat,
    center: CGPoint,
    radius: CGFloat
) -> CGPoint {
    let r = radius * saturation
    let angle = hue.toRadians()
    return CGPoint(
        x: center.x + r * cos(angle),
        y: center.y + r * sin(angle)
    )
}

private func calculateHueAndSaturation(
    point: CGPoint,
    center: CGPoint,
    radius: CGFloat
) -> (hue: CGFloat, saturation: CGFloat) {
    let dx = point.x - center.x
    let dy = point.y - center.y

    var angle = atan2(dy, dx)
    if angle < 0 { angle += 2 * .pi }

    let hue = angle * 180 / .pi
    let dist = sqrt(dx*dx + dy*dy)
    let sat = min(max(dist / radius, 0), 1)

    return (hue, sat)
}


private extension CGFloat {
    func toRadians() -> CGFloat { self * .pi / 180 }
    func toDegrees() -> CGFloat { self * 180 / .pi }
}

#Preview {
    ZStack {
        ColorPickerView(
            currentColor: UIColor.red,
            currentSaturation: 1,
            currentHue: 0
        )
    }
    .background(Color.mint)
}
