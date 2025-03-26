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

private let containerMargin: CGFloat = 4
private let containerWidth: CGFloat = 150
private let containerHeight: CGFloat = 240
private let containerRatio: CGFloat = containerWidth / containerHeight
private let containerSpecification = ContainerSpecification(
    bottomPartHeight: 190,
    topPartWidth: 56,
    containerRadius: 10,
    coverHeight: 16,
    coverWidth: 32,
    coverRadius: 5,
    waveX: 25,
    waveY: 12,
    levelMargin: 10,
    dashWidth: 5,
    dashSpace: 3,
    alertTextMargin: 4
)
private let labelCorrection: CGFloat = 4

struct ContainerIconView: View {
    let level: CGFloat?
    let containerType: ContainerType
    let controlLevels: [ControlLevel]
    
    init(
        level: CGFloat?,
        containerType: ContainerType = .default,
        controlLevels: [ControlLevel] = []
    ) {
        self.level = level
        self.containerType = containerType
        self.controlLevels = controlLevels
    }
    
    var body: some View {
        GeometryReader { reader in
            let targetRect = targetRect(reader.size)
            let scale = targetRect.width / containerWidth
            let specification = containerSpecification.scale(scale)
            
            ZStack(alignment: .topLeading) {
                ContainerShape(specification).fill(Color.Supla.surface)
                if let level {
                    FluidShape(level, specification)
                        .fill(containerType.primary)
                    WaveShape(level, specification)
                        .fill(containerType.secondary)
                }
                
                ControlLinesView(controlLevels, specification, targetRect, scale)
                
                ContainerShape(specification).stroke(Color.Supla.outline, lineWidth: 2)
            }
            .frame(width: targetRect.width, height: targetRect.height)
            .offset(x: targetRect.minX, y: targetRect.minY)
        }
        .frame(idealWidth: containerWidth, idealHeight: containerHeight)
    }
    
    private func targetRect(_ size: CGSize) -> CGRect {
        let canvasRatio = size.width / size.height
        let doubleMargin = containerMargin * 2
        
        if (canvasRatio < containerRatio) {
            let height = (size.width - doubleMargin) / containerRatio
            let topOffset = (size.height - height) / 2
            
            return CGRect(x: containerMargin, y: topOffset, width: size.width - doubleMargin, height: height)
        } else {
            let width = (size.height - doubleMargin) * containerRatio
            let leftOffset = (size.width - width) / 2
            
            return CGRect(x: leftOffset, y: containerMargin, width: width, height: size.height - doubleMargin)
        }
    }
}

private struct ContainerShape: SwiftUI.Shape {
    let specification: ContainerSpecification
    
    init(_ specification: ContainerSpecification) {
        self.specification = specification
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.containerBottom(targetRect: rect, specification: specification)
        path.closeSubpath()
        path.containerTop(targetRect: rect, specification: specification)
        return path
    }
}

private struct FluidShape: SwiftUI.Shape {
    let level: CGFloat
    let specification: ContainerSpecification
    
    init(
        _ level: CGFloat,
        _ specification: ContainerSpecification
    ) {
        self.level = level
        self.specification = specification
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.containerBottom(targetRect: rect, specification: specification, level: level)
        path.fluidWave(level, targetRect: rect, specification: specification)
        path.closeSubpath()
        return path
    }
}

private struct WaveShape: SwiftUI.Shape {
    let level: CGFloat
    let specification: ContainerSpecification
    
    init(
        _ level: CGFloat,
        _ specification: ContainerSpecification
    ) {
        self.level = level
        self.specification = specification
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.secondaryWave(level, targetRect: rect, specification: specification)
        return path
    }
}

private struct ControlLinesView: View {
    
    let controlLevels: [ControlLevel]
    let specification: ContainerSpecification
    let targetRect: CGRect
    let scale: CGFloat
    
    init(_ controlLevels: [ControlLevel], _ specification: ContainerSpecification, _ targetRect: CGRect, _ scale: CGFloat) {
        self.controlLevels = controlLevels
        self.specification = specification
        self.targetRect = targetRect
        self.scale = scale
    }
    
