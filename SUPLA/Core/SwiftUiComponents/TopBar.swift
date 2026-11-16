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

import Combine
import SwiftUI

enum TopBarEvent: Hashable {
    case openProfileSelector
    case deleteNotifications
    case deleteNfcTag
    case deleteHistoryData
    case openImpulseCounterOcr
    case openDimmerSettings
    case openElectricityMeterSettings
    case openImpulseCounterSettings
}

enum TopBarAction: Hashable {
    case profileSelect
    case notificationsDelete
    case nfcTagDelete
    case historyDeleteData
    case impulseCounterOpenOcr
    case detailDimmerSettings
    case detailElectricityMeterSettings
    case detailImpulseCounterSettings

    var title: String {
        switch self {
        case .profileSelect: Strings.ProfileChooser.title
        case .notificationsDelete, .nfcTagDelete: Strings.General.delete
        case .historyDeleteData: Strings.Charts.historyDeleteData
        case .impulseCounterOpenOcr: Strings.StandardDetail.tabOcr
        case .detailDimmerSettings,
             .detailElectricityMeterSettings,
             .detailImpulseCounterSettings: Strings.StandardDetail.tabSettings
        }
    }

    var icon: String? {
        switch self {
        case .profileSelect: "profile-navbar"
        case .notificationsDelete, .nfcTagDelete: String.Icons.delete
        case .historyDeleteData: nil
        case .impulseCounterOpenOcr: String.Icons.ocrPhoto
        case .detailDimmerSettings,
             .detailElectricityMeterSettings,
             .detailImpulseCounterSettings: String.Icons.settings
        }
    }

    var displayMode: DisplayMode {
        switch self {
        case .historyDeleteData: .overflowOnly
        default: .automatic
        }
    }

    var lifetime: Lifetime {
        switch self {
        case .detailDimmerSettings,
             .detailElectricityMeterSettings,
             .detailImpulseCounterSettings: .detail
        default: .tab
        }
    }

    var event: TopBarEvent {
        switch self {
        case .profileSelect: .openProfileSelector
        case .notificationsDelete: .deleteNotifications
        case .nfcTagDelete: .deleteNfcTag
        case .historyDeleteData: .deleteHistoryData
        case .impulseCounterOpenOcr: .openImpulseCounterOcr
        case .detailDimmerSettings: .openDimmerSettings
        case .detailElectricityMeterSettings: .openElectricityMeterSettings
        case .detailImpulseCounterSettings: .openImpulseCounterSettings
        }
    }

    enum DisplayMode: Equatable {
        case automatic
        case overflowOnly
    }

    enum Lifetime: Equatable {
        case tab
        case detail
    }
}

private struct TopBarEventHandler: ViewModifier {
    @Singleton<TopBarActionCoordinator> private var coordinator
    @State private var subscription: AnyCancellable?
    @State private var isVisible = false

    let event: TopBarEvent
    let enabled: Bool
    let handler: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                isVisible = true
                updateSubscription(isEnabled: enabled)
            }
            .onChange(of: enabled) { newValue in
                updateSubscription(isEnabled: newValue)
            }
            .onDisappear {
                isVisible = false
                cancelSubscription()
            }
    }

    private func updateSubscription(isEnabled: Bool) {
        guard isVisible && isEnabled else {
            cancelSubscription()
            return
        }

        guard subscription == nil else { return }
        subscription = coordinator.events
            .filter { $0 == event }
            .receive(on: DispatchQueue.main)
            .sink { _ in handler() }
    }

    private func cancelSubscription() {
        subscription?.cancel()
        subscription = nil
    }
}

extension View {
    func onTopBarEvent(
        _ event: TopBarEvent,
        enabled: Bool = true,
        perform handler: @escaping () -> Void
    ) -> some View {
        modifier(TopBarEventHandler(event: event, enabled: enabled, handler: handler))
    }
}

extension SuplaCore {
    struct TopBarContainer<TopBarContent: View, Content: View>: View {
        private let topBar: TopBarContent
        private let content: Content

