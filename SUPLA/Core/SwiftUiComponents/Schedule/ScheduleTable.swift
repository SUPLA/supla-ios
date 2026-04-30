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

private let BOX_PADDING: CGFloat = 2
private let BOX_SPACING: CGFloat = BOX_PADDING * 2

struct ScheduleTable<Value: ScheduleDetailBoxValue>: View {
    let schedule: [ScheduleDetailBoxKey: Value]
    let currentDay: DayOfWeek?
    let currentHour: Int?

    let onFingerMoved: ((ScheduleDetailBoxKey) -> Void)?
    let onFingerMoveFinished: (() -> Void)?
    let onFingerLongPressed: ((ScheduleDetailBoxKey) -> Void)?

    @ObservedObject private var orientationObserver = OrientationObserver()
    @State private var lastTouchedBoxKey: ScheduleDetailBoxKey? = nil
    @State private var lastTouchTime: Date? = nil
    @State private var lastTouchDistance: CGFloat? = nil

    var body: some View {
        let isLandscape = orientationObserver.orientation.isLandscape
        
        GeometryReader { geometry in
            let grid = getGridDimensions(geometry.size, isLandscape: isLandscape)
            
            Grid(grid)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard let onFingerMoved,
                                  let key = grid.keyForTap(value.location)
                            else { return }

                            lastTouchDistance = value.startLocation.distance(to: value.location)
                            
                            if (lastTouchTime == nil) {
                                SALog.debug("First finger move event: \(key)")
                                
                                // First touch, do nothing, only store data
                                lastTouchTime = value.time
                                lastTouchedBoxKey = key

                                return
                            }

                            guard let time = lastTouchTime?.timeIntervalSince1970,
                                  let lastTouchDistance,
                                  value.time.timeIntervalSince1970 - time > 1 || lastTouchDistance > 10
                            else { return }

                            SALog.debug("Finger moved to key: \(key)")
                            lastTouchedBoxKey = key
                            onFingerMoved(key)
                        }
                        .onEnded { _ in
                            guard let onFingerMoveFinished else { return }

                            SALog.debug("Drag gesture finished")
                            if let lastTouchedBoxKey, let onFingerMoved {
                                onFingerMoved(lastTouchedBoxKey)
                            }
                            onFingerMoveFinished()
                            
                            lastTouchTime = nil
                            lastTouchedBoxKey = nil
                            lastTouchDistance = nil
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            guard let onFingerLongPressed,
                                  let key = lastTouchedBoxKey,
                                  let lastTouchDistance
                            else { return }
                            
                            if (lastTouchDistance < 10) {
                                onFingerLongPressed(key)
                            }
                            lastTouchedBoxKey = nil
                        }
                )
        }
        
    }
    
    private func Grid(_ grid: GridDimensions) -> some SwiftUI.View {
        ZStack {
            ForEach(DayOfWeek.allCases.indices, id: \.self) { index in
                let day = DayOfWeek.allCases[index]
                let rect = grid.dayRect(CGFloat(index))

                TextLabel(day.shortText(), isActive: day == currentDay)
                    .frame(width: rect.width, height: rect.height, alignment: .center)
                    .position(x: rect.minX, y: rect.minY)
            }

            ForEach(0...23, id: \.self) { hour in
                let rect = grid.hourRect(CGFloat(hour))

                TextLabel(hour.hourString, isActive: hour == currentHour)
                    .frame(width: rect.width, height: rect.height, alignment: .center)
                    .position(x: rect.minX, y: rect.minY)
            }

            ForEach(DayOfWeek.allCases) { day in
                ForEach(0...23, id: \.self) { hour in
                    let key = ScheduleDetailBoxKey(dayOfWeek: day, hour: hour)
                    let box = schedule[key]
                    let rect = grid.boxRect(key)

                    box?.boxView
                        .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusSmall))
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.minX, y: rect.minY)

                    if (day == currentDay && hour == currentHour) {
                        CurrentMarkerShape()
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.minX, y: rect.minY)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func TextLabel(_ text: String, isActive: Bool) -> some SwiftUI.View {
        if (isActive) {
            Text(text).fontBodySmallBold()
        } else {
            Text(text).fontBodySmall()
        }
    }

    private func getGridDimensions(_ size: CGSize, isLandscape: Bool) -> GridDimensions {
        let dayOfWeekMaxSize = getDayOfWeekMaxSize()
        let hourMaxSize = getHourMaxSize()

        let leftMargin: CGFloat = (isLandscape ? dayOfWeekMaxSize.width : hourMaxSize.width) + BOX_PADDING
        let topMargin: CGFloat = (isLandscape ? hourMaxSize.height : dayOfWeekMaxSize.height) + BOX_PADDING

        let gridWidth: CGFloat = (size.width - leftMargin) / (isLandscape ? 24 : CGFloat(DayOfWeek.allCases.count))
        let gridHeight: CGFloat = (size.height - topMargin) / (isLandscape ? CGFloat(DayOfWeek.allCases.count) : 24)

        return GridDimensions(
            leftMargin: leftMargin,
            topMargin: topMargin,
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            boxWidth: gridWidth - BOX_SPACING,
            boxHeight: gridHeight - BOX_SPACING,
            isLandscape: isLandscape,
            viewSize: size
        )
    }

    private func getDayOfWeekMaxSize() -> CGSize {
        var maxWidth: CGFloat = 0
        var maxHeigth: CGFloat = 0
        for day in DayOfWeek.allCases {
            let size = textSize(day.shortText(), font: .caption)
            maxWidth = max(maxWidth, size.width)
            maxHeigth = max(maxHeigth, size.height)
        }

        return CGSizeMake(maxWidth, maxHeigth)
    }

    private func getHourMaxSize() -> CGSize {
        var maxWidth: CGFloat = 0
        var maxHeigth: CGFloat = 0
        for hour in 0...23 {
            let size = textSize(hour.hourString, font: .caption)
            maxWidth = max(maxWidth, size.width)
            maxHeigth = max(maxHeigth, size.height)
        }

        return CGSizeMake(maxWidth, maxHeigth)
    }
}