    var body: some View {
        let alarmUpper = controlLevels.first(where: { $0.isAlarm && $0.isUpper })
        let alarmLower = controlLevels.first(where: { $0.isAlarm && $0.isLower })
        let warningUpper = controlLevels.first(where: { $0.isWarning && $0.isUpper })
        let warningLower = controlLevels.first(where: { $0.isWarning && $0.isLower })
        
        alarmUpper?.line(specification)
        alarmLower?.line(specification)
        warningUpper?.line(specification)
        warningLower?.line(specification)
        
        alarmUpper?.label(targetRect, specification, scale, nextLevel: alarmLower)
        alarmLower?.label(targetRect, specification, scale, previousLevel: alarmUpper)
        warningUpper?.label(targetRect, specification, scale, nextLevel: warningLower)
        warningLower?.label(targetRect, specification, scale, previousLevel: warningUpper)
    }
}

private struct ControlLine: SwiftUI.Shape {
    let level: CGFloat
    let specification: ContainerSpecification
    
    init(
        _ level: CGFloat,
        _ specification: ContainerSpecification
    ) {
        self.level = level
        self.specification = specification
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.lineOn(level: level, targetRect: rect, specification: specification)
        return path
    }
    
    func dashed(_ color: Color) -> some View {
        stroke(
            style: StrokeStyle(
                lineWidth: 1,
                dash: [specification.dashWidth, specification.dashSpace]
            )
        )
        .foregroundColor(color)
    }
}

private extension ControlLevel {
    func line(_ specification: ContainerSpecification) -> some View {
        return ControlLine(level, specification).dashed(color)
    }
    
    func label(
        _ targetRect: CGRect,
        _ specification: ContainerSpecification,
        _ scale: CGFloat,
        previousLevel: ControlLevel? = nil,
        nextLevel: ControlLevel? = nil
    ) -> some View {
        ZStack {
            Text(levelString)
                .textColor(color)
                .modifier(
                    ControlLevelModifier(
                        type: type,
                        levelPosition: calculateTopPadding(targetRect, specification),
                        scale: scale,
                        previousLevelPosition: previousLevel?.calculateTopPadding(targetRect, specification),
                        nextLevelPosition: nextLevel?.calculateTopPadding(targetRect, specification)
                    )
                )
        }.frame(maxWidth: .infinity, alignment: alignment())
    }
    
    private func calculateTopPadding(_ targetRect: CGRect, _ specification: ContainerSpecification) -> CGFloat {
        targetRect.height - calculateFluidHeight(level, specification: specification)
    }
    
    private func alignment() -> Alignment {
        switch self {
        case .alarm: .trailing
        case .warning: .leading
        }
    }
}

private struct ControlLevelModifier: ViewModifier {
    let type: ControlLevelType
    let levelPosition: CGFloat
    let scale: CGFloat
    let previousLevelPosition: CGFloat?
    let nextLevelPosition: CGFloat?
    
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .font(.custom("OpenSans-SemiBold", size: 12 * scale))
            .padding(4)
            .background(ViewGeometry())
            .background(ControlLevelShape(scale: scale, type: type).fill(Color.Supla.surface))
            .background(ControlLevelShape(scale: scale, type: type).stroke(Color.Supla.outline, lineWidth: 2))
            .padding(.top, topPadding())
            .onPreferenceChange(ViewSizeKey.self) {
                size = $0
            }
    }
    
    private func topPadding() -> CGFloat {
        if let previousLevelPosition {
            let distance = levelPosition - previousLevelPosition
            return if (distance > size.height - labelCorrection * scale * 2) {
                levelPosition - size.height / 2
            } else {
                previousLevelPosition + distance / 2 - labelCorrection * scale
            }
        } else if let nextLevelPosition {
            let distance = nextLevelPosition - levelPosition
            return if (distance > size.height - labelCorrection * scale * 2) {
                levelPosition - size.height / 2
            } else {
                levelPosition + distance / 2 - size.height + labelCorrection * scale
            }
        } else {
            return levelPosition - size.height / 2
        }
    }
}

private struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

private struct ControlLevelShape: SwiftUI.Shape {
    let scale: CGFloat
    let type: ControlLevelType
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let correction = labelCorrection * scale
            
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + correction))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - correction))
            if type == .upper {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - correction))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + correction))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            } else {
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - correction))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + correction))
            }
            path.closeSubpath()
        }
    }
}

private struct ContainerSpecification {
    let bottomPartHeight: CGFloat
    let topPartWidth: CGFloat
    let containerRadius: CGFloat
    let coverHeight: CGFloat
    let coverWidth: CGFloat
    let coverRadius: CGFloat
    let waveX: CGFloat
    let waveY: CGFloat
    let levelMargin: CGFloat
    let dashWidth: CGFloat
    let dashSpace: CGFloat
    let alertTextMargin: CGFloat
    
    func scale(_ scale: CGFloat) -> ContainerSpecification {
        ContainerSpecification(
            bottomPartHeight: bottomPartHeight * scale,
            topPartWidth: topPartWidth * scale,
            containerRadius: containerRadius * scale,
            coverHeight: coverHeight * scale,
            coverWidth: coverWidth * scale,
            coverRadius: coverRadius * scale,
            waveX: waveX * scale,
            waveY: waveY * scale,
            levelMargin: levelMargin * scale,
            dashWidth: dashWidth * scale,
            dashSpace: dashSpace * scale,
            alertTextMargin: alertTextMargin * scale
        )
    }
}

