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
    struct BaseScreen<S: DetailViewState, VM: BaseDetailVM<S>>: SwiftUI.View {
        @EnvironmentObject private var router: AppRouter
        @Singleton<GlobalSettings> private var settings

        private let item: ItemBundle
        private let pages: [DetailPage]
        private let viewModel: VM
        private let topBarActionsProvider: (S, DetailPage) -> [TopBarAction]

        @State private var selectedPage: DetailPage

        init(
            viewModel: VM,
            item: ItemBundle,
            pages: [DetailPage],
            topBarActionsProvider: @escaping (S, DetailPage) -> [TopBarAction] = { _, _ in [] }
        ) {
            self.viewModel = viewModel
            self.item = item
            self.pages = pages
            self.topBarActionsProvider = topBarActionsProvider
            _selectedPage = State(initialValue: Self.initialPage(item: item, pages: pages))
        }

        var body: some SwiftUI.View {
            SuplaCore.ViewModelHost(viewModel) { state in
                ZStack(alignment: .top) {
                    Color.Supla.background
                        .ignoresSafeArea()

                    Color.Supla.primaryContainer
                        .frame(height: SuplaCore.TopBar.height)
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 0) {
                        DetailTopBar(
                            state: state,
                            pages: pages,
                            selectedPage: selectedPage,
                            actionsProvider: topBarActionsProvider
                        )

                        GeometryReader { geometry in
                            if (geometry.size.width > geometry.size.height) {
                                HStack(spacing: 0) {
                                    detailTabBar(axis: .vertical)
                                    selectedContent
                                }
                            } else {
                                VStack(spacing: 0) {
                                    selectedContent
                                    detailTabBar(axis: .horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .onTopBarEvent(
                .openElectricityMeterSettings,
                enabled: pages.contains(.electricityMeterSettings)
            ) { router.navigate(to: .electricityMeterSettings(item: item)) }
            .onTopBarEvent(
                .openImpulseCounterSettings,
                enabled: pages.contains(.impulseCounterSettings)
            ) { router.navigate(to: .impulseCounterSettings(item: item)) }
            .onTopBarEvent(
                .openDimmerSettings,
                enabled: pages.contains(.dimmerSettings)
            ) { router.navigate(to: .legacyDimmerSettings(channelId: item.remoteId)) }
        }

        private var selectedContent: some SwiftUI.View {
            ZStack {
                destination(for: selectedPage)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        @ViewBuilder
        private func destination(for page: DetailPage) -> some SwiftUI.View {
            switch page {
            case .switchGeneral:
                SwitchGeneralFeature.Screen(itemBundle: item)
            case .switchSchedule:
                RelayScheduleFeature.Screen(itemBundle: item)
            case .switchTimer:
                SwitchTimerDetailFeature.Screen(itemBundle: item)
            case .thermostatGeneral:
                ThermostatGeneralFeature.Screen(itemBundle: item)
            case .thermostatList:
                ThermostatSlavesFeature.Screen(itemBundle: item)
            case .schedule:
                ThermostatScheduleDetailFeature.Screen(itemBundle: item)
            case .thermostatTimer:
                ThermostatTimerDetailFeature.Screen(itemBundle: item)
            case .thermostatHistory:
                ThermostatHistoryDetailFeature.Screen(itemBundle: item)
            case .thermostatHeatpolGeneral:
                DetailViewControllerScreen(itemBundle: item, detailViewType: .thermostat_hp)
            case .thermostatHeatpolHistory:
                HeatpolHistoryDetailFeature.Screen(itemBundle: item)
            case .thermometerHistory:
                ThermometerHistoryDetailFeature.Screen(itemBundle: item)
            case .humidityHistory:
                HumidityHistoryDetailFeature.Screen(itemBundle: item)
            case .gpmHistory:
                GpmHistoryDetailFeature.Screen(itemBundle: item)
            case .rollerShutter:
                RollerShutterFeature.Screen(itemBundle: item)
            case .roofWindow:
                RoofWindowFeature.Screen(itemBundle: item)
            case .facadeBlind:
                FacadeBlindsFeature.Screen(itemBundle: item)
            case .terraceAwning:
                TerraceAwningFeature.Screen(itemBundle: item)
            case .projectorScreen:
                ProjectorScreenFeature.Screen(itemBundle: item)
            case .curtain:
                CurtainFeature.Screen(itemBundle: item)
            case .verticalBlind:
                VerticalBlindsFeature.Screen(itemBundle: item)
            case .garageDoor:
                GarageDoorFeature.Screen(itemBundle: item)
            case .electricityMeterGeneral:
                ElectricityMeterGeneralFeature.Screen(itemBundle: item)
            case .electricityMeterHistory:
                ElectricityMeterHistoryFeature.Screen(itemBundle: item)
            case .impulseCounterGeneral:
                ImpulseCounterGeneralFeature.Screen(itemBundle: item)
            case .impulseCounterHistory:
                ImpulseCounterHistoryDetailFeature.Screen(itemBundle: item)
            case .impulseCounterOcr:
                CounterPhotoFeature.Screen(itemBundle: item)
            case .valveGeneral:
                ValveGeneralFeature.Screen(itemBundle: item)
            case .containerGeneral:
                ContainerGeneralFeature.Screen(itemBundle: item)
            case .gateGeneral:
                GateGeneralFeature.Screen(itemBundle: item)
            case .actionTriggerGeneral:
                ActionTriggerGeneralFeature.Screen(itemBundle: item)
            case .actionTriggerSchedule:
                ActionTriggerScheduleFeature.Screen(itemBundle: item)
            case .gateSchedule:
                RelayScheduleFeature.Screen(itemBundle: item)
            case .recuperatorGeneral:
                RecuperatorGeneralFeature.Screen(itemBundle: item)
            case .rgb:
                RgbDetailFeature.Screen(itemBundle: item)
            case .dimmer:
                DimmerDetailFeature.Screen(itemBundle: item)
            case .dimmerCct:
                DimmerCctDetailFeature.Screen(itemBundle: item)
            default:
                EmptyView()
            }
        }

        @ViewBuilder
        private func detailTabBar(axis: Axis) -> some SwiftUI.View {
            let bottomBarPages = pages.filter { $0.iconDestination == .bottomBar }
            if (bottomBarPages.count > 1) {
                DetailTabBar(
                    remoteId: item.remoteId,
                    pages: bottomBarPages,
                    selectedPage: $selectedPage,
                    axis: axis,
                    showLabels: settings.showBottomLabels
                )
            }
        }

        private static func initialPage(item: ItemBundle, pages: [DetailPage]) -> DetailPage {
            let bottomBarPages = pages.filter { $0.iconDestination == .bottomBar }
            guard let firstPage = bottomBarPages.first else {
                fatalError("BaseDetailScreen requires at least one detail page")
            }

            let runtimeConfig = DiContainer.shared.resolve(type: RuntimeConfig.self)
            let pageToOpen = runtimeConfig?.getDetailOpenedPage(remoteId: item.remoteId) ?? -1
            if (pageToOpen >= 0 && pageToOpen < bottomBarPages.count) {
                return bottomBarPages[pageToOpen]
            }

            return firstPage
        }
    }
}

private struct DetailTopBar<S: DetailViewState>: SwiftUI.View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var state: S
    @ObservedObject private var topBarCoordinator: TopBarActionCoordinator = DiContainer.shared.resolve(
        type: TopBarActionCoordinator.self
    )!

    let pages: [DetailPage]
    let selectedPage: DetailPage
    let actionsProvider: (S, DetailPage) -> [TopBarAction]

    var body: some SwiftUI.View {
        let pageActions = pages.compactMap { action(for: $0) }
        let actions = pageActions + actionsProvider(state, selectedPage) + topBarCoordinator.actions

        SuplaCore.TopBar(
            navigationIcon: .back,
            title: state.title ?? "",
            actions: actions,
            onNavigationIconTap: router.back
        )
    }

    private func action(for page: DetailPage) -> TopBarAction? {
        guard page.iconDestination == .topBar else { return nil }

        switch page {
        case .electricityMeterSettings: return .detailElectricityMeterSettings
        case .impulseCounterSettings: return .detailImpulseCounterSettings
        case .dimmerSettings: return .detailDimmerSettings
        default:
            return nil
        }
    }
}
