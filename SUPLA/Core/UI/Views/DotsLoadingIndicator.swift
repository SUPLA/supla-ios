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

private let dotSize: CGFloat = 8

struct DotsLoadingIndicator: View {

    var grayColor: Color = .Supla.outline
    var greenColor: Color = .Supla.primary
    var delayBetweenDots: Double = 0.15

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    DotView(
                        time: time,
                        index: index,
                        delayBetweenDots: delayBetweenDots,
                        grayColor: grayColor,
                        greenColor: greenColor
                    )
                }
            }
        }
    }
}

private struct DotView: View {

    let time: Double
    let index: Int
    let delayBetweenDots: Double
    let grayColor: Color
    let greenColor: Color

    var body: some View {
        let alpha = dotAlpha()

        ZStack {
            Circle()
                .fill(grayColor)

            Circle()
                .fill(greenColor)
                .opacity(alpha)
        }
        .frame(width: dotSize, height: dotSize)
    }

    private func dotAlpha() -> Double {
        let duration = delayBetweenDots * 6
        let t = (time.truncatingRemainder(dividingBy: duration))

        let start = delayBetweenDots * Double(index)
        let fadeIn = start + delayBetweenDots
        let hold = start + delayBetweenDots * 3
        let fadeOut = start + delayBetweenDots * 4

        if t < start {
            return 0
        } else if t < fadeIn {
            return (t - start) / delayBetweenDots
        } else if t < hold {
            return 1
        } else if t < fadeOut {
            return 1 - (t - hold) / delayBetweenDots
        } else {
            return 0
        }
    }
}