private extension Path {
    mutating func containerBottom(
        targetRect: CGRect,
        specification: ContainerSpecification,
        level: CGFloat? = nil
    ) {
        let left = targetRect.minX
        let right = targetRect.maxX
        let bottom = targetRect.maxY
        let bottomPartHeight = if let level {
            calculateFluidHeight(level, specification: specification)
        } else {
            specification.bottomPartHeight
        }
        
        move(to: CGPoint(x: left, y: bottom - bottomPartHeight))
        addLine(to: CGPoint(x: left, y: bottom - specification.containerRadius))
        addArc(
            center: CGPoint(x: left + specification.containerRadius, y: bottom - specification.containerRadius),
            radius: specification.containerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 90),
            clockwise: true
        )
        addLine(to: CGPoint(x: right - specification.containerRadius, y: bottom))
        addArc(
            center: CGPoint(x: right - specification.containerRadius, y: bottom - specification.containerRadius),
            radius: specification.containerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 0),
            clockwise: true
        )
        addLine(to: CGPoint(x: right, y: bottom - bottomPartHeight))
    }
    
    mutating func fluidWave(_ level: CGFloat, targetRect: CGRect, specification: ContainerSpecification) {
        let left = targetRect.minX
        let bottom = targetRect.maxY
        let fluidTop = bottom - calculateFluidHeight(level, specification: specification)
        
        addLine(to: CGPoint(x: targetRect.midX, y: fluidTop))
        addCurve(
            to: CGPoint(x: targetRect.minX, y: fluidTop),
            control1: CGPoint(x: targetRect.midX - specification.waveX, y: fluidTop - specification.waveY),
            control2: CGPoint(x: left + specification.waveX, y: fluidTop - specification.waveY)
        )
    }
    
    mutating func secondaryWave(_ level: CGFloat, targetRect: CGRect, specification: ContainerSpecification) {
        let right = targetRect.maxX
        let bottom = targetRect.maxY
        let fluidTop = bottom - calculateFluidHeight(level, specification: specification) + 0.1
        
        move(to: CGPoint(x: targetRect.midX, y: fluidTop))
        addCurve(
            to: CGPoint(x: right, y: fluidTop),
            control1: CGPoint(x: targetRect.midX + specification.waveX, y: fluidTop - specification.waveY),
            control2: CGPoint(x: right - specification.waveX, y: fluidTop - specification.waveY)
        )
        addCurve(
            to: CGPoint(x: targetRect.midX, y: fluidTop),
            control1: CGPoint(x: right - specification.waveX, y: fluidTop + specification.waveY),
            control2: CGPoint(x: targetRect.midX + specification.waveX, y: fluidTop + specification.waveY)
        )
        closeSubpath()
    }
    
    mutating func lineOn(level: CGFloat, targetRect: CGRect, specification: ContainerSpecification) {
        let bottom = targetRect.maxY
        let fluidTop = bottom - calculateFluidHeight(level, specification: specification)
        move(to: CGPoint(x: targetRect.minX, y: fluidTop))
        addLine(to: CGPoint(x: targetRect.maxX, y: fluidTop))
    }
    
    mutating func containerTop(targetRect: CGRect, specification: ContainerSpecification) {
        let halfTopPartWidth = specification.topPartWidth / 2
        let halfCoverWidth = specification.coverWidth / 2
        let top = targetRect.minY
        let left = targetRect.minX
        let right = targetRect.maxX
        let bottom = targetRect.maxY
        let centerX = targetRect.midX
        
        move(to: CGPoint(x: left, y: bottom - specification.bottomPartHeight))
        addLine(to: CGPoint(x: centerX - halfTopPartWidth, y: top + specification.coverHeight))
        addLine(to: CGPoint(x: centerX + halfTopPartWidth, y: top + specification.coverHeight))
        addLine(to: CGPoint(x: right, y: bottom - specification.bottomPartHeight))
        move(to: CGPoint(x: centerX - halfCoverWidth, y: top + specification.coverHeight))
        addLine(to: CGPoint(x: centerX - halfCoverWidth, y: top + specification.coverRadius))
        addArc(
            center: CGPoint(
                x: centerX - halfCoverWidth + specification.coverRadius,
                y: top + specification.coverRadius
            ),
            radius: specification.coverRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        addLine(to: CGPoint(x: centerX + specification.coverWidth / 2 - specification.coverRadius, y: top))
        addArc(
            center: CGPoint(
                x: centerX + specification.coverWidth / 2 - specification.coverRadius,
                y: top + specification.coverRadius
            ),
            radius: specification.coverRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        addLine(to: CGPoint(x: centerX + specification.coverWidth / 2, y: top + specification.coverHeight))
    }
}

private func calculateFluidHeight(_ level: CGFloat, specification: ContainerSpecification) -> CGFloat {
    specification.levelMargin + (specification.bottomPartHeight - specification.levelMargin * 2) * level
}

#Preview {
    ZStack {
        Color.Supla.background
        ContainerIconView(
            level: 0.8,
            controlLevels: [
                .alarm(level: 0.9, levelString: "90%", type: .upper),
                .warning(level: 0.8, levelString: "80%", type: .upper),
                .warning(level: 0.2, levelString: "20%", type: .lower),
                .alarm(level: 0.1, levelString: "10%", type: .lower),
            ]
        )
    }
}

#Preview("small") {
    ZStack {
        Color.Supla.background
        ContainerIconView(
            level: 0.8,
            controlLevels: [
                .alarm(level: 0.9, levelString: "90%", type: .upper),
                .warning(level: 0.8, levelString: "80%", type: .upper),
                .warning(level: 0.2, levelString: "20%", type: .lower),
                .alarm(level: 0.1, levelString: "10%", type: .lower),
            ]
        )
        .frame(width: 200, height: 300)
    }
}

#Preview("near values") {
    ZStack {
        Color.Supla.background
        ContainerIconView(
            level: 0.8,
            controlLevels: [
                .alarm(level: 0.9, levelString: "90%", type: .upper),
                .warning(level: 0.22, levelString: "22%", type: .upper),
                .warning(level: 0.2, levelString: "20%", type: .lower),
                .alarm(level: 0.88, levelString: "88%", type: .lower),
            ]
        )
    }
}
