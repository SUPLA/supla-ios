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

private let trackHeight: CGFloat = 4
private let tickOuterRadius: CGFloat = 6
private let tickInnerRadius: CGFloat = 4
private let thumbSize: CGFloat = 32
private let thumbRadius: CGFloat = 12

struct SteppedSlider: View {
    @Binding var value: Int

    let steps: Int
    var labels: [String]? = nil

    var body: some View {
        VStack(spacing: Distance.tiny) {
            if let labels {
                HStack {
                    ForEach(labels, id: \.self) { label in
                        Text(label.uppercased())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            GeometryReader { geometry in
                let fullWidth = geometry.size.width
                let stepWidth = fullWidth / CGFloat(steps)
                let sliderWidth = stepWidth * CGFloat(steps - 1)
                let leadingOffset = (fullWidth - sliderWidth) / 2

                ZStack(alignment: .leading) {
                    TrackView(
                        value: value,
                        steps: steps
                    )

                    ThumbView()
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(
                            x: leadingOffset
                                + thumbX(width: sliderWidth)
                                - thumbSize / 2
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    let localX = gesture.location.x - leadingOffset
                                    let progress = min(max(localX / sliderWidth, 0), 1)
                                    let newValue = Int(round(progress * CGFloat(steps - 1)))
                                    value = newValue
                                }
                        )
                }
                .frame(width: fullWidth, height: thumbSize)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let localX = gesture.location.x - leadingOffset
                            let progress = min(max(localX / sliderWidth, 0), 1)
                            value = Int(round(progress * CGFloat(steps - 1)))
                        }
                )
            }
            .frame(height: thumbSize)
        }
    }

    private func thumbX(width: CGFloat) -> CGFloat {
        guard steps > 1 else { return 0 }
        return width * CGFloat(value) / CGFloat(steps - 1)
    }
}

private struct TrackView: View {
    let value: Int
    let steps: Int

    var body: some View {
        Canvas { context, size in
            let primary = Color.Supla.primary
            let outline = Color.Supla.outline
            let background = Color.Supla.background
            
            let y = size.height / 2
            let stepWidth = size.width / CGFloat(steps)
            let leadingSpace = stepWidth / 2
            let selectedWidth = leadingSpace + stepWidth * CGFloat(value)
            let halfTrackHeight = trackHeight / 2

            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: halfTrackHeight, y: y))
                    path.addLine(to: CGPoint(x: size.width - halfTrackHeight, y: y))
                },
                with: .color(outline),
                style: StrokeStyle(lineWidth: trackHeight, lineCap: .round)
            )

            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: halfTrackHeight, y: y))
                    path.addLine(to: CGPoint(x: selectedWidth, y: y))
                },
                with: .color(primary),
                style: StrokeStyle(lineWidth: trackHeight, lineCap: .round)
            )

            for index in 0 ..< steps {
                let x = leadingSpace + CGFloat(index) * stepWidth
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: x - tickOuterRadius,
                        y: y - tickOuterRadius,
                        width: tickOuterRadius * 2,
                        height: tickOuterRadius * 2
                    )),
                    with: .color(background)
                )

                context.fill(
                    Path(ellipseIn: CGRect(
                        x: x - tickInnerRadius,
                        y: y - tickInnerRadius,
                        width: tickInnerRadius * 2,
                        height: tickInnerRadius * 2
                    )),
                    with: .color(primary)
                )
            }
        }
    }
}

private struct ThumbView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )
            let outerRadius: CGFloat = thumbSize / 2

            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - outerRadius,
                    y: center.y - outerRadius,
                    width: outerRadius * 2,
                    height: outerRadius * 2
                )),
                with: .color(Color.Supla.primary.opacity(0.4))
            )

            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - thumbRadius,
                    y: center.y - thumbRadius,
                    width: thumbRadius * 2,
                    height: thumbRadius * 2
                )),
                with: .color(Color.Supla.primary)
            )
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var value = 2
    
    SteppedSlider(
        value: $value,
        steps: 4,
        labels: [
            "Speed 1",
            "Speed 2",
            "Speed 3",
            "Speed 4"
        ]
    )
}
