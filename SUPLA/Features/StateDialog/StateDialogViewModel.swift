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
import SwiftUI

private let REFRESH_INTERVAL_S = 4.0

extension StateDialogFeature {
    class ViewModel: SuplaCore.Dialog.ViewModel {
        @Singleton<DateProvider> var dateProvider
        @Singleton<SuplaClientProvider> var suplaClientProvider
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        
        @Published private(set) var title: String = ""
        @Published private(set) var subtitle: String? = nil
        @Published private(set) var function: String = ""
        @Published private(set) var values: [StateDialogItem: String] = [:]
        @Published private(set) var showLifespanSettingsButton: Bool = false
        @Published private(set) var showArrows: Bool = false
        
        private var channels: [ChannelData] = []
        private var currentIdx: Int = 0
        
        private var timer: Timer? = nil
        private var lastRefreshTime: TimeInterval? = nil
        
        private let lifespanSettingsCallback: (Int32, String, Int32) -> Void
        private var lightSourceLifespan: Int32 = 0
        
        init(lifespanSettingsCallback: @escaping (_ remoteId: Int32, _ caption: String, _ lifesourceLifespan: Int32) -> Void) {
            self.lifespanSettingsCallback = lifespanSettingsCallback
            super.init()
            
            observeNotification(name: NSNotification.Name("KSA-N17"), selector: #selector(onStateEvent))
        }
        
        // For previews
        init(
            title: String,
            function: String,
            values: [StateDialogItem: String] = [:],
            subtitle: String? = nil,
            showLifespanSettingsButton: Bool = false,
            showArrows: Bool = false,
            online: Bool = false,
            loading: Bool = false
        ) {
            self.lifespanSettingsCallback = { _, _, _ in }
            super.init()
            
            self.title = title
            self.subtitle = subtitle
            self.function = function
            self.values = values
            self.showLifespanSettingsButton = showLifespanSettingsButton
            self.showArrows = showArrows
            self.online = online
            self.loading = loading
        }
        
        func show(remoteId: Int32) {
            present = true
            loading = true
            
            currentIdx = 0
            channels = []
            
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleChannels($0.channels) })
                .disposed(by: self)
        }
        
        func onDismiss() {
            stopRefreshing()
            present = false
            channels = []
        }
        
        func onNext() {
            loading = true
            stopRefreshing()
            currentIdx = (currentIdx + 1) % channels.count
            publish()
            startRefreshing()
        }
        
        func onPrevious() {
            loading = true
            stopRefreshing()
            currentIdx = currentIdx - 1
            if (currentIdx < 0) {
                currentIdx = channels.count - 1
            }
            publish()
            startRefreshing()
        }
        
        func onLifespanSettingsButton() {
            present = false
            lifespanSettingsCallback(channels[currentIdx].remoteId, channels[currentIdx].caption, lightSourceLifespan)
        }
        
        private func handleChannels(_ channels: [ChannelData]) {
            self.channels = channels
            currentIdx = 0
            
            publish()
            startRefreshing()
        }
        
        private func publish() {
            title = channels[currentIdx].caption
            subtitle = channels.count > 1 ? Strings.State.dialogIndex.arguments(currentIdx + 1, channels.count) : nil
            function = channels[currentIdx].function
            online = channels[currentIdx].online
            showArrows = channels.count > 1
            showLifespanSettingsButton = channels[currentIdx].showLifespanSettingsButton
            
            if (!channels[currentIdx].infoSupported) {
                values = [StateDialogItem.channelId: String(channels[currentIdx].remoteId)]
            }
            
            if (!online || !channels[currentIdx].infoSupported) {
                loading = false
            }
        }
        
        private func startRefreshing() {
            SALog.debug("Starting channel state timer")
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.refreshTimerTick()
            }
            
            lastRefreshTime = dateProvider.currentTimestamp()
            suplaClientProvider.provide()?.channelStateRequest(withChannelId: channels[currentIdx].remoteId)
        }
        
        private func refreshTimerTick() {
            let remoteId = channels[currentIdx].remoteId
            let currentTimestamp = dateProvider.currentTimestamp()
            
            if let lastRefreshTime, lastRefreshTime + REFRESH_INTERVAL_S < currentTimestamp {
                SALog.debug("Asking for channel state of \(remoteId)")
                self.lastRefreshTime = currentTimestamp
                suplaClientProvider.provide()?.channelStateRequest(withChannelId: remoteId)
            }
        }
        
        private func stopRefreshing() {
            timer?.invalidate()
            timer = nil
        }
        
        @objc
        private func onStateEvent(notification: NSNotification) {
            if (channels.count == 0 || currentIdx < 0 || currentIdx >= channels.count) {
                return
            }
            
            let remoteId = channels[currentIdx].remoteId
            if let userInfo = notification.userInfo,
               let channelState = userInfo["state"] as? SAChannelStateExtendedValue,
               remoteId == channelState.channelId().int32Value
            {
                lightSourceLifespan = channelState.lightSourceLifespanInt()
                
                let values = StateDialogFeature.StateDialogItem.allCases
                    .reduce(into: [StateDialogFeature.StateDialogItem: String?]()) {
                        $0[$1] = $1.extract(from: channelState)
                    }
                    .filter { $0.value != nil && $0.value?.isEmpty == false }
                    .mapValues { $0! }

                self.values = values
                loading = false
            }
        }
    }
}

extension SAChannelStateExtendedValue {
    func lightSourceLifespanInt() -> Int32 {
        let lifespan: NSNumber? = lightSourceLifespan()
        
        if let lifespan {
            return lifespan.int32Value
        } else {
            return 0
        }
    }
}

extension UIViewController {
    func showAuthorizationLightSourceLifespanSettings(_ remoteId: Int32, _ caption: String, _ lifesourceLifespan: Int32) {
        SAAuthorizationDialogVC {
            SALightsourceLifespanSettingsDialog.globalInstance().show(remoteId, title: caption, lifesourceLifespan: lifesourceLifespan, vc: self)
        }.showAuthorization(self)
    }
}

private extension ChannelWithChildren {
    var channels: [ChannelData] {
        var result: [ChannelData] = []
        
        result.append(channel.channelData)
        for item in allDescendantFlat {
            result.append(item.channel.channelData)
        }
        
        return result
    }
}

private extension SAChannel {
    var channelData: ChannelData {
        @Singleton<GetChannelBaseDefaultCaptionUseCase> var getChannelBaseDefaultCaptionUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return ChannelData(
            remoteId: remote_id,
            function: getChannelBaseDefaultCaptionUseCase.invoke(function: self.func),
            caption: getCaptionUseCase.invoke(data: shareable).string,
            showLifespanSettingsButton: (flags & Int64(SUPLA_CHANNEL_FLAG_LIGHTSOURCELIFESPAN_SETTABLE)) > 0,
            infoSupported: (flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE)) > 0,
            online: status().online
        )
    }
}

private struct ChannelData {
    let remoteId: Int32
    let function: String
    let caption: String
    let showLifespanSettingsButton: Bool
    let infoSupported: Bool
    var online: Bool
}
