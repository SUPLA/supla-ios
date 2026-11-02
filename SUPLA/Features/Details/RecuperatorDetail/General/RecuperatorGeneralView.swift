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

import SharedCore
import SwiftUI
import UIKit

private let recuperatorVectorHeight: CGFloat = 156

extension RecuperatorGeneralFeature {
    protocol ViewDelegate {
        func onVentilationClick()
        func onEmptyHouseClick()
        func onOpenWindowClick()
        func onPowerClick()
        func onManualClick()
        func onProgramClick()
        func onSpeedChanged()
    }

    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        var delegate: ViewDelegate?

        @StateObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                if orientationObserver.orientation.isLandscape {
                    landscapeView
                } else {
                    portraitView
                }
            }
        }

        private var portraitView: some SwiftUI.View {
            VStack(spacing: Distance.default) {
                StateCard()
                    .suplaCard()

                if let mode = viewState.mode {
                    ModeCard(mode: mode)
                        .suplaCard(alignment: .leading)
                }

                Spacer()

                VStack(spacing: Distance.small) {
                    OptionButtons()
                    ModeButtons()
                }
                .padding(Distance.default)
            }
        }

        private var landscapeView: some SwiftUI.View {
            HStack(alignment: .top, spacing: Distance.default) {
                VStack(spacing: Distance.default) {
                    StateCard()
                        .suplaCard(padding: .zero)
                    Spacer()
                    OptionButtons()
                }

                VStack(spacing: Distance.default) {
                    if let mode = viewState.mode {
                        ModeCard(mode: mode)
                            .suplaCard(alignment: .leading, padding: .zero)
                    }

                    Spacer()

                    ModeButtons()
                }
            }
            .padding(Distance.default)
        }

        private func StateCard() -> some SwiftUI.View {
            RecuperatorDiagram(viewState: viewState)
                .frame(height: 160)
                .padding([.top, .bottom], Distance.small)
                .padding([.leading, .trailing], Distance.default)
        }

        @ViewBuilder
        private func ModeCard(mode: RecuperatorGeneralFeature.WorkingMode) -> some SwiftUI.View {
            switch mode {
            case .manual: ManualModeCard()
            case .program: ProgramModeCard()
            }
        }
        
        private func ManualModeCard() -> some SwiftUI.View {
            VStack(
                alignment: .leading,
                spacing: Distance.small
            ) {
                Text(Strings.ThermostatDetail.modeManual.uppercased())
                    .fontBodyLarge()
                    .textColor(.Supla.onSurfaceVariant)
                
                SteppedSlider(
                    value: $viewState.currentSpeed,
                    steps: 4,
                    labels: ["Speed 1", "Speed 2", "Speed 3", "Speed 4"]
                )
                .onChange(of: viewState.currentSpeed) { _ in
                    delegate?.onSpeedChanged()
                }
            }
            .padding([.top, .bottom], Distance.small)
            .padding([.leading, .trailing], Distance.default)
        }
        
        private func ProgramModeCard() -> some SwiftUI.View {
            VStack(
                alignment: .leading,
                spacing: Distance.tiny
            ) {
                Text(Strings.ThermostatDetail.modeWeeklySchedule.uppercased())
                    .fontBodyLarge()
                    .textColor(.Supla.onSurfaceVariant)
                
                Text(Strings.ThermostatDetail.programCurrent)
                    .fontBodySmall()
                    .textColor(.Supla.onSurfaceVariant)
                
                HStack {
                    Text("09:00 - 10:00")
                        .fontLabelLarge()
                    Spacer()
                    Text("A - Tryb wysoki")
                        .fontLabelLarge()
                }
                Divider()
                Text(Strings.ThermostatDetail.programNext)
                    .fontBodySmall()
                    .textColor(.Supla.onSurfaceVariant)
                
                HStack {
                    Text("09:00 - 10:00")
                        .fontBodyLarge()
                    Spacer()
                    Text("A - Tryb wysoki")
                        .fontBodyLarge()
                }
            }
            .padding([.top, .bottom], Distance.small)
            .padding([.leading, .trailing], Distance.default)
        }

        private func OptionButtons() -> some SwiftUI.View {
            HStack(spacing: Distance.small) {
                RoundedControlButton(
                    "Ventilation",
                    fullWidth: true,
                    action: { delegate?.onVentilationClick() }
                )
                RoundedControlButton(
                    "Empty house",
                    fullWidth: true,
                    action: { delegate?.onEmptyHouseClick() }
                )
                RoundedControlButton(
                    "Open window",
                    fullWidth: true,
                    action: { delegate?.onOpenWindowClick() }
                )
            }
        }
        
        private func ModeButtons() -> some SwiftUI.View {
            HStack(spacing: Distance.small) {
                RoundedControlButton(
                    .suplaIcon(name: .Icons.powerButton),
                    type: viewState.isOff ? .negative : .positive,
                    color: viewState.isOff ? .Supla.error : .Supla.primary,
                    action: { delegate?.onPowerClick() }
                )
                RoundedControlButton(
                    Strings.ThermostatDetail.modeManual,
                    type: .positive,
                    active: viewState.mode == .manual,
                    fullWidth: true,
                    action: { delegate?.onManualClick() }
                )
                RoundedControlButton(
                    Strings.ThermostatDetail.modeWeeklySchedule,
                    type: .positive,
                    active: viewState.mode == .program,
                    fullWidth: true,
                    action: { delegate?.onProgramClick() }
                )
            }
        }
    }
}