        init(
            @ViewBuilder topBar: () -> TopBarContent,
            @ViewBuilder content: () -> Content
        ) {
            self.topBar = topBar()
            self.content = content()
        }

        var body: some View {
            ZStack(alignment: .top) {
                Color.Supla.background
                    .ignoresSafeArea()

                Color.Supla.primaryContainer
                    .frame(height: TopBar.height)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    topBar
                    content
                }
            }
        }
    }

    struct TopBar: View {
        @Singleton<TopBarActionCoordinator> private var actionCoordinator

        let navigationIcon: NavigationIcon
        let title: String
        let actions: [TopBarAction]
        let searchText: Binding<String>?
        let searchActive: Binding<Bool>?
        let searchPrompt: String
        let onNavigationIconTap: () -> Void
        let onSearchActiveChange: (Bool) -> Void

        @State private var internalSearchOpened = false
        @FocusState private var searchFocused: Bool

        static let height: CGFloat = 56
        private let height = TopBar.height
        private var searchIconVisible: Bool { searchText != nil && !searchOpened }
        private var actionLayout: ActionLayout {
            Self.layoutActions(actions, searchIconVisible: searchIconVisible)
        }
        private var rightControlsWidth: CGFloat {
            let searchControlCount = searchIconVisible ? 1 : 0
            let actionControlCount = actionLayout.controlCount
            let placeholderCount = searchText == nil && actionControlCount == 0 ? 1 : 0
            return height * CGFloat(searchControlCount + actionControlCount + placeholderCount)
        }

        private var titleHorizontalPadding: CGFloat { max(height, rightControlsWidth) }

        init(
            navigationIcon: NavigationIcon,
            title: String,
            actions: [TopBarAction] = [],
            searchText: Binding<String>? = nil,
            searchActive: Binding<Bool>? = nil,
            searchPrompt: String = Strings.Notifications.searchPrompt,
            onNavigationIconTap: @escaping () -> Void = {},
            onSearchActiveChange: @escaping (Bool) -> Void = { _ in }
        ) {
            self.navigationIcon = navigationIcon
            self.title = title
            self.actions = actions
            self.searchText = searchText
            self.searchActive = searchActive
            self.searchPrompt = searchPrompt
            self.onNavigationIconTap = onNavigationIconTap
            self.onSearchActiveChange = onSearchActiveChange
        }

        var body: some View {
            Group {
                if (searchOpened) {
                    searchContent
                } else {
                    defaultContent
                }
            }
            .frame(height: height)
            .background(Color.Supla.primaryContainer)
            .foregroundColor(Color.Supla.onPrimaryContainer)
        }

        private var defaultContent: some View {
            ZStack {
                HStack(spacing: 0) {
                    toolbarButton(icon: navigationIcon.name, action: onNavigationTap)

                    Spacer()

                    if (searchText != nil) {
                        toolbarButton(icon: String.Icons.search, action: openSearch)
                    }

                    actionControls

                    if (searchText == nil && actionLayout.controlCount == 0) {
                        Color.clear
                            .frame(width: height, height: height)
                    }
                }

                Text(title)
                    .fontHeadlineSmall()
                    .lineLimit(1)
                    .padding(.horizontal, titleHorizontalPadding)
            }
        }

        @ViewBuilder
        private var searchContent: some View {
            if let searchText {
                HStack(spacing: 0) {
                    toolbarButton(icon: NavigationIcon.back.name, action: closeSearch)

                    HStack(spacing: Distance.tiny) {
                        TextField(searchPrompt, text: searchText)
                            .fontBodyMedium()
                            .foregroundColor(Color.Supla.onBackground)
                            .accentColor(Color.Supla.onBackground)
                            .focused($searchFocused)

                        if (!searchText.wrappedValue.isEmpty) {
                            clearSearchButton(searchText)
                        }
                    }
                    .padding(.leading, Distance.small)
                    .padding(.trailing, searchText.wrappedValue.isEmpty ? Distance.small : 0)
                    .frame(maxWidth: .infinity)
                    .frame(height: Dimens.buttonHeight)
                    .background(Color.Supla.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Dimens.buttonRadius))
                    .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.outline))
                    .onAppear { searchFocused = true }

                    actionControls

                    if (actionLayout.controlCount == 0) {
                        Color.clear
                            .frame(width: height, height: height)
                    }
                }
            } else {
                defaultContent
            }
        }

        @ViewBuilder
        private var actionControls: some View {
            ForEach(actionLayout.icons.indices, id: \.self) { index in
                let item = actionLayout.icons[index]
                if let icon = item.icon {
                    Button(action: { actionCoordinator.emit(item.event) }) {
                        toolbarIcon(icon)
                    }
                    .accessibilityLabel(item.title)
                }
            }

            if (!actionLayout.overflow.isEmpty) {
                Menu {
                    ForEach(actionLayout.overflow.indices, id: \.self) { index in
                        let item = actionLayout.overflow[index]
                        Button(item.title) { actionCoordinator.emit(item.event) }
                    }
                } label: {
                    toolbarIcon(String.Icons.more)
                }
            }
        }

        static func layoutActions(_ actions: [TopBarAction], searchIconVisible: Bool) -> ActionLayout {
            let eligibleIcons = actions.filter { $0.displayMode == .automatic && $0.icon != nil }
            let hasOverflowOnlyAction = actions.contains { $0.displayMode == .overflowOnly }

            if (searchIconVisible && (actions.count > 1 || hasOverflowOnlyAction)) {
                return ActionLayout(icons: [], overflow: actions)
            }

            if (searchIconVisible) {
                return ActionLayout(icons: eligibleIcons, overflow: [])
            }

            let needsOverflow = hasOverflowOnlyAction || actions.count > 2
            guard (needsOverflow) else {
                return ActionLayout(icons: eligibleIcons, overflow: actions.filter { $0.icon == nil })
            }

            guard let firstIconIndex = actions.firstIndex(where: {
                $0.displayMode == .automatic && $0.icon != nil
            }) else {
                return ActionLayout(icons: [], overflow: actions)
            }

            return ActionLayout(
                icons: [actions[firstIconIndex]],
                overflow: actions.enumerated().compactMap { index, action in
                    index == firstIconIndex ? nil : action
                }
            )
        }

        private func toolbarButton(icon: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                toolbarIcon(icon)
            }
        }

        private func toolbarIcon(_ icon: String) -> some View {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                .frame(width: height, height: height)
                .contentShape(Rectangle())
                .foregroundColor(.Supla.onPrimaryContainer)
        }

        private func clearSearchButton(_ searchText: Binding<String>) -> some View {
            Button(action: { searchText.wrappedValue = "" }) {
                Image(String.Icons.close)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.Supla.onBackground)
                    .frame(width: 12, height: 12)
            }
            .frame(width: Dimens.buttonHeight, height: Dimens.buttonHeight)
        }

        private func onNavigationTap() {
            if (searchOpened) {
                closeSearch()
            } else {
                onNavigationIconTap()
            }
        }

        private func openSearch() {
            searchOpened = true
            searchFocused = true
            onSearchActiveChange(true)
        }

        private func closeSearch() {
            searchOpened = false
            searchFocused = false
            onSearchActiveChange(false)
        }

        private var searchOpened: Bool {
            get {
                searchActive?.wrappedValue ?? internalSearchOpened
            }
            nonmutating set {
                if let searchActive {
                    searchActive.wrappedValue = newValue
                } else {
                    internalSearchOpened = newValue
                }
            }
        }

        enum NavigationIcon {
            case back
            case menu
            case custom(String)

            var name: String {
                switch self {
                case .back: String.Icons.arrowLeft
                case .menu: String.Icons.menu
                case let .custom(name): name
                }
            }
        }

        struct ActionLayout {
            let icons: [TopBarAction]
            let overflow: [TopBarAction]

            var controlCount: Int { icons.count + (overflow.isEmpty ? 0 : 1) }
        }
    }
}
