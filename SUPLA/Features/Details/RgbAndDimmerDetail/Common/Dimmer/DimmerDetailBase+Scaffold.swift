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

extension DimmerDetailBase {
    protocol ViewDelegate {
        func toggleSelectorType()
        func updateSavedColorsOrder(items: [SavedColor])
        func onSavedColorSelected(color: SavedColor)
        func onRemoveColor(color: SavedColor)
        func onSaveCurrentColor()
        func turnOn()
        func turnOff()
    }
    
    struct Scaffold<
        BrightnessBox: View,
        BrightnessControl: View,
        SavedColorItemContent: View
    >: View {
        var delegate: ViewDelegate?
        
        @ViewBuilder let brightnessBox: () -> BrightnessBox
        @ViewBuilder let brightnessControl: () -> BrightnessControl
        @ViewBuilder let savedColorItemContent: (SavedColor) -> SavedColorItemContent
        
        @EnvironmentObject private var viewState: ViewState
        @ObservedObject private var orientationObserver = OrientationObserver()
        
        var body: some View {
            BackgroundStack(alignment: .top) {
                if (orientationObserver.orientation.isLandscape) {
                    landscape()
                } else {
                    portrait()
                }

                if (viewState.loadingState.loading) {
                    SuplaCore.LoadingScrim()
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
                brightnessBox()
                selector()

                Spacer()
                savedColors()
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
                    
                    brightnessBox()
                    Spacer()
                    
                    savedColors()
                    buttons()
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 0) {
                    selector()
                        .padding(Distance.default)
                }
                .frame(maxWidth: .infinity)
            }
        }
        
        @ViewBuilder
        private func selector() -> some SwiftUI.View {
            ZStack(alignment: .top) {
                brightnessControl()
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                RoundedControlButtonWrapperView(
                    type: .neutral,
                    icon: .suplaIcon(name: viewState.selectorType.swapIcon),
                    onTap: { delegate?.toggleSelectorType() }
                )
                .frame(width: Dimens.buttonHeight, height: Dimens.buttonHeight, alignment: .topTrailing)
                .padding(.trailing, Distance.default)
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
                placeholder: { SavedColorAction() }
            ) { savedColorItemContent($0) }
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
}
