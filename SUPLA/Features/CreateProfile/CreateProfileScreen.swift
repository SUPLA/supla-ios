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

extension CreateProfileFeature {
    struct Screen: SwiftUI.View {
        private let profileId: Int32
        private let onBack: () -> Void

        @StateObject private var viewModel: ViewModel

        init(
            profileId: Int32,
            onBack: @escaping () -> Void = {}
        ) {
            self.profileId = profileId
            self.onBack = onBack
            self._viewModel = StateObject(wrappedValue: ViewModel(profileId: profileId))
        }

        var body: some SwiftUI.View {
            SuplaCore.ViewModelHost(viewModel) { state in
                VStack(spacing: 0) {
                    SuplaCore.TopBar(
                        navigationIcon: .back,
                        title: title(state),
                        onNavigationIconTap: { handleBack(state) }
                    )

                    View(
                        viewState: state,
                        onAdvancedAuthorizationChange: viewModel.onToggleAdvancedState(_:),
                        onServerAutoDetectChange: viewModel.onServerAutoDetectChange(_:),
                        onLogout: viewModel.logoutAccount,
                        onDelete: viewModel.removeAccount,
                        onSave: viewModel.save,
                        onCreateAccount: viewModel.createNewAccount
                    )
                }
            }
        }

        private func title(_ state: ViewState) -> String {
            if (!state.profileNameVisible) {
                return Strings.appName
            } else if (profileId != ProfileDto.INVALID_ID) {
                return Strings.CreateProfile.modificationTitle
            } else {
                return Strings.CreateProfile.creationTitle
            }
        }

        private func handleBack(_ state: ViewState) {
            if (state.profileNameVisible) {
                onBack()
            } else {
                closeApplication()
            }
        }

        private func closeApplication() {
            _ = UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
}
