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

import CoreGraphics
import SwiftUI

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
    @State private var initialValue: CGFloat? = nil
    @State private var valueDiff: CGFloat? = nil

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

                context.drawOuterRing(center, ringRadius)
                context.drawGradientRing(center, ringRadius, [endColor, startColor])

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
                    .onChanged { gestureValue in
                        guard enabled, ringRadius > 0 else { return }
                        handleGestureOnStart(gestureValue, center, ringRadius)

                        guard isActiveGesture else { return }
                        handleGestureOnDrag(gestureValue, center)
                    }
                    .onEnded { gestureValue in
                        defer {
                            didStartDrag = false
                            isActiveGesture = false
                            gesturePrevValue = nil
                            initialValue = nil
                            valueDiff = nil
                        }
                        guard enabled, isActiveGesture, ringRadius > 0 else { return }
                        let notMoved = gestureValue.startLocation == gestureValue.location
                        if notMoved, let newValue = valueFromTouch(point: gestureValue.location, center: center) {
                            onValueChanging(newValue)
                        }
                        onValueChanged()
                    }
            )
        }
    }

    // MARK: - Interaction helpers

    private func handleGestureOnStart(_ gesture: DragGesture.Value, _ center: CGPoint, _ ringRadius: CGFloat) {
        if !didStartDrag {
            let ok = isInRing(
                touch: gesture.location,
                center: center,
                ringRadius: ringRadius,
                slop: SELECTOR_RADIUS
            )
            isActiveGesture = ok
            didStartDrag = true

            if ok {
                gesturePrevValue = nil
                initialValue = nil
                valueDiff = 0
                onValueChangeStarted()
            }
        }
    }

    private func handleGestureOnDrag(_ gesture: DragGesture.Value, _ center: CGPoint) {
        if let newValue = valueFromTouch(point: gesture.location, center: center) {
            if (initialValue == nil) {
                initialValue = newValue
            }

            if let previous = gesturePrevValue {
                let currentDiff = previous - newValue

                valueDiff = valueDiff?.also { $0 + calculateCurrentIncrement(currentDiff, previous, newValue) }

                if let currentValue = initialValue?.also({ $0 - (valueDiff ?? 0) }) {
                    if (currentValue > 1) {
                        onValueChanging(1)
                    } else if (currentValue < 0) {
                        onValueChanging(0)
                    } else {
                        onValueChanging(currentValue)
                    }

                    if (currentValue < -1) {
                        valueDiff = valueDiff?.also { $0 - 1 }
                    } else if (currentValue > 2) {
                        valueDiff = valueDiff?.also { $0 + 1 }
                    }
                }
            }

            gesturePrevValue = newValue
        }
    }

    private func calculateCurrentIncrement(_ currentDiff: CGFloat, _ previous: CGFloat, _ current: CGFloat) -> CGFloat {
        if ((currentDiff > 0 && currentDiff < 0.8) || (currentDiff < 0 && currentDiff > (-0.8))) {
            return currentDiff
        } else if (currentDiff > 0) {
            return previous - 1 - current
        } else if (currentDiff < 0) {
            return previous + 1 - current
        } else {
            return 0
        }
    }

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

// MARK: - Canvas extensions

private extension GraphicsContext {
    func drawOuterRing(_ center: CGPoint, _ ringRadius: CGFloat) {
        let outerRect = CGRect(
            x: center.x - ringRadius,
            y: center.y - ringRadius,
            width: ringRadius * 2,
            height: ringRadius * 2
        )
        var surfacePath = Circle().path(in: outerRect)
        surfacePath = surfacePath.strokedPath(.init(lineWidth: TRACK_WIDTH + OUTER_SURFACE_WIDTH * 2, lineCap: .round))
        fill(surfacePath, with: .color(Color(.systemBackground)))
    }

    func drawGradientRing(_ center: CGPoint, _ ringRadius: CGFloat, _ colors: [Color]) {
        let ringRect = CGRect(
            x: -ringRadius,
            y: -ringRadius,
            width: ringRadius * 2,
            height: ringRadius * 2
        )
        var ringPath = Circle().path(in: ringRect)
        ringPath = ringPath.strokedPath(.init(lineWidth: TRACK_WIDTH, lineCap: .round))

        drawLayer { ctx in
            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: .degrees(-90))
            let gradient = Gradient(colors: colors)
            ctx.fill(ringPath, with: .conicGradient(gradient, center: CGPoint(x: 0, y: 0)))
        }
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
