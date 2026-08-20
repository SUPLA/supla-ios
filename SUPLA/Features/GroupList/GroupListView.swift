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

extension GroupListFeature {
    protocol ViewDelegate {
        func onItemClick(_ item: MainListItem)
        func onLeftButtonClick(_ item: MainListItem)
        func onRightButtonClick(_ item: MainListItem)
        func onMove(_ sourceItem: MainListItem, _ destinationItem: MainListItem)
        func onLocationClick(_ item: LocationListItem)
        func onNoContentButtonClick()
    }

    struct View: SwiftUI.View {
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
        @ObservedObject var viewState: GroupListFeature.ViewState
        let delegate: ViewDelegate?

        let onScroll: (CGFloat) -> Void
        let onScrollEnded: (Bool) -> Void

        var body: some SwiftUI.View {
            ZStack {
                content
                    .background(Color.Supla.background)

                if (captionChangeDialogViewModel.present) {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
            }
        }

        @ViewBuilder
        private var content: some SwiftUI.View {
            if (viewState.loading) {
                MainListLoadingContent()
            } else if (viewState.items.isEmpty) {
                NoContentView(onButtonClick: { delegate?.onNoContentButtonClick() })
            } else {
                MainListTable(
                    items: viewState.items,
                    callbacks: tableCallbacks,
                    onScroll: onScroll,
                    onScrollEnded: onScrollEnded
                )
            }
        }

        private var tableCallbacks: MainListTableView.Callbacks {
            MainListTableView.Callbacks(
                onItemClick: { item in delegate?.onItemClick(item) },
                onTitleLongClick: { item in captionChangeDialogViewModel.show(groupRemoteId: item.remoteId) },
                onLocationClick: { item in delegate?.onLocationClick(item) },
                onLocationLongClick: { item in captionChangeDialogViewModel.show(locationRemoteId: item.remoteId) },
                onLeftButtonClick: { item in delegate?.onLeftButtonClick(item) },
                onRightButtonClick: { item in delegate?.onRightButtonClick(item) },
                onMove: { sourceItem, destinationItem in delegate?.onMove(sourceItem, destinationItem) }
            )
        }
    }
}

private struct NoContentView: SwiftUI.View {
    let onButtonClick: () -> Void

    var body: some SwiftUI.View {
        VStack(spacing: Distance.small) {
            EmptyListView()

            TitleButton(title: Strings.Groups.emptyListButton, action: onButtonClick)
                .borderedButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
