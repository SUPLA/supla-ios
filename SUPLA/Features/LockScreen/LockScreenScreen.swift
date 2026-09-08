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

extension LockScreenFeature {
    enum Presentation {
        case root
        case pushed
    }

    struct Screen: SwiftUI.View {
        @EnvironmentObject private var router: AppRouter

        @StateObject private var viewModel: ViewModel
        @State private var showForgottenCodeDialog = false

        private let presentation: Presentation

        init(unlockAction: UnlockAction, presentation: Presentation = .root) {
            self.presentation = presentation
            self._viewModel = StateObject(wrappedValue: ViewModel(unlockAction: unlockAction))
        }

        var body: some SwiftUI.View {
            SuplaCore.ViewModelHost(viewModel) { state in
                content(state)
            }
            .overlay(forgottenCodeDialog)
        }

        @ViewBuilder
        private func content(_ state: ViewState) -> some SwiftUI.View {
            switch presentation {
            case .root:
                lockScreenContent(state)

            case .pushed:
                VStack(spacing: 0) {
                    SuplaCore.TopBar(
                        navigationIcon: .back,
                        title: Strings.LockScreen.enterPin,
                        onNavigationIconTap: router.back
                    )

                    lockScreenContent(state)
                }
            }
        }

        private func lockScreenContent(_ state: ViewState) -> some SwiftUI.View {
            View(
                viewState: state,
                onPinChange: viewModel.onPinChange,
                onBiometricShow: viewModel.onViewAppear,
                onPinForgotten: { showForgottenCodeDialog = true }
            )
        }

        @ViewBuilder
        private var forgottenCodeDialog: some SwiftUI.View {
            if showForgottenCodeDialog {
                SuplaCore.AlertDialog(
                    header: Strings.LockScreen.forgottenCodeTitle,
                    message: Strings.LockScreen.forgottenCodeMessage,
                    onDismiss: { showForgottenCodeDialog = false },
                    primaryButtonData: .default(Strings.LockScreen.forgottenCodeButton),
                    onPrimaryButtonClick: { showForgottenCodeDialog = false }
                )
            }
        }
    }
}
