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

import Foundation
import UIKit
import RxSwift

class AppRootVM: SuplaCore.ViewModel<AppRootViewState> {
    @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
    @Singleton<DownloadUserIconsManager> private var downloadUserIconsManager
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<GetCaptionUseCase> private var getCaptionUseCase

    private var eventNotificationDismissTask: Task<Void, Never>?

    init(state: AppRootViewState = AppRootViewState()) {
        super.init(state: state, eventSelector: #selector(onEvent), eventName: NSNotification.Name.saEvent)
        observeChangesForIconsReload()
    }

    @objc private func onEvent(notification: Notification) {
        if (notification.userInfo == nil) {
            return
        }

        let event: SAEvent? = SAEvent.notification(toEvent: notification)
        if (event == nil || event?.owner == true) {
            return
        }

        Task { [weak self] in
            guard let self else { return }

            guard let event,
                  let actionText = getMessageForEvent(event),
                  let profile = try? await profileRepository.getActiveProfile().awaitFirstElement(),
                  let channel = try? await channelRepository.getChannel(for: profile, with: event.channelID).awaitFirstElement()
            else {
                return
            }

            await showEventNotification(EventNotificationState(
                time: Date(),
                device: event.senderName,
                actionText: actionText,
                subjectIcon: getChannelBaseIconUseCase.invoke(channel: channel),
                subjectName: getCaptionUseCase.invoke(data: channel.shareable).string
            ))
        }
    }

    @MainActor
    func dismissEventNotification() {
        eventNotificationDismissTask?.cancel()
        eventNotificationDismissTask = nil
        state.eventNotificationState = nil
    }

    @MainActor
    private func showEventNotification(_ eventNotificationState: EventNotificationState) {
        eventNotificationDismissTask?.cancel()
        state.eventNotificationState = eventNotificationState
        eventNotificationDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(AppRootVM.NOTIFICATION_TIMEOUT_S) * 1_000_000_000)

            if (!Task.isCancelled) {
                self?.dismissEventNotification()
            }
        }
    }

    private func getMessageForEvent(_ event: SAEvent) -> String? {
        switch (event.event) {
        case SUPLA_EVENT_CONTROLLINGTHEGATEWAYLOCK:
            return NSLocalizedString("opened the gateway", comment: "")
        case SUPLA_EVENT_CONTROLLINGTHEGATE:
            return NSLocalizedString("opened / closed the gate", comment: "")
        case SUPLA_EVENT_CONTROLLINGTHEGARAGEDOOR:
            return NSLocalizedString("opened / closed the gate doors", comment: "")
        case SUPLA_EVENT_CONTROLLINGTHEDOORLOCK:
            return NSLocalizedString("opened the door", comment: "")
        case SUPLA_EVENT_CONTROLLINGTHEROLLERSHUTTER:
            return NSLocalizedString("opened / closed roller shutter", comment: "")
        case SUPLA_EVENT_CONTROLLINGTHEROOFWINDOW:
            return NSLocalizedString("opened / closed the roof window", comment: "")
        case SUPLA_EVENT_POWERONOFF:
            return NSLocalizedString("turned the power ON/OFF", comment: "")
        case SUPLA_EVENT_LIGHTONOFF:
            return NSLocalizedString("turned the light ON/OFF", comment: "")
        default:
            return nil
        }
    }

    private func observeChangesForIconsReload() {
        Observable.combineLatest(
            updateEventsManager.observeChannelsUpdate(),
            updateEventsManager.observeGroupsUpdate(),
            updateEventsManager.observeScenesUpdate(),
            resultSelector: { _, _, _ in
                return ()
            }
        ).asDriverWithoutError()
            .debounce(.seconds(2))
            .drive(onNext: { [weak self] in self?.downloadUserIconsManager.download() })
            .disposed(by: disposeBag)
    }

    static let NOTIFICATION_TIMEOUT_S = 5
}
