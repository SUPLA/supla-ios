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

extension ChannelListFeature {
    protocol ViewDelegate {
        func onItemClick(_ item: MainListItem)
        func onIssueClick(_ issues: ListItemIssues)
        func onLeftButtonClick(_ item: MainListItem)
        func onRightButtonClick(_ item: MainListItem)
        func onMove(_ sourceItem: MainListItem, _ destinationItem: MainListItem)
        func onLocationClick(_ item: LocationListItem)
        func onAddDeviceClick()
        func onDeviceCatalogClick()
        func onAlertConfirmed(_ remoteId: Int32?, _ action: ActionId?)
        func onAlertDismissed()
    }

    struct View: SwiftUI.View {
        @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
        @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
        @ObservedObject var viewState: ChannelListFeature.ViewState
        let delegate: ViewDelegate?

        let onScroll: (CGFloat) -> Void
        let onScrollEnded: (Bool) -> Void

        var body: some SwiftUI.View {
            ZStack {
                content
                    .background(Color.Supla.background)

                if (stateDialogViewModel.present) {
                    StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
                }
                if (captionChangeDialogViewModel.present) {
                    CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
                }
                if let alertDialogState = viewState.alertDialogState {
                    SuplaCore.AlertDialog(
                        header: Strings.General.warning,
                        message: alertDialogState.message,
                        onDismiss: { delegate?.onAlertDismissed() },
                        primaryButtonData: .optional(alertDialogState.positiveButtonText),
                        secondaryButtonText: alertDialogState.negativeButtonText,
                        onPrimaryButtonClick: { delegate?.onAlertConfirmed(alertDialogState.remoteId, alertDialogState.action) },
                        onSecondaryButtonClick: { delegate?.onAlertDismissed() }
                    )
                }
            }
        }

        @ViewBuilder
        private var content: some SwiftUI.View {
            if (viewState.loading) {
                MainListLoadingContent()
            } else if (viewState.items.isEmpty) {
                NoContentView(
                    showDeviceCatalog: BrandingConfiguration.Menu.DEVICES_OPTION_VISIBLE,
                    onAddDeviceClick: { delegate?.onAddDeviceClick() },
                    onDeviceCatalogClick: { delegate?.onDeviceCatalogClick() }
                )
            } else {
                MainListTable(
                    items: viewState.items,
                    callbacks: tableCallbacks,
                    inSearch: viewState.filterActive,
                    onScroll: onScroll,
                    onScrollEnded: onScrollEnded
                )
            }
        }

        private var tableCallbacks: MainListTableView.Callbacks {
            MainListTableView.Callbacks(
                onItemClick: { item in delegate?.onItemClick(item) },
                onInfoClick: { item in stateDialogViewModel.show(remoteId: item.remoteId) },
                onIssueClick: { _, issues in delegate?.onIssueClick(issues) },
                onTitleLongClick: { item in captionChangeDialogViewModel.show(channelRemoteId: item.remoteId) },
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
    let showDeviceCatalog: Bool
    let onAddDeviceClick: () -> Void
    let onDeviceCatalogClick: () -> Void

    var body: some SwiftUI.View {
        VStack(spacing: Distance.small) {
            EmptyListView()

            if (showDeviceCatalog) {
                TitleButton(title: Strings.DeviceCatalog.menu, action: onDeviceCatalogClick)
                    .borderedButtonStyle()
            }

            TitleButton(title: Strings.Menu.addDevice, action: onAddDeviceClick)
                .borderedButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
