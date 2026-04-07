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

struct ThermostatScheduleDetailBoxValue: Equatable, ScheduleDetailBoxValue {
    var firstQuarterProgram: SuplaScheduleProgram
    var secondQuarterProgram: SuplaScheduleProgram
    var thirdQuarterProgram: SuplaScheduleProgram
    var fourthQuarterProgram: SuplaScheduleProgram
    
    var hasSingleProgram: Bool {
        return firstQuarterProgram == secondQuarterProgram
            && secondQuarterProgram == thirdQuarterProgram
            && thirdQuarterProgram == fourthQuarterProgram
    }
    
    @ViewBuilder
    var boxView: some View {
        if (hasSingleProgram) {
            firstQuarterProgram.color
        } else {
            GeometryReader { geo in
                let width = geo.size.width / 4
                HStack(spacing: 0) {
                    firstQuarterProgram.color
                        .frame(width: width)
                        .clipShape(LeftRoundedShape(radius: Dimens.radiusSmall))
                    secondQuarterProgram.color
                        .frame(width: width)
                    thirdQuarterProgram.color
                        .frame(width: width)
                    fourthQuarterProgram.color
                        .frame(width: width)
                        .clipShape(RightRoundedShape(radius: Dimens.radiusSmall))
                }
            }
        }
    }
    
    init(_ first: SuplaScheduleProgram, _ second: SuplaScheduleProgram, _ third: SuplaScheduleProgram, _ fourth: SuplaScheduleProgram) {
        firstQuarterProgram = first
        secondQuarterProgram = second
        thirdQuarterProgram = third
        fourthQuarterProgram = fourth
    }
    
    init(oneProgram: SuplaScheduleProgram) {
        firstQuarterProgram = oneProgram
        secondQuarterProgram = oneProgram
        thirdQuarterProgram = oneProgram
        fourthQuarterProgram = oneProgram
    }
    
    func programForQuarter(_ quarter: QuarterOfHour) -> SuplaScheduleProgram {
        switch (quarter) {
        case .first: firstQuarterProgram
        case .second: secondQuarterProgram
        case .third: thirdQuarterProgram
        case .fourth: fourthQuarterProgram
        }
    }
    
    func withQuarterProgram(_ quarter: QuarterOfHour, _ program: SuplaScheduleProgram) -> Self {
        ThermostatScheduleDetailBoxValue(
            quarter == .first ? program : firstQuarterProgram,
            quarter == .second ? program : secondQuarterProgram,
            quarter == .third ? program : thirdQuarterProgram,
            quarter == .fourth ? program : fourthQuarterProgram
        )
    }
}


private struct LeftRoundedShape: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .bottomLeft],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private struct RightRoundedShape: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topRight, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
