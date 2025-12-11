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

extension RgbDetailFeature {
    protocol ViewDelegate: ColorDialog.Delegate {
        func onColorSelectionStarted()
        func onColorSelecting(_ color: HsvColor)
        func onColorSelected()
        func turnOn()
        func turnOff()
        func updateSavedColorsOrder(items: [SavedColor])
        func onSavedColorSelected(color: SavedColor)
        func onRemoveColor(color: SavedColor)
        func onSaveCurrentColor()
        func openColorEditorDialog()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?

        @StateObject private var orientationObserver = OrientationObserver()

        init(viewState: ViewState, delegate: ViewDelegate? = nil) {
            self.viewState = viewState
            self.delegate = delegate
        }

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                if (orientationObserver.orientation.isLandscape) {
                    landscape()
                } else {
                    portrait()
                }

                if (viewState.loadingState.loading) {
                    SuplaCore.LoadingScrim()
                }

                if let color = viewState.hexColorEditorValue {
                    RgbDetailFeature.ColorDialog.View(colorString: color, delegate: delegate)
                }
                
                if (viewState.showLimitReachedToast) {
                    ToastView(message: Strings.RgbDetail.colorLimit)
                }
            }
        }

        @ViewBuilder
        private func portrait() -> some SwiftUI.View {
            VStack(spacing: 0) {
                if let stateData = viewState.deviceStateData {
                    DeviceStateView(data: stateData)
                }
                ChannelIssuesView(issues: viewState.issues)

                Spacer()
                colorAndBrightnessBox()

                selectors()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.leading, .trailing], Distance.default)

                Spacer()
                savedColors()
                    .frame(maxWidth: .infinity, alignment: .leading)
                buttons()
            }
        }

        @ViewBuilder
        private func landscape() -> some SwiftUI.View {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    if let stateData = viewState.deviceStateData {
                        DeviceStateView(data: stateData)
                    }
                    ChannelIssuesView(issues: viewState.issues)
                    colorAndBrightnessBox()
                    Spacer()
                    savedColors()
                    buttons()
                }
                .frame(maxWidth: .infinity)

                selectors()
                    .frame(maxWidth: .infinity)
                    .padding(Distance.default)
            }
        }

        @ViewBuilder
        private func colorAndBrightnessBox() -> some SwiftUI.View {
            HStack(spacing: Distance.tiny) {
                Text(Strings.RgbDetail.color)
                    .fontLabelMedium()
                    .textColor(.Supla.onSurfaceVariant)
                RgbDetailFeature.ColorBox(color: viewState.value.hsv?.color)
                Spacer().frame(width: Distance.default)
                Text(Strings.RgbDetail.brightness)
                    .fontLabelMedium()
                    .textColor(.Supla.onSurfaceVariant)
                Text(viewState.value.brightnessString)
                    .fontBodyMedium()
                    .textColor(.Supla.onBackground)
            }
            .padding([.leading, .trailing], Distance.default)
            .padding([.top, .bottom], Distance.small)
            .background(Color.Supla.surface.clipShape(RoundedRectangle(cornerRadius: Dimens.radiusDefault)))
            .padding(Distance.default)
            .onTapGesture { delegate?.openColorEditorDialog() }
        }

        @ViewBuilder
        private func selectors() -> some SwiftUI.View {
            HStack {
                CircularColorSelector(
                    currentColor: viewState.value.hsv?.color,
                    currentSaturation: viewState.value.hsv?.saturation.cgFloat,
                    currentHue: viewState.value.hsv?.hue.cgFloat,
                    enabled: !viewState.offline,
                    markers: viewState.value.markers,
                    onDragStart: { delegate?.onColorSelectionStarted() },
                    onDrag: { hue, saturation in
                        let color = viewState.value.hsv?.copy(hue: hue, saturation: saturation) ?? HsvColor(hue: hue, saturation: saturation)
                        delegate?.onColorSelecting(color)
                    },
                    onDragEnd: { delegate?.onColorSelected() }
                )
                LinearColorSelector(
                    value: viewState.value.hsv?.value.cgFloat,
                    selectedColor: viewState.value.hsv?.color,
                    valueMarkers: viewState.value.markers.map { $0.value.cgFloat },
                    enabled: !viewState.offline,
                    startColor: Color(viewState.value.hsv?.fullBrightnessColor ?? UIColor.white),
                    onValueChangeStarted: { delegate?.onColorSelectionStarted() },
                    onValueChanging: { value in
                        let color = viewState.value.hsv?.copy(value: value) ?? HsvColor(value: value)
                        delegate?.onColorSelecting(color)
                    },
                    onValueChanged: { delegate?.onColorSelected() }
                )
                .frame(width: 40)
            }
        }

        @ViewBuilder
        private func savedColors() -> some SwiftUI.View {
            ReorderableHStack(
                items: $viewState.savedColors,
                onReorderEnd: { delegate?.updateSavedColorsOrder(items: $0) },
                onPlaceholderTap: { delegate?.onSaveCurrentColor() },
                onDelete: { delegate?.onRemoveColor(color: $0) },
                onItemTap: { delegate?.onSavedColorSelected(color: $0) },
                placeholder: { SavedColorAction(dragging: $0, over: $1) }
            ) { SavedColorBox(color: $0.color) }
                .padding(.horizontal, Distance.small)
        }

        @ViewBuilder
        private func buttons() -> some SwiftUI.View {
            if let onButtonState = viewState.onButtonState,
               let offButtonState = viewState.offButtonState
            {
                SwitchButtons(
                    leftButton: offButtonState,
                    rightButton: onButtonState,
                    enabled: !viewState.offline,
                    onLeftButtonClick: { delegate?.turnOff() },
                    onRightButtonClick: { delegate?.turnOn() }
                )
            }
        }
    }

    struct SavedColorAction: SwiftUI.View {
        let dragging: Bool
        let over: Bool

        var body: some SwiftUI.View {
            let color: Color = over ? .Supla.error : .Supla.onSurfaceVariant
            let iconSize: CGFloat = dragging ? 16 : 12
            let icon: String = dragging ? .Icons.delete : .Icons.plus

            ZStack {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .tint(color)
                    .foregroundColor(color)
            }
            .frame(width: 42, height: 36)
            .overlay(
                RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                    .stroke(color, lineWidth: 1)
            )
            .padding(Distance.tiny)
        }
    }

    struct SavedColorBox: SwiftUI.View {
        let color: UIColor

        var body: some SwiftUI.View {
            RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                .fill(Color(color))
                .frame(width: 42, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: Dimens.radiusSmall)
                        .stroke(Color.Supla.onSurfaceVariant, lineWidth: 1)
                )
                .padding(Distance.tiny)
        }
    }
}