private struct RecuperatorDiagram: SwiftUI.View {
    @ObservedObject var viewState: RecuperatorGeneralFeature.ViewState

    var body: some SwiftUI.View {
        Canvas { context, size in
            let diagramRect = fittedDiagramRect(in: size)
            let scale = diagramRect.height / recuperatorVectorHeight

            context.drawHousePath(scale: scale, inRect: diagramRect)
            let (arrowLeft, arrowTop, arrowRect) = context.drawCrossLines(scale: scale, inRect: diagramRect)

            let topSupplyPower = viewState.supplyPowerPercent.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.supplyPowerPercent,
                x: arrowLeft - topSupplyPower.width / 2 - 8 * scale,
                y: arrowTop - 3 * scale + topSupplyPower.height / 2,
                textSize: topSupplyPower,
                scale: scale
            )

            let topSupplyInside = viewState.supplyInsideTemperature.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.supplyInsideTemperature,
                x: arrowLeft - topSupplyPower.width - 8 * scale - topSupplyInside.width / 2 - 8 * scale,
                y: arrowTop - 3 * scale + topSupplyInside.height / 2,
                textSize: topSupplyInside,
                scale: scale
            )

            let topSupplyOutside = viewState.supplyOutsideTemperature.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.supplyOutsideTemperature,
                x: arrowLeft + arrowRect.width + 8 * scale + topSupplyOutside.width / 2,
                y: arrowTop - 3 * scale + topSupplyOutside.height / 2,
                textSize: topSupplyOutside,
                scale: scale
            )

            let bottomSupplyPower = viewState.exhaustPowerPercent.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.exhaustPowerPercent,
                x: arrowLeft - bottomSupplyPower.width / 2 - 8 * scale,
                y: arrowTop - bottomSupplyPower.height / 2 + arrowRect.height + bottomSupplyPower.height / 2,
                textSize: bottomSupplyPower,
                scale: scale
            )

            let bottomSupplyInside = viewState.exhaustInsideTemperature.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.exhaustInsideTemperature,
                x: arrowLeft - bottomSupplyPower.width - 8 * scale - bottomSupplyInside.width / 2 - 8 * scale,
                y: arrowTop - bottomSupplyInside.height / 2 + arrowRect.height + bottomSupplyInside.height / 2,
                textSize: bottomSupplyInside,
                scale: scale
            )

            let bottomSupplyOutside = viewState.exhaustOutsideTemperature.boxMetrics(scale: scale)
            context.drawTextInRoundRect(
                text: viewState.exhaustOutsideTemperature,
                x: arrowLeft + arrowRect.width + 8 * scale + bottomSupplyOutside.width / 2,
                y: arrowTop - bottomSupplyOutside.height / 2 + arrowRect.height + bottomSupplyOutside.height / 2,
                textSize: bottomSupplyOutside,
                scale: scale
            )
        }
    }
}

private func fittedDiagramRect(in size: CGSize) -> CGRect {
    let ratio: CGFloat = 1.9
    let widthFromHeight = size.height * ratio

    if widthFromHeight <= size.width {
        return CGRect(
            x: (size.width - widthFromHeight) / 2,
            y: 0,
            width: widthFromHeight,
            height: size.height
        )
    } else {
        let heightFromWidth = size.width / ratio
        return CGRect(
            x: 0,
            y: (size.height - heightFromWidth) / 2,
            width: size.width,
            height: heightFromWidth
        )
    }
}

#Preview("Manual mode") {
    RecuperatorGeneralFeature.View(
        viewState: RecuperatorGeneralFeature.ViewState(
            isOff: true,
            mode: .manual,
            supplyOutsideTemperature: "14.0°",
            supplyInsideTemperature: "22.2°",
            exhaustOutsideTemperature: "15.0°",
            exhaustInsideTemperature: "23.2°",
            supplyPowerPercent: "50%",
            exhaustPowerPercent: "50%"
        ),
        delegate: nil
    )
}

#Preview("Program mode") {
    RecuperatorGeneralFeature.View(
        viewState: RecuperatorGeneralFeature.ViewState(
            isOff: false,
            mode: .program,
            supplyOutsideTemperature: "14.0°",
            supplyInsideTemperature: "22.2°",
            exhaustOutsideTemperature: "15.0°",
            exhaustInsideTemperature: "23.2°",
            supplyPowerPercent: "50%",
            exhaustPowerPercent: "50%"
        ),
        delegate: nil
    )
}