private func textSize(_ text: String, font: UIFont) -> CGSize {
    let attributes = [NSAttributedString.Key.font: font]
    return (text as NSString).size(withAttributes: attributes)
}

private extension Int {
    var hourString: String { self < 10 ? "0\(self)" : "\(self)" }
}

private struct GridDimensions {
    let leftMargin: CGFloat
    let topMargin: CGFloat

    let gridWidth: CGFloat
    let gridHeight: CGFloat

    let boxWidth: CGFloat
    let boxHeight: CGFloat

    let isLandscape: Bool
    let viewSize: CGSize

    init(
        leftMargin: CGFloat,
        topMargin: CGFloat,
        gridWidth: CGFloat,
        gridHeight: CGFloat,
        boxWidth: CGFloat,
        boxHeight: CGFloat,
        isLandscape: Bool,
        viewSize: CGSize
    ) {
        self.leftMargin = leftMargin
        self.topMargin = topMargin
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.isLandscape = isLandscape
        self.viewSize = viewSize
    }

    func dayRect(_ index: CGFloat) -> CGRect {
        CGRect(
            x: isLandscape ? (leftMargin / 2) : (leftMargin + (gridWidth / 2) + (index * gridWidth)),
            y: isLandscape ? (topMargin + (gridHeight / 2) + (index * gridHeight)) : (topMargin / 2),
            width: isLandscape ? leftMargin : gridWidth,
            height: isLandscape ? gridHeight : topMargin
        )
    }

    func hourRect(_ hour: CGFloat) -> CGRect {
        CGRect(
            x: isLandscape ? (leftMargin + (gridWidth / 2) + (hour * gridWidth)) : (leftMargin / 2),
            y: isLandscape ? (topMargin / 2) : (topMargin + (gridHeight / 2) + (hour * gridHeight)),
            width: isLandscape ? gridWidth : leftMargin,
            height: isLandscape ? topMargin : gridHeight
        )
    }

    func boxRect(_ box: ScheduleDetailBoxKey) -> CGRect {
        let xIndex = isLandscape ? box.hour : box.dayOfWeek.index
        let zIndex = isLandscape ? box.dayOfWeek.index : box.hour

        return CGRect(
            x: leftMargin + (CGFloat(xIndex) * gridWidth) + (gridWidth / 2),
            y: topMargin + (CGFloat(zIndex) * gridHeight) + (gridHeight / 2),
            width: boxWidth,
            height: boxHeight
        )
    }

    func keyForTap(_ location: CGPoint) -> ScheduleDetailBoxKey? {
        if (location.x < leftMargin || location.x > viewSize.width) {
            return nil
        }
        if (location.y < topMargin || location.y > viewSize.height) {
            return nil
        }

        if (isLandscape) {
            let day = Int((location.y - topMargin) / gridHeight)
            let hour = Int((location.x - leftMargin) / gridWidth)

            return ScheduleDetailBoxKey(dayOfWeek: .from(index: day), hour: hour)
        } else {
            let day = Int((location.x - leftMargin) / gridWidth)
            let hour = Int((location.y - topMargin) / gridHeight)

            return ScheduleDetailBoxKey(dayOfWeek: .from(index: day), hour: hour)
        }
    }
}

private struct CurrentMarkerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let size = (rect.height > rect.width ? rect.width : rect.height) / 2

        var path = Path()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: 0, y: Dimens.radiusSmall))
        path.addLine(to: CGPoint(x: Dimens.radiusSmall, y: 0))
        path.addLine(to: CGPoint(x: size, y: 0))
        path.closeSubpath()

        return path
    }
}

private let programs: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [
    .init(dayOfWeek: .monday, hour: 8): .init(oneProgram: .program1),
    .init(dayOfWeek: .monday, hour: 9): .init(oneProgram: .program2),
    .init(dayOfWeek: .monday, hour: 10): .init(oneProgram: .program3),
    .init(dayOfWeek: .monday, hour: 11): .init(oneProgram: .program4)
]

#Preview {
    if #available(iOS 17.0, *) {
        ZStack {
            ScheduleTable(
                schedule: generateSchedule(programs),
                currentDay: .friday,
                currentHour: 16,
                onFingerMoved: nil,
                onFingerMoveFinished: nil,
                onFingerLongPressed: nil
            )
        }
        .safeAreaPadding()
    } else {
        EmptyView()
    }
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("Landscape", traits: .landscapeRight) {
    ZStack {
        ScheduleTable(
            schedule: generateSchedule(programs),
            currentDay: .friday,
            currentHour: 16,
            onFingerMoved: nil,
            onFingerMoveFinished: nil,
            onFingerLongPressed: nil
        )
    }
    .safeAreaPadding()
}
#endif // swift(>=5.9)

func generateSchedule(
    _ values: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue]
) -> [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] {
    var result: [ScheduleDetailBoxKey: ThermostatScheduleDetailBoxValue] = [:]

    for day in DayOfWeek.allCases {
        for hour in 0...23 {
            result[.init(dayOfWeek: day, hour: hour)] = .init(oneProgram: .off)
        }
    }

    for value in values {
        result[value.key] = value.value
    }

    return result
}