#Preview {
    let viewState = RgbDetailFeature.ViewState()
    viewState.deviceStateData = DeviceStateData(
        label: Strings.SwitchDetail.stateLabel,
        icon: .suplaIcon(name: "rgb-on"),
        value: Strings.General.on
    )
    viewState.onButtonState = .init(
        icon: .originalSuplaIcon(name: "rgb-on"),
        label: Strings.General.turnOn,
        active: true,
        type: .positive
    )
    viewState.offButtonState = .init(
        icon: .originalSuplaIcon(name: "rgb-off"),
        label: Strings.General.turnOff,
        active: false,
        type: .positive
    )
    viewState.value = .single(color: HsvColor(hue: 0, saturation: 1, value: 1))
    viewState.savedColors = [
        RgbDetailFeature.SavedColor(idx: 1, color: UIColor.white, brightness: 100),
        RgbDetailFeature.SavedColor(idx: 2, color: UIColor.red, brightness: 100),
        RgbDetailFeature.SavedColor(idx: 3, color: UIColor(argb: 0xffff00ff), brightness: 100),
        RgbDetailFeature.SavedColor(idx: 4, color: UIColor(argb: 0xff0000ff), brightness: 100)
    ]
    viewState.loadingState = viewState.loadingState.copy(loading: false)

    return RgbDetailFeature.View(
        viewState: viewState,
        delegate: nil,
    )
}
