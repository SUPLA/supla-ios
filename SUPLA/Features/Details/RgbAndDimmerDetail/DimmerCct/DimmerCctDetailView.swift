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

private let CCT_START_COLOR: Color = .init(uiColor: UIColor(argb: 0xFFB1E1FF))
private let CCT_END_COLOR: Color = .init(uiColor: UIColor(argb: 0xFFFFDF00))

private let CCT_SELECTOR_COLORS = [
    Gradient.Stop(color: CCT_START_COLOR, location: 0),
    Gradient.Stop(color: .white, location: 0.45),
    Gradient.Stop(color: .white, location: 0.55),
    Gradient.Stop(color: CCT_END_COLOR, location: 1),
]

private let CCT_CIRCULAR_SELECTOR_COLORS = [
    Gradient.Stop(color: CCT_END_COLOR, location: 0),
    Gradient.Stop(color: .white, location: 0.45),
    Gradient.Stop(color: .white, location: 0.55),
    Gradient.Stop(color: CCT_START_COLOR, location: 1),
]

extension DimmerCctDetailFeature {
    protocol ViewDelegate: DimmerDetailBase.ViewDelegate {
        func onBrightnessSelectionStarted()
        func onBrightnessSelecting(_ brightness: Int)
        func onBrightnessSelected()
        func onCctSelectionStarted()
        func onCctSelecting(_ cct: Int)
        func onCctSelected()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: DimmerDetailBase.ViewState
        var delegate: ViewDelegate?

        @StateObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            DimmerDetailBase.Scaffold(
                delegate: delegate,
                brightnessBox: { brightnessBox() },
                brightnessControl: { brightnessControl() },
                savedColorItemContent: { savedColorBox($0) }
            )
            .environmentObject(viewState)
        }

        @ViewBuilder
        private func brightnessBox() -> some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                Text(Strings.RgbDetail.brightness)
                    .fontLabelMedium()
                    .textColor(.Supla.onSurfaceVariant)
                Text(viewState.value.brightnessString)
                    .fontBodyMedium()
                    .textColor(.Supla.onBackground)
                Spacer().frame(width: Distance.default)
                Text(Strings.RgbDetail.dimmerDetailTemperature)
                    .fontLabelMedium()
                    .textColor(.Supla.onSurfaceVariant)
                RgbDetailFeature.ColorBox(color: viewState.value.cct?.asPercentageFloat.toCctColor())
            }
            .padding([.leading, .trailing], Distance.default)
            .padding([.top, .bottom], Distance.small)
            .background(Color.Supla.surface.clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault)))
            .padding(Distance.default)
        }

        @ViewBuilder
        private func brightnessControl() -> some SwiftUI.View {
            switch (viewState.selectorType) {
            case .linear:
                linearSelector()
            case .circular:
                circularSelector()
            }
        }

        @ViewBuilder
        private func linearSelector() -> some SwiftUI.View {
            HStack() {
                Spacer()
                LinearColorSelector(
                    value: viewState.value.brightness?.asPercentageFloat,
                    selectedColor: viewState.value.brightness?.asGrayColor,
                    valueMarkers: viewState.value.brightnessMarkers.map { $0.asPercentageFloat },
                    enabled: !viewState.offline,
                    startColor: .white,
                    onValueChangeStarted: { delegate?.onBrightnessSelectionStarted() },
                    onValueChanging: { delegate?.onBrightnessSelecting(Int($0 * 100)) },
                    onValueChanged: { delegate?.onBrightnessSelected() }
                )
                .frame(width: 40)
                Spacer()
                LinearColorSelector(
                    value: viewState.value.cct?.asPercentageFloat,
                    selectedColor: viewState.value.cct?.asPercentageFloat.toCctColor(),
                    valueMarkers: viewState.value.cctMarkers.map { $0.asPercentageFloat },
                    enabled: !viewState.offline,
                    colors: CCT_SELECTOR_COLORS,
                    onValueChangeStarted: { delegate?.onCctSelectionStarted() },
                    onValueChanging: { delegate?.onCctSelecting(Int($0 * 100)) },
                    onValueChanged: { delegate?.onCctSelected() }
                )
                .frame(width: 40)
                Spacer()
            }
            .frame(maxHeight: 350)
        }

        @ViewBuilder
        private func circularSelector() -> some SwiftUI.View {
            ZStack {
                CircularColorSelector(
                    value: viewState.value.brightness?.asPercentageFloat,
                    selectedColor: viewState.value.brightness?.asGrayColor,
                    valueMarkers: viewState.value.brightnessMarkers.map { $0.asPercentageFloat },
                    enabled: !viewState.offline,
                    startColor: .white,
                    onValueChangeStarted: { delegate?.onBrightnessSelectionStarted() },
                    onValueChanging: { delegate?.onBrightnessSelecting(Int($0 * 100)) },
                    onValueChanged: { delegate?.onBrightnessSelected() }
                )
                CircularColorSelector(
                    value: viewState.value.cct?.asPercentageFloat,
                    selectedColor: viewState.value.cct?.asPercentageFloat.toCctColor(),
                    valueMarkers: viewState.value.cctMarkers.map { $0.asPercentageFloat },
                    enabled: !viewState.offline,
                    colors: CCT_CIRCULAR_SELECTOR_COLORS,
                    onValueChangeStarted: { delegate?.onCctSelectionStarted() },
                    onValueChanging: { delegate?.onCctSelecting(Int($0 * 100)) },
                    onValueChanged: { delegate?.onCctSelected() }
                ).padding(50)
            }
            .frame(maxWidth: .infinity, maxHeight: 350)
        }

        @ViewBuilder
        private func savedColorBox(_ color: SavedColor) -> some SwiftUI.View {
            let leftColor = Int(color.brightness).asGrayColor
            let rightColor = color.color.asPercentageFloat.toCctColor()

            SavedColorBox(leftColor: leftColor, rightColor: rightColor)
        }
    }

    struct SavedColorBox: SwiftUI.View {
        let leftColor: UIColor
        let rightColor: UIColor

        var body: some SwiftUI.View {
            HStack(spacing: 0) {
                Color(leftColor)
                Color(rightColor)
            }
            .frame(width: 42, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                    .stroke(Color.Supla.onSurfaceVariant, lineWidth: 1)
            )
            .padding(Distance.tiny)
        }
    }
}

