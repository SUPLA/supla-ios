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
import CoreGraphics

private let TRACK_WIDTH: CGFloat = 24

struct CircularColorSelector: View {
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
    @State private var gesturePrevValue: CGFloat? = nil
    @State private var isActiveGesture: Bool = false

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
            let minDim = min(size.width, size.height)
            let outerMargin = OUTER_SURFACE_WIDTH
            let outerRadius = minDim / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            let ringRadius = max(0, outerRadius - outerMargin - TRACK_WIDTH / 2)

            Canvas { context, _ in
                guard ringRadius > 0 else { return }

                let outerRect = CGRect(
                    x: center.x - ringRadius,
                    y: center.y - ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                )
                var surfacePath = Circle().path(in: outerRect)
                surfacePath = surfacePath.strokedPath(.init(lineWidth: TRACK_WIDTH + OUTER_SURFACE_WIDTH * 2, lineCap: .round))
                context.fill(surfacePath, with: .color(Color(.systemBackground)))

                let ringRect = CGRect(
                    x: -ringRadius,
                    y: -ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                )
                var ringPath = Circle().path(in: ringRect)
                ringPath = ringPath.strokedPath(.init(lineWidth: TRACK_WIDTH, lineCap: .round))

                context.drawLayer { ctx in
                    ctx.translateBy(x: center.x, y: center.y)
                    ctx.rotate(by: .degrees(-90))
                    let gradient = Gradient(colors: [endColor, startColor])
                    ctx.fill(ringPath, with: .conicGradient(gradient, center: CGPoint(x: 0, y: 0)))
                }

                for m in valueMarkers {
                    let p = pointOnCircle(center: center, radius: ringRadius, angleDeg: valueToAngle(m))
                    drawMarkerPoint(context: &context, position: p)
                }

                if enabled, let v = value, let c = selectedColor {
                    let p = pointOnCircle(center: center, radius: ringRadius, angleDeg: valueToAngle(v))
                    drawSelectorPoint(context: &context, position: p, color: Color(c))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        guard enabled, ringRadius > 0 else { return }

                        if !didStartDrag {
                            let ok = isInRing(
                                touch: g.location,
                                center: center,
                                ringRadius: ringRadius,
                                slop: SELECTOR_RADIUS
                            )
                            isActiveGesture = ok
                            didStartDrag = true

                            if ok {
                                gesturePrevValue = value?.clamped(to: 0...1)
                                onValueChangeStarted()
                            }
                        }

                        guard isActiveGesture else { return }

                        if let newVal = valueFromTouch(point: g.location, center: center) {
                            onValueChanging(applySeamLock(newValue: newVal))
                        }
                    }
                    .onEnded { g in
                        defer {
                            didStartDrag = false
                            isActiveGesture = false
                            gesturePrevValue = nil
                        }
                        guard enabled, isActiveGesture, ringRadius > 0 else { return }

                        if let newVal = valueFromTouch(point: g.location, center: center) {
                            onValueChanging(applySeamLock(newValue: newVal))
                        }
                        onValueChanged()
                    }
            )
        }
    }

    // MARK: - Interaction helpers

    private func valueFromTouch(point: CGPoint, center: CGPoint) -> CGFloat? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angleRad = atan2(dy, dx)

        let angleDeg = angleRad * 180 / .pi
        return angleToValue(angleDeg).clamped(to: 0...1)
    }

    private func isInRing(
        touch: CGPoint,
        center: CGPoint,
        ringRadius: CGFloat,
        slop: CGFloat
    ) -> Bool {
        let d = hypot(touch.x - center.x, touch.y - center.y)
        let inner = ringRadius - TRACK_WIDTH / 2 - slop
        let outer = ringRadius + TRACK_WIDTH / 2 + slop
        return d >= inner && d <= outer
    }

    private func applySeamLock(newValue: CGFloat) -> CGFloat {
        var v = newValue.clamped(to: 0...1)
        if let prev = gesturePrevValue {
            let nearHigh = prev > 0.85
            let nearLow = prev < 0.15
            let jumpedHighToLow = nearHigh && v < 0.15
            let jumpedLowToHigh = nearLow && v > 0.85

            if jumpedHighToLow { v = 1 }
            if jumpedLowToHigh { v = 0 }
        }
        gesturePrevValue = v
        return v
    }

    // MARK: - Angle/value mapping (jak w Kotlin)

    private func valueToAngle(_ value: CGFloat) -> CGFloat {
        let v = value.clamped(to: 0...1)
        return -90 + (v) * 360
    }

    private func angleToValue(_ angleDeg: CGFloat) -> CGFloat {
        let fromTop = normalizeDegrees(angleDeg + 90) // 0..360
        return fromTop / 360
    }

    private func normalizeDegrees(_ d: CGFloat) -> CGFloat {
        var x = d.truncatingRemainder(dividingBy: 360)
        if x < 0 { x += 360 }
        return x
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angleDeg: CGFloat) -> CGPoint {
        let r = angleDeg * .pi / 180
        return CGPoint(x: center.x + cos(r) * radius, y: center.y + sin(r) * radius)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        CircularColorSelector(
            value: 0.2, selectedColor: UIColor.red
        )
        .frame(width: 300, height: 300)
    }
    .background(Color.mint)
}
