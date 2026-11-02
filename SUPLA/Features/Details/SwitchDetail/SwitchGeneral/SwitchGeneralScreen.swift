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

extension SwitchGeneralFeature {
    struct Screen: SwiftUI.View {
        let itemBundle: ItemBundle

        @StateObject private var viewModel: ViewModel
        @StateObject private var captionChangeDialogViewModel = CaptionChangeDialogFeature.ViewModel()
        @StateObject private var stateDialogViewModel = StateDialogFeature.ViewModel()

        init(itemBundle: ItemBundle) {
            self.itemBundle = itemBundle
            _viewModel = StateObject(wrappedValue: ViewModel(itemBundle: itemBundle))
        }

        var body: some SwiftUI.View {
            SuplaCore.ViewModelHost(viewModel) { state in
                View(
                    viewState: state,
                    emState: viewModel.electricityState,
                    icState: viewModel.impulseCounterState,
                    stateDialogViewModel: stateDialogViewModel,
                    captionChangeDialogViewModel: captionChangeDialogViewModel,
                    delegate: viewModel,
                    onInfoClick: { stateDialogViewModel.show(remoteId: $0.id) },
                    onCaptionLongPress: { captionChangeDialogViewModel.show(sensorData: $0) }
                )
            }
        }
    }
}
