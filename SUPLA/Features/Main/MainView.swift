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
import UIKit

extension MainFeature {
    struct View: SwiftUI.View {
        @EnvironmentObject private var router: AppRouter

        @ObservedObject var viewState: ViewState

        @Binding var selectedTab: MainTab

        let showBottomMenu: Bool
        let showBottomLabels: Bool

        @State private var drawerOpened = false
        @State private var profileChooserOpened = false
        @State private var channelsSearchActive = false
        @State private var groupsSearchActive = false
        @State private var scenesSearchActive = false

        @StateObject private var channelListViewModel = ChannelListFeature.ViewModel()
        @StateObject private var groupListViewModel = GroupListFeature.ViewModel()
        @StateObject private var sceneListViewModel = SceneListFeature.ViewModel()

        @StateObject private var channelsTopBarBehavior = CollapsibleTopBarBehavior(height: SuplaCore.TopBar.height)
        @StateObject private var groupsTopBarBehavior = CollapsibleTopBarBehavior(height: SuplaCore.TopBar.height)
        @StateObject private var scenesTopBarBehavior = CollapsibleTopBarBehavior(height: SuplaCore.TopBar.height)

        private let drawerAnimation = Animation.easeInOut(duration: 0.2)

        var body: some SwiftUI.View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Color.Supla.primaryContainer
                        .ignoresSafeArea(edges: .top)

                    content

                    Color.Supla.primaryContainer
                        .frame(height: geometry.safeAreaInsets.top)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(edges: .top)
                        .allowsHitTesting(false)

                    Color.black
                        .opacity(drawerOpened ? 0.32 : 0)
                        .ignoresSafeArea()
                        .allowsHitTesting(drawerOpened)
                        .onTapGesture(perform: closeDrawer)

                    MainDrawer(
                        configuration: drawerConfiguration,
                        onClose: closeDrawer,
                        onItemTap: onDrawerItemTap
                    )
                    .frame(width: drawerWidth(for: geometry.size), height: geometry.size.height)
                    .offset(x: drawerOpened ? 0 : -drawerWidth(for: geometry.size))
                    .allowsHitTesting(drawerOpened)

