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

import Alamofire
import Foundation

extension ScheduleListFeature {
    final class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<CloudApiClient> private var cloudApiClient
        @Singleton<CloudApiTokenStore> private var tokenStore
        @Singleton<AppRouter> private var router

        private struct AuthorizationProfile {
            let email: String
            let serverAddress: String?
        }

        private var activeProfile: AuthorizationProfile?

        init(state: ViewState = ViewState()) {
            super.init(state: state)
        }

        override func onViewAppear() {
            Task { await load() }
        }

        func onRefresh() async {
            // Keep the request alive if SwiftUI cancels the task running the refreshable action.
            let refreshTask = Task { @MainActor in
                if activeProfile == nil {
                    await load()
                } else {
                    await loadSchedules()
                }
            }
            
            await refreshTask.value
        }

        func onTryAgain() {
            Task { await onRefresh() }
        }

        func onAuthorizationDismiss() {
            state.credentialsViewState = nil
            state.items = nil
            state.editingScheduleId = nil
            state.captionChangeDialogViewState = nil
        }

        func onEditedCaptionChanged(_ value: String) {
            state.captionChangeDialogViewState?.caption = value
            state.captionChangeDialogViewState?.error = nil
        }

        func onCaptionChanged(_ caption: String) {
            onEditedCaptionChanged(caption)
        }

        func onCaptionDialogDismiss() {
            onCaptionChangeDismiss()
        }

        func onApply() {
            onCaptionChangeConfirmed()
        }

        func onAuthenticate() {
            guard let credentialsViewState = state.credentialsViewState,
                  !credentialsViewState.password.isEmpty,
                  let profile = activeProfile
            else { return }
            let password = credentialsViewState.password
            credentialsViewState.loading = true
            credentialsViewState.error = nil

            Task { @MainActor in
                do {
                    try await cloudApiClient.authenticate(email: profile.email, password: password, serverAddress: profile.serverAddress)
                    state.credentialsViewState = nil
                    await loadSchedules()
                } catch CloudApiError.invalidCredentials {
                    credentialsViewState.loading = false
                    credentialsViewState.error = Strings.Status.errorInvalidData
                } catch {
                    credentialsViewState.loading = false
                    credentialsViewState.error = Strings.Status.errorUnknown
                }
            }
        }

        func onDismiss() {
            onAuthorizationDismiss()
        }

        func onAuthorize() {
            onAuthenticate()
        }

        func onEnabledChanged(_ item: ScheduleListItem, enabled: Bool) {
            guard !state.loading else { return }
            state.updatingScheduleId = item.id
            state.loading = true
            state.loadingError = false

            Task { @MainActor in
                do {
                    var schedule = try await cloudApiClient.getSchedule(id: item.id)
                    if schedule.enabled != enabled {
                        schedule.enabled = enabled
                        try await cloudApiClient.updateSchedule(id: item.id, schedule: schedule)
                    }
                    await loadSchedules()
                } catch {
                    handle(error)
                }
                state.updatingScheduleId = nil
            }
        }

        func onTitleLongPress(_ item: ScheduleListItem) {
            state.editingScheduleId = item.id
            state.captionChangeDialogViewState = CaptionChangeDialogFeature.ViewState(
                caption: item.userCaption,
                label: Strings.ScheduleList.name
            )
        }

        func onCaptionChangeDismiss() {
            state.editingScheduleId = nil
            state.captionChangeDialogViewState = nil
        }

        func onCaptionChangeConfirmed() {
            guard let scheduleId = state.editingScheduleId,
                  let captionChangeDialogViewState = state.captionChangeDialogViewState
            else { return }
            let caption = captionChangeDialogViewState.caption
            captionChangeDialogViewState.processing = true
            captionChangeDialogViewState.error = nil

            Task { @MainActor in
                do {
                    var schedule = try await cloudApiClient.getSchedule(id: scheduleId)
                    schedule.caption = caption
                    try await cloudApiClient.updateSchedule(id: scheduleId, schedule: schedule)

                    onCaptionChangeDismiss()
                    await loadSchedules()
                } catch CloudApiError.unauthorized {
                    captionChangeDialogViewState.processing = false
                    handle(CloudApiError.unauthorized)
                } catch {
                    captionChangeDialogViewState.processing = false
                    captionChangeDialogViewState.error = Strings.Status.errorUnknown
                }
            }
        }

        @MainActor
        private func load() async {
            if activeProfile == nil {
                do {
                    guard let profile = try await profileRepository.getActiveProfile().map(\.dto).awaitFirstElement(),
                          profile.authorizationType == .email,
                          let email = profile.email
                    else {
                        router.back()
                        return
                    }
                    activeProfile = AuthorizationProfile(email: email, serverAddress: profile.serverAddress)
                } catch {
                    router.back()
                    return
                }
            }

            guard tokenStore.token != nil else {
                presentAuthorization()
                return
            }
            
            await loadSchedules()
        }

        @MainActor
        private func loadSchedules() async {
            guard activeProfile != nil else { return }
            guard tokenStore.token != nil else {
                presentAuthorization()
                return
            }

            state.loading = true
            state.loadingError = false
            do {
                let schedules = try await cloudApiClient.getSchedules()
                state.items = schedules.map(makeItem)
                state.loading = false
                state.loadingError = false
            } catch {
                handle(error)
            }
        }

        @MainActor
        private func handle(_ error: Error) {
            SALog.error(String(describing: error))
            
            if Task.isCancelled || error is CancellationError || error.asAFError?.isExplicitlyCancelledError == true {
                state.loading = false
                state.updatingScheduleId = nil
                return
            }

            state.loading = false
            state.updatingScheduleId = nil
            if case CloudApiError.unauthorized = error {
                tokenStore.clean()
                state.items = nil
                state.loadingError = false
                presentAuthorization()
            } else {
                state.loadingError = true
            }
        }

        @MainActor
        private func presentAuthorization() {
            state.loading = false
            guard let profile = activeProfile else { return }
            state.credentialsViewState = CredentialsFeature.ViewState(
                visible: true,
                userName: profile.email,
                isCloudAccount: profile.serverAddress?.contains(".supla.org") == true,
                userNameEnabled: false
            )
        }

        private func makeItem(_ schedule: CloudApi.ScheduleDto) -> ScheduleListItem {
            let remoteId = schedule.id ?? 0
            let caption = schedule.caption?.trimmingCharacters(in: .whitespacesAndNewlines)
                .nilIfEmpty ?? Strings.ScheduleList.defaultCaption.arguments(remoteId)
            return ScheduleListItem(
                id: remoteId,
                caption: caption,
                userCaption: schedule.caption ?? "",
                enabled: schedule.enabled == true,
                lastExecution: schedule.closestExecutions?.past?.last.map(makeExecution),
                nextExecution: schedule.closestExecutions?.future?.first.map(makeExecution)
            )
        }

        private func makeExecution(_ execution: CloudApi.ScheduleExecutionDto) -> ScheduleListExecutionItem {
            ScheduleListExecutionItem(date: parseTimestamp(execution.plannedTimestamp), failed: execution.failed)
        }

        private func parseTimestamp(_ value: String?) -> Date? {
            guard let value else { return nil }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
