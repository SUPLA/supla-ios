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

struct TimerProgressView: View {
    var progressPercentage: CGFloat? = nil
    var indeterminate: Bool = false
    
    private var clampedProgress: CGFloat {
        min(max(progressPercentage ?? 0, 0), 1)
    }
    
    private let size: CGFloat = 220
    private let progressLineWidth: CGFloat = 6
    private let progressInset: CGFloat = 10
    private let endpointOrbitRadius: CGFloat = 100
    
    var body: some View {
        ZStack {
            EvenOddRingShape(outerInset: 4, innerInset: 16)
                .fill(Color.Supla.surface, style: FillStyle(eoFill: true))
            
            Circle()
                .trim(from: 0, to: indeterminate ? 1 : clampedProgress)
                .stroke(
                    Color.Supla.primary,
                    style: StrokeStyle(lineWidth: progressLineWidth, lineCap: .round)
                )
                .padding(progressInset)
                .shadow(color: Color.Supla.primary.opacity(0.8), radius: 9)
            
            if indeterminate {
                RotatingIndeterminateRing(lineWidth: progressLineWidth)
                    .padding(5)
            } else {
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    let center = CGPoint(x: side / 2, y: side / 2)
                    let angle = 2 * CGFloat.pi * clampedProgress
                    let x = center.x + endpointOrbitRadius * cos(angle)
                    let y = center.y + endpointOrbitRadius * sin(angle)
                    
                    GreenPointView()
                        .position(x: x, y: y)
                }
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(-90))
    }
}

struct EvenOddRingShape: Shape {
    let outerInset: CGFloat
    let innerInset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect.insetBy(dx: outerInset, dy: outerInset))
        path.addEllipse(in: rect.insetBy(dx: innerInset, dy: innerInset))
        return path
    }
}

struct GreenPointView: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 14, height: 14)
            .overlay {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
            .shadow(color: Color.green.opacity(0.5), radius: 4)
    }
}

struct RotatingIndeterminateRing: View {
    let lineWidth: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        AngularGradient(
            gradient: Gradient(stops: [
                .init(color: .white, location: 0.0),
                .init(color: .clear, location: 0.2),
                .init(color: .clear, location: 0.8),
                .init(color: .white, location: 1.0)
            ]),
            center: .center
        )
        .mask {
            Circle()
                .stroke(lineWidth: lineWidth)
                .padding(5)
        }
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}