                    if (profileChooserOpened) {
                        ProfileChooserFeature.Dialog(onDismissed: closeProfileChooser)
                    }
                }
                .animation(drawerAnimation, value: drawerOpened)
            }
        }

        private var content: some SwiftUI.View {
            VStack(spacing: 0) {
                topBar
                    .frame(height: activeTopBarBehavior.visibleHeight)
                    .clipped()

                GeometryReader { geometry in
                    if (geometry.size.width > geometry.size.height) {
                        HStack(spacing: 0) {
                            if (showBottomMenu) {
                                MainTabBar(selectedTab: $selectedTab, axis: .vertical, showLabels: showBottomLabels)
                            }
                            selectedContent
                        }
                    } else {
                        VStack(spacing: 0) {
                            selectedContentWithBottomSafeArea
                            if (showBottomMenu) {
                                MainTabBar(selectedTab: $selectedTab, axis: .horizontal, showLabels: showBottomLabels)
                            }
                        }
                    }
                }
            }
        }

        private var selectedContentWithBottomSafeArea: some SwiftUI.View {
            selectedContent
                .ignoresSafeArea(edges: showBottomMenu ? [] : .bottom)
        }

        private var topBar: some SwiftUI.View {
            SuplaCore.TopBar(
                navigationIcon: .menu,
                title: Strings.appName,
                actionIcon: viewState.showProfilesIcon ? .icon("profile-navbar", openProfileChooser) : nil,
                searchText: activeSearchTextBinding,
                searchActive: activeSearchActiveBinding,
                onNavigationIconTap: openDrawer,
                onSearchActiveChange: onSearchActiveChange
            )
            .offset(y: activeTopBarBehavior.offset)
        }

        private var activeSearchTextBinding: Binding<String> {
            Binding(
                get: {
                    switch selectedTab {
                    case .channels:
                        channelListViewModel.state.searchText
                    case .groups:
                        groupListViewModel.state.searchText
                    case .scenes:
                        sceneListViewModel.state.searchText
                    }
                },
                set: {
                    switch selectedTab {
                    case .channels:
                        channelListViewModel.onSearchTextChanged($0)
                    case .groups:
                        groupListViewModel.onSearchTextChanged($0)
                    case .scenes:
                        sceneListViewModel.onSearchTextChanged($0)
                    }
                }
            )
        }

        private var activeSearchActiveBinding: Binding<Bool> {
            Binding(
                get: { activeSearchActive },
                set: {
                    switch selectedTab {
                    case .channels:
                        channelsSearchActive = $0
                    case .groups:
                        groupsSearchActive = $0
                    case .scenes:
                        scenesSearchActive = $0
                    }
                }
            )
        }

        private var activeSearchActive: Bool {
            switch selectedTab {
            case .channels:
                channelsSearchActive
            case .groups:
                groupsSearchActive
            case .scenes:
                scenesSearchActive
            }
        }

        private var activeTopBarBehavior: CollapsibleTopBarBehavior {
            switch selectedTab {
            case .channels:
                channelsTopBarBehavior
            case .groups:
                groupsTopBarBehavior
            case .scenes:
                scenesTopBarBehavior
            }
        }

        private var drawerConfiguration: MainDrawer.Configuration {
            .init(
                showMainTabs: !showBottomMenu,
                selectedTab: selectedTab,
                zWaveVisible: BrandingConfiguration.Menu.Z_WAVE_OPTION_VISIBLE && viewState.showZWave,
                deviceCatalogVisible: BrandingConfiguration.Menu.DEVICES_OPTION_VISIBLE,
                helpVisible: BrandingConfiguration.Menu.HELP_OPTION_VISIBLE,
                aboutVisible: BrandingConfiguration.Menu.ABOUT_OPTION_VISIBLE,
                developerOptionsVisible: GlobalSettingsLegacy.devModeActive
            )
        }

        private func drawerWidth(for size: CGSize) -> CGFloat {
            min(320, size.width * 0.86)
        }

        private func openDrawer() {
            drawerOpened = true
        }

        private func closeDrawer() {
            drawerOpened = false
        }

        private func openProfileChooser() {
            profileChooserOpened = true
        }

        private func closeProfileChooser() {
            profileChooserOpened = false
        }

        private func onSearchActiveChange(_ active: Bool) {
            if (active) {
                activeTopBarBehavior.expand()
            } else {
                activeSearchTextBinding.wrappedValue = ""
            }
        }

        private func onContentScroll(_ delta: CGFloat) {
            activeTopBarBehavior.scroll(delta: delta, canCollapse: !activeSearchActive)
        }

        private func onContentScrollEnded(atTop: Bool) {
            if (atTop) {
                activeTopBarBehavior.expand()
            } else {
                activeTopBarBehavior.snapToNearestEdge()
            }
        }

        private func onDrawerItemTap(_ item: MainDrawer.Item) {
            switch item {
            case .channels:
                selectedTab = .channels
            case .groups:
                selectedTab = .groups
            case .scenes:
                selectedTab = .scenes
            case .profiles:
                router.navigate(to: .profiles)
            case .settings:
                router.navigate(to: .settings)
            case .addDevice:
                router.navigate(to: .addWizard)
            case .zWave:
                router.openZWaveWizard()
            case .deviceCatalog:
                router.navigate(to: .deviceCatalog)
            case .notifications:
                router.navigate(to: .notificationsLog)
            case .cloud:
                router.openCloud()
            case .help:
                router.openForum()
            case .about:
                router.navigate(to: .about)
            case .developerOptions:
                router.navigate(to: .developerOptions)
            case .homepage:
                router.openHomepage()
            }

            closeDrawer()
        }

        @ViewBuilder
        private var selectedContent: some SwiftUI.View {
            switch selectedTab {
            case .channels:
                ChannelListFeature.Screen(
                    viewModel: channelListViewModel,
                    onScroll: onContentScroll,
                    onScrollEnded: onContentScrollEnded
                )

            case .groups:
                GroupListFeature.Screen(
                    viewModel: groupListViewModel,
                    onScroll: onContentScroll,
                    onScrollEnded: onContentScrollEnded
                )

            case .scenes:
                SceneListFeature.Screen(
                    viewModel: sceneListViewModel,
                    onScroll: onContentScroll,
                    onScrollEnded: onContentScrollEnded
                )
            }
        }
    }
}

private final class CollapsibleTopBarBehavior: ObservableObject {
    @Published private(set) var offset: CGFloat = 0

    private let height: CGFloat
    private let snapAnimation = Animation.easeOut(duration: 0.2)

    var visibleHeight: CGFloat {
        max(0, height + offset)
    }

    init(height: CGFloat) {
        self.height = height
    }

    func scroll(delta: CGFloat, canCollapse: Bool) {
        if (!canCollapse && delta > 0) {
            return
        }

        offset = min(0, max(-height, offset - delta))
    }

    func expand() {
        withAnimation(snapAnimation) {
            offset = 0
        }
    }

    func snapToNearestEdge() {
        let target = offset > -height / 2 ? CGFloat(0) : -height
        withAnimation(snapAnimation) {
            offset = target
        }
    }
}

private struct ViewControllerHost<Controller: UIViewController>: UIViewControllerRepresentable {
    let create: () -> Controller
    let onScroll: (CGFloat) -> Void
    let onScrollEnded: (Bool) -> Void

