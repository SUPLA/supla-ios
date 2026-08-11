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

protocol NavigationItemProvider: AnyObject {
    var navigationItem: UINavigationItem { get }
}

struct DetailTopBarAction {
    let icon: String
    let onTap: () -> Void
}

extension DetailBaseFeature {
    struct BaseScreen<S: DetailViewState, VM: BaseDetailVM<S>>: SwiftUI.View {
        @Singleton<GlobalSettings> private var settings

        private let item: ItemBundle
        private let pages: [DetailPage]
        private let viewModel: VM
        private let topBarActionProvider: (S, DetailPage) -> DetailTopBarAction?

        @State private var selectedPage: DetailPage

        init(
            viewModel: VM,
            item: ItemBundle,
            pages: [DetailPage],
            topBarActionProvider: @escaping (S, DetailPage) -> DetailTopBarAction? = { _, _ in nil }
        ) {
            self.viewModel = viewModel
            self.item = item
            self.pages = pages
            self.topBarActionProvider = topBarActionProvider
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
                            selectedPage: selectedPage,
                            actionProvider: topBarActionProvider
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
            default:
                EmptyView()
            }
        }

        @ViewBuilder
        private func detailTabBar(axis: Axis) -> some SwiftUI.View {
            if (pages.count > 1) {
                DetailTabBar(
                    remoteId: item.remoteId,
                    pages: pages,
                    selectedPage: $selectedPage,
                    axis: axis,
                    showLabels: settings.showBottomLabels
                )
            }
        }

        private static func initialPage(item: ItemBundle, pages: [DetailPage]) -> DetailPage {
            guard let firstPage = pages.first else {
                fatalError("BaseDetailScreen requires at least one detail page")
            }

            let runtimeConfig = DiContainer.shared.resolve(type: RuntimeConfig.self)
            let pageToOpen = runtimeConfig?.getDetailOpenedPage(remoteId: item.remoteId) ?? -1
            if (pageToOpen >= 0 && pageToOpen < pages.count) {
                return pages[pageToOpen]
            }

            return firstPage
        }
    }
}

private struct DetailTopBar<S: DetailViewState>: SwiftUI.View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var state: S

    let selectedPage: DetailPage
    let actionProvider: (S, DetailPage) -> DetailTopBarAction?

    var body: some SwiftUI.View {
        let action = actionProvider(state, selectedPage)

        SuplaCore.TopBar(
            navigationIcon: .back,
            title: state.title ?? "",
            actionIcon: action?.icon,
            onNavigationIconTap: router.back,
            onActionIconTap: {
                action?.onTap()
            }
        )
    }
}
