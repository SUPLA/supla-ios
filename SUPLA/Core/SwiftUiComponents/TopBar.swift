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

extension SuplaCore {
    struct TopBar: View {
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

        let navigationIcon: NavigationIcon
        let title: String
        let actionIcon: String?
        let searchText: Binding<String>?
        let searchPrompt: String
        let onNavigationIconTap: () -> Void
        let onActionIconTap: () -> Void
        let onSearchActiveChange: (Bool) -> Void

        @State private var searchOpened = false
        @FocusState private var searchFocused: Bool

        static let height: CGFloat = 56
        private let height = TopBar.height
        private var rightControlsWidth: CGFloat {
            height * CGFloat((searchText == nil ? 0 : 1) + (actionIcon == nil ? 0 : 1))
        }

        private var titleHorizontalPadding: CGFloat { max(height, rightControlsWidth) }

        init(
            navigationIcon: NavigationIcon,
            title: String,
            actionIcon: String? = nil,
            searchText: Binding<String>? = nil,
            searchPrompt: String = Strings.Notifications.searchPrompt,
            onNavigationIconTap: @escaping () -> Void = {},
            onActionIconTap: @escaping () -> Void = {},
            onSearchActiveChange: @escaping (Bool) -> Void = { _ in }
        ) {
            self.navigationIcon = navigationIcon
            self.title = title
            self.actionIcon = actionIcon
            self.searchText = searchText
            self.searchPrompt = searchPrompt
            self.onNavigationIconTap = onNavigationIconTap
            self.onActionIconTap = onActionIconTap
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

                    if let actionIcon {
                        toolbarButton(icon: actionIcon, action: onActionIconTap)
                    } else {
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

                    if let actionIcon {
                        toolbarButton(icon: actionIcon, action: onActionIconTap)
                    } else {
                        Color.clear
                            .frame(width: height, height: height)
                    }
                }
            } else {
                defaultContent
            }
        }

        private func toolbarButton(icon: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                    .frame(width: height, height: height)
                    .contentShape(Rectangle())
                    .foregroundColor(.Supla.onPrimaryContainer)
            }
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
    }
}