    init(
        onScroll: @escaping (CGFloat) -> Void = { _ in },
        onScrollEnded: @escaping (Bool) -> Void = { _ in },
        create: @escaping () -> Controller
    ) {
        self.create = create
        self.onScroll = onScroll
        self.onScrollEnded = onScrollEnded
    }

    func makeUIViewController(context: Context) -> Controller {
        let controller = create()
        context.coordinator.attach(to: controller.view)
        return controller
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        context.coordinator.onScroll = onScroll
        context.coordinator.onScrollEnded = onScrollEnded
        context.coordinator.attach(to: uiViewController.view)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScroll: onScroll, onScrollEnded: onScrollEnded)
    }

    final class Coordinator: NSObject {
        var onScroll: (CGFloat) -> Void
        var onScrollEnded: (Bool) -> Void

        private weak var scrollView: UIScrollView?
        private var contentOffsetObservation: NSKeyValueObservation?
        private var contentSizeObservation: NSKeyValueObservation?
        private var lastEffectiveContentOffsetY: CGFloat?
        private var lastContentHeight: CGFloat?

        init(onScroll: @escaping (CGFloat) -> Void, onScrollEnded: @escaping (Bool) -> Void) {
            self.onScroll = onScroll
            self.onScrollEnded = onScrollEnded
        }

        func attach(to view: UIKit.UIView) {
            guard let scrollView = view.firstScrollView(), self.scrollView !== scrollView else { return }

            self.scrollView?.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
            self.scrollView = scrollView
            lastEffectiveContentOffsetY = scrollView.effectiveContentOffsetY
            lastContentHeight = scrollView.contentSize.height

            contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, _ in
                self?.handleContentOffsetChange(scrollView)
            }
            contentSizeObservation = scrollView.observe(\.contentSize, options: [.new]) { [weak self] scrollView, _ in
                self?.handleContentSizeChange(scrollView)
            }
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        }

        private func handleContentOffsetChange(_ scrollView: UIScrollView) {
            let contentOffsetY = scrollView.effectiveContentOffsetY

            guard scrollView.isUserScrolling, scrollView.canScrollVertically else {
                lastEffectiveContentOffsetY = contentOffsetY
                return
            }

            guard let lastEffectiveContentOffsetY else {
                self.lastEffectiveContentOffsetY = contentOffsetY
                return
            }

            let delta = contentOffsetY - lastEffectiveContentOffsetY
            self.lastEffectiveContentOffsetY = contentOffsetY

            if (abs(delta) > 0.1) {
                dispatchScroll(delta)
            }
        }

        private func handleContentSizeChange(_ scrollView: UIScrollView) {
            defer { lastContentHeight = scrollView.contentSize.height }

            guard let lastContentHeight else { return }

            let contentShrunk = scrollView.contentSize.height < lastContentHeight - 1
            if (contentShrunk || !scrollView.canScrollVertically) {
                lastEffectiveContentOffsetY = scrollView.effectiveContentOffsetY
                dispatchScrollEnded(atTop: true)
            }
        }

        @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .ended, .cancelled, .failed:
                if let scrollView, scrollView.canScrollVertically {
                    dispatchScrollEnded(atTop: scrollView.isAtTop)
                }
            default:
                break
            }
        }

        private func dispatchScroll(_ delta: CGFloat) {
            DispatchQueue.main.async { [onScroll] in
                onScroll(delta)
            }
        }

        private func dispatchScrollEnded(atTop: Bool) {
            DispatchQueue.main.async { [onScrollEnded] in
                onScrollEnded(atTop)
            }
        }
    }
}

private extension UIKit.UIView {
    func firstScrollView() -> UIScrollView? {
        if let scrollView = self as? UIScrollView {
            return scrollView
        }

        for subview in subviews {
            if let scrollView = subview.firstScrollView() {
                return scrollView
            }
        }

        return nil
    }
}

private extension UIScrollView {
    var isUserScrolling: Bool {
        isTracking || isDragging || isDecelerating
    }

    var canScrollVertically: Bool {
        let contentHeight = contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom
        return contentHeight > bounds.height + 1
    }

    var effectiveContentOffsetY: CGFloat {
        min(max(contentOffset.y, minContentOffsetY), maxContentOffsetY)
    }

    var isAtTop: Bool {
        effectiveContentOffsetY <= minContentOffsetY + 1
    }

    private var minContentOffsetY: CGFloat {
        -adjustedContentInset.top
    }

    private var maxContentOffsetY: CGFloat {
        max(minContentOffsetY, contentSize.height - bounds.height + adjustedContentInset.bottom)
    }
}
