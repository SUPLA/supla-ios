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

struct AppRootView: View {
    @StateObject private var viewModel = AppRootVM()

    var body: some View {
        SuplaCore.ViewModelHost(viewModel) { state in
            Content(
                state: state,
                onEventNotificationRemoved: { viewModel.dismissEventNotification() }
            )
        }
    }
}

private extension AppRootView {
    struct Content: View {
        @EnvironmentObject private var authorizationCoordinator: AuthorizationCoordinator
        @EnvironmentObject private var router: AppRouter

        @ObservedObject var state: AppRootViewState

        let onEventNotificationRemoved: () -> Void

        var body: some View {
            NavigationView {
                ZStack {
                    rootView
                    navigationLink
                }
            }
            .navigationViewStyle(.stack)
            .overlay(alignment: .bottom) { eventNotificationOverlay }
            .overlay(authorizationDialog)
        }

        @ViewBuilder
        private var rootView: some View {
            switch router.root {
            case .status:
                StatusFeature.Screen()

            case .main:
                MainFeature.Screen()

            case .unlockApp(let action):
                LockScreenFeature.Screen(unlockAction: action)
            }
        }

        @ViewBuilder
        private func destination(for route: AppRoute) -> some View {
            switch route {
            case .settings: SettingsScreen()
            case .locationOrdering: LocationOrderingScreen()
            case .profiles: ProfilesListFeature.Screen()
            case .addWizard: AddWizardFeature.ScreenFlow()
            case .profile(let profileId, _): CreateProfileFeature.Screen(profileId: profileId)
            case .createAccountWeb: CreateAccountScreen()
            case .removeAccountWeb(let needsRestart, let serverAddress):
                AccountRemovalScreen(needsRestart: needsRestart, serverAddress: serverAddress)
            case .pinSetup(let scope): PinSetupFeature.Screen(scope: scope)
            case .lockScreen(let action): LockScreenFeature.Screen(unlockAction: action)
            case .carPlayList: CarPlayListFeature.Screen()
            case .carPlayAdd: CarPlayAddFeature.Screen()
            case .carPlayEdit(let id): CarPlayAddFeature.Screen(id: id)
            case .callNfcAction(let url): CallNfcActionFeature.Screen(url: url)
            case .nfcTagsList: NfcTagsListFeature.Screen()
            case .editNfcTag(let uuid, let readOnly): EditTagFeature.Screen(uuid: uuid, readOnly: readOnly)
            case .nfcTagDetail(let uuid): NfcTagDetailFeature.Screen(uuid: uuid)

            default: EmptyView()
            }
        }

        private var navigationLink: some View {
            NavigationLink(
                destination: currentDestination,
                isActive: isNavigationActive,
                label: EmptyView.init
            )
            .hidden()
        }

        @ViewBuilder
        private var currentDestination: some View {
            if let route = router.currentRoute {
                destination(for: route)
                    .navigationBarHidden(true)
            }
        }

        private var isNavigationActive: Binding<Bool> {
            Binding(
                get: { router.currentRoute != nil },
                set: { isActive in
                    if (!isActive) {
                        router.back()
                    }
                }
            )
        }

        @ViewBuilder
        private var eventNotificationOverlay: some View {
            if let eventNotificationState = state.eventNotificationState {
                EventNotificationOverlay(
                    state: eventNotificationState,
                    onEventRemoved: onEventNotificationRemoved
                )
            }
        }

        @ViewBuilder
        private var authorizationDialog: some View {
            if let request = authorizationCoordinator.request {
                CredentialsFeature.Dialog(
                    requestType: request.requestType,
                    onAuthorized: { authorizationCoordinator.complete() },
                    onDismissed: { authorizationCoordinator.dismiss() }
                )
            }
        }
    }
}
