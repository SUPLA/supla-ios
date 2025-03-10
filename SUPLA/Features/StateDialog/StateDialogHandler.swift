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

import RxSwift

private let REFRESH_INTERVAL_S = 4.0

extension StateDialogFeature {
    protocol Handler: AnyObject {
        var stateDialogState: StateDialogFeature.ViewState? { get }

        func updateStateDialogState(_ updater: (ViewState?) -> ViewState?)
    }
}

extension StateDialogFeature.Handler {
    func showStateDialog(remoteId: Int32, caption: String) {
        updateStateDialogState { _ in
            StateDialogFeature.ViewState(remoteId: remoteId, title: caption, loading: true, values: [:], timer: nil, lastRefreshTimestamp: nil)
        }
        startDialogStateRefreshing()
    }

    func closeStateDialog() {
        stopDialogStateRefreshing()
        updateStateDialogState { _ in nil }
    }

    func updateStateDialog(_ state: SAChannelStateExtendedValue) {
        updateStateDialogState { currentState in
            if (currentState?.remoteId != state.channelId().int32Value) {
                return currentState
            }
            
            let values = StateDialogFeature.StateDialogItem.allCases
                .reduce(into: [StateDialogFeature.StateDialogItem: String?]()) {
                    $0[$1] = $1.extract(from: state)
                }
                .filter { $0.value != nil && $0.value?.isEmpty == false }
                .mapValues { $0! }

            return currentState?.changing(path: \.values, to: values)
                .changing(path: \.loading, to: false)
        }
    }

    private func startDialogStateRefreshing() {
        SALog.debug("Starting channel state timer")
        @Singleton<DateProvider> var dateProvider
        @Singleton<SuplaClientProvider> var suplaClientProvider

        if let remoteId = stateDialogState?.remoteId {
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                let lastRefreshTime = self?.stateDialogState?.lastRefreshTimestamp
                let currentTimestamp = dateProvider.currentTimestamp()

                if let lastRefreshTime,
                   lastRefreshTime + REFRESH_INTERVAL_S < currentTimestamp
                {
                    SALog.debug("Asking for channel state of \(remoteId)")
                    self?.updateStateDialogState { $0?.changing(path: \.lastRefreshTimestamp, to: currentTimestamp) }
                    suplaClientProvider.provide()?.channelStateRequest(withChannelId: remoteId)
                }
            }

            updateStateDialogState {
                $0?.changing(path: \.timer, to: timer)
                    .changing(path: \.lastRefreshTimestamp, to: dateProvider.currentTimestamp())
            }
            suplaClientProvider.provide()?.channelStateRequest(withChannelId: remoteId)
        }
    }

    private func stopDialogStateRefreshing() {
        SALog.debug("Stopping channel state timer")
        updateStateDialogState {
            $0?.timer?.invalidate()
            return $0?.changing(path: \.timer, to: nil)
        }
    }
}
