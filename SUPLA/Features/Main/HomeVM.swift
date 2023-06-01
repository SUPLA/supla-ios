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
import RxSwift

class HomeViewModel: BaseViewModel<HomeViewState, HomeViewEvent> {
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    
    override func defaultViewState() -> HomeViewState { HomeViewState() }
    
    func onViewAppear() {
        profileRepository.getAllProfiles()
            .map { profiles in profiles.count }
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] count in
                    self?.updateView { state in
                        state.changing(path: \.showProfilesIcon, to: count > 1)
                    }
                }
            )
            .disposed(by: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationEvent), name: NSNotification.Name.saEvent, object: nil)
    }
    
    func onViewDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func onNotificationEvent(notification: Notification) {
        if (notification.userInfo == nil) {
            return
        }
        
        let event: SAEvent? = SAEvent.notification(toEvent: notification)
        if (event == nil) {
            return
        }
        
        channelRepository.getChannel(remoteId: Int(event!.channelID))
            .flatMapFirst { self.channelToEvent(channel: $0, event: event!) }
            .asDriverWithoutError()
            .drive(onNext: { self.send(event: $0)})
            .disposed(by: self)
    }
    
    private func channelToEvent(channel: SAChannel, event: SAEvent) -> Observable<HomeViewEvent> {
        let icon: UIImage? = channel.getIcon()
        var message = getMessageForEvent(event)
            
        if (icon != nil && message != nil) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            if (channel.caption != nil && channel.caption!.isEmpty == false) {
                message = String(format: "%@ %@ %@ %@", formatter.string(from: Date()), event.senderName, message!, channel.caption!)
            } else {
                message = String(format: "%@ %@ %@", formatter.string(from: Date()), event.senderName, message!)
            }
            return Observable.just(.showNotification(message: message!, icon: icon!))
        }
        
        return Observable.empty()
    }
    
    private func getMessageForEvent(_ event: SAEvent) -> String? {
        switch(event.event) {
        case SUPLA_EVENT_CONTROLLINGTHEGATEWAYLOCK:
            return NSLocalizedString("opened the gateway", comment: "");
        case SUPLA_EVENT_CONTROLLINGTHEGATE:
            return NSLocalizedString("opened / closed the gate", comment: "");
        case SUPLA_EVENT_CONTROLLINGTHEGARAGEDOOR:
            return NSLocalizedString("opened / closed the gate doors", comment: "");
        case SUPLA_EVENT_CONTROLLINGTHEDOORLOCK:
            return NSLocalizedString("opened the door", comment: "");
        case SUPLA_EVENT_CONTROLLINGTHEROLLERSHUTTER:
            return NSLocalizedString("opened / closed roller shutter", comment: "");
        case SUPLA_EVENT_CONTROLLINGTHEROOFWINDOW:
            return NSLocalizedString("opened / closed the roof window", comment: "");
        case SUPLA_EVENT_POWERONOFF:
            return NSLocalizedString("turned the power ON/OFF", comment: "");
        case SUPLA_EVENT_LIGHTONOFF:
            return NSLocalizedString("turned the light ON/OFF", comment: "");
        default:
            return nil
        }
    }
}

enum HomeViewEvent: ViewEvent {
    case showNotification(message: String, icon: UIImage)
}

struct HomeViewState: ViewState {
    var showProfilesIcon: Bool = false
}
