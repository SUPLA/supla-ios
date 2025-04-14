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

struct ChannelListView: View {
    
    @ObservedObject var stateDialogViewModel: StateDialogFeature.ViewModel
    @ObservedObject var captionChangeDialogViewModel: CaptionChangeDialogFeature.ViewModel
    @ObservedObject var channelListViewState: ChannelListViewState
    
    let onAlertConfirmed: (Int32?, Action?) -> Void
    let onAlertDismissed: () -> Void
    
    var body: some View {
        if (stateDialogViewModel.present) {
            StateDialogFeature.Dialog(viewModel: stateDialogViewModel)
        }
        if (captionChangeDialogViewModel.present) {
            CaptionChangeDialogFeature.Dialog(viewModel: captionChangeDialogViewModel)
        }
        if let alertDialogState = channelListViewState.alertDialogState {
            SuplaCore.AlertDialog(
                header: Strings.General.warning,
                message: alertDialogState.message,
                onDismiss: {},
                positiveButtonText: alertDialogState.positiveButtonText,
                negativeButtonText: alertDialogState.negativeButtonText,
                onPositiveButtonClick: { onAlertConfirmed(alertDialogState.remoteId, alertDialogState.action) },
                onNegativeButtonClick: onAlertDismissed
            )
        }
    }
}
