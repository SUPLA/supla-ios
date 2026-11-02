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

extension DetailBaseFeature {
    struct DetailTabBar: SwiftUI.View {
        @Singleton<RuntimeConfig> private var runtimeConfig

        let remoteId: Int32
        let pages: [DetailPage]
        @Binding var selectedPage: DetailPage
        let axis: Axis
        let showLabels: Bool

        private var tabItemHeight: CGFloat {
            showLabels ? 56 : Dimens.iconSize + Distance.tiny * 2
        }

        var body: some SwiftUI.View {
            Group {
                switch axis {
                case .horizontal:
                    HStack(spacing: 0) {
                        tabItems
                    }
                    .frame(height: tabItemHeight)

                case .vertical:
                    VStack(spacing: 0) {
                        tabItems
                        Spacer(minLength: 0)
                    }
                    .frame(width: 84)
                }
            }
            .background(Color.Supla.surface)
            .overlay(alignment: axis == .horizontal ? .top : .trailing) {
                Rectangle()
                    .fill(Color.Supla.outline)
                    .frame(
                        width: axis == .horizontal ? nil : 1,
                        height: axis == .horizontal ? 1 : nil
                    )
            }
        }

        private var tabItems: some SwiftUI.View {
            ForEach(pages, id: \.self) { page in
                Button(action: { select(page) }) {
                    VStack(spacing: Distance.tiny) {
                        Image(page.iconName)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSize, height: Dimens.iconSize)

                        if (showLabels) {
                            Text(page.title)
                                .fontLabelSmall()
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: tabItemHeight)
                    .foregroundColor(selectedPage == page ? .Supla.primary : .Supla.onBackground)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }

        private func select(_ page: DetailPage) {
            selectedPage = page
            if let openedPage = pages.firstIndex(of: page) {
                runtimeConfig.setDetailOpenedPage(remoteId: remoteId, openedPage: openedPage)
            }
        }
    }
}

private extension DetailPage {
    var title: String {
        switch self {
        case .switchTimer, .thermostatTimer: Strings.StandardDetail.tabTimer
        case .thermostatList: Strings.StandardDetail.tabList
        case .schedule: Strings.StandardDetail.tabSchedule
        case .thermostatHistory,
             .thermometerHistory,
             .gpmHistory,
             .electricityMeterHistory,
             .humidityHistory,
             .impulseCounterHistory,
             .thermostatHeatpolHistory: Strings.StandardDetail.tabHistory
        case .electricityMeterSettings,
             .impulseCounterSettings,
             .recuperatorGeneral: Strings.StandardDetail.tabSettings
        case .impulseCounterOcr: Strings.StandardDetail.tabOcr
        case .rgb: Strings.StandardDetail.tabRgb
        case .dimmer, .dimmerCct: Strings.StandardDetail.tabDimmer
        case .switchGeneral,
             .thermostatGeneral,
             .thermostatHeatpolGeneral,
             .rollerShutter,
             .roofWindow,
             .facadeBlind,
             .terraceAwning,
             .projectorScreen,
             .curtain,
             .verticalBlind,
             .garageDoor,
             .electricityMeterGeneral,
             .impulseCounterGeneral,
             .valveGeneral,
             .containerGeneral,
             .gateGeneral: Strings.StandardDetail.tabGeneral
        }
    }

    var iconName: String {
        switch self {
        case .switchTimer, .thermostatTimer: String.Icons.timer
        case .thermostatList: String.Icons.list
        case .schedule: String.Icons.schedule
        case .thermostatHistory,
             .thermometerHistory,
             .gpmHistory,
             .electricityMeterHistory,
             .humidityHistory,
             .impulseCounterHistory,
             .thermostatHeatpolHistory: String.Icons.history
        case .electricityMeterSettings,
             .impulseCounterSettings,
             .recuperatorGeneral: String.Icons.settings
        case .impulseCounterOcr: String.Icons.ocrPhoto
        case .rgb: String.Icons.rgb
        case .dimmer, .dimmerCct: String.Icons.dimmer
        case .switchGeneral,
             .thermostatGeneral,
             .thermostatHeatpolGeneral,
             .rollerShutter,
             .roofWindow,
             .facadeBlind,
             .terraceAwning,
             .projectorScreen,
             .curtain,
             .verticalBlind,
             .garageDoor,
             .electricityMeterGeneral,
             .impulseCounterGeneral,
             .valveGeneral,
             .containerGeneral,
             .gateGeneral: String.Icons.general
        }
    }
}