private func lerp(_ a: CGFloat, _ b: CGFloat, t: CGFloat) -> CGFloat {
    a + (b - a) * t
}

private func clamp01(_ x: CGFloat) -> CGFloat {
    max(0, min(1, x))
}

private func colorAt(_ t: CGFloat, start: UIColor, middle: UIColor, end: UIColor) -> UIColor {
    if t <= 0.5 {
        return colorAt(t * 2, start: start, end: middle)
    } else {
        return colorAt(t * 2 - 1, start: middle, end: end)
    }
}

private func colorAt(_ t: CGFloat, start: UIColor, end: UIColor) -> UIColor {
    let tt = clamp01(t)

    var r0: CGFloat = 0, g0: CGFloat = 0, b0: CGFloat = 0, a0: CGFloat = 0
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0

    start.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
    end.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

    return UIColor(
        red: lerp(r0, r1, t: tt),
        green: lerp(g0, g1, t: tt),
        blue: lerp(b0, b1, t: tt),
        alpha: lerp(a0, a1, t: tt)
    )
}

private extension CGFloat {
    func toCctColor() -> UIColor {
        colorAt(self, start: UIColor(CCT_END_COLOR), middle: .white, end: UIColor(CCT_START_COLOR))
    }
}

#Preview {
    let viewState = DimmerDetailBase.ViewState()
    viewState.deviceStateData = DeviceStateData(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: "dimmer-on"),
        value: Strings.General.on
    )
    viewState.onButtonState = .init(
        icon: .originalSuplaIcon(name: "dimmer-on"),
        label: Strings.General.turnOn,
        active: true,
        type: .positive
    )
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "dimmer-off"),
        label: Strings.General.turnOff,
        active: false,
        type: .positive
    )
    viewState.value = .single(brightness: 50, cct: 25)
    viewState.loadingState = viewState.loadingState.copy(loading: false)

    return DimmerCctDetailFeature.View(
        viewState: viewState,
        delegate: nil,
    )
}
