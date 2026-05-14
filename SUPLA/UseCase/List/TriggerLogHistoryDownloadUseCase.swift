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

private let MAX_REFRESH_INTERVAL: TimeInterval = 5 * 60
private let LOG_NORMAL_REFRESH_INTERVAL: TimeInterval = 10 * 60
private let LOG_OCR_REFREHS_INTERVAL: TimeInterval = 60 * 60
    
enum TriggerLogHistoryDownload {
    protocol UseCase {
        func invoke() async
    }
    
    class Implementation: UseCase {
        @Singleton<DateProvider> private var dateProvider
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
        @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
        
        func invoke() async {
            guard let activeProfile = try? await profileRepository.getActiveProfile().awaitFirstElement() else { return }
            
            var channels: [SAChannel] = []
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .icGasMeter))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .icHeatMeter))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .icWaterMeter))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .icElectricityMeter))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .staircaseTimer))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .powerSwitch))
            channels.append(contentsOf: await channelRepository.findChannelsBy(activeProfile.id, function: .lightswitch))
            
            for channel in channels {
                await handle(channel)
            }
        }
        
        private var entriesLastUpdate: [EntryKey: TimeInterval] = [:]
        
        private func handle(_ channel: SAChannel) async {
            let settings = userStateHolder.getImpulseCounterSettings(profileId: channel.profile.id, remoteId: channel.remote_id)
            guard let serverId = channel.profile.server?.id,
                  settings.showOnList != .noAggregation
            else { return }
            
            SALog.info("Found channel for aggregated value refresh: \(channel.remote_id) \(settings.showOnList)")
            
            let logsInterval = (channel.flags & Int64(SUPLA_CHANNEL_FLAG_OCR) > 0) ? LOG_OCR_REFREHS_INTERVAL : LOG_NORMAL_REFRESH_INTERVAL
            
            let currentDate = dateProvider.currentDate()
            guard let lastEntry = try? await impulseCounterMeasurementItemRepository.findOldestEntity(remoteId: channel.remote_id, serverId: serverId).awaitFirstElement(),
                  let lastEntryDate = lastEntry?.date
            else {
                let key = EntryKey(profileId: channel.profile.id, remoteId: channel.remote_id)
                let lastDownloadDate = entriesLastUpdate[key]
                entriesLastUpdate[key] = currentDate.timeIntervalSince1970
                
                if let lastDownloadDate, currentDate.timeIntervalSince1970 - lastDownloadDate <= logsInterval {
                    SALog.debug("Found channel without entries, download skipped because of interval")
                    return
                }
                
                SALog.debug("Found channel without entries, triggering download")
                downloadChannelMeasurementsUseCase.invoke(ChannelWithChildren(channel: channel))
                return
            }
            
            if (currentDate.timeIntervalSince1970 - lastEntryDate.timeIntervalSince1970 > logsInterval) {
                let key = EntryKey(profileId: channel.profile.id, remoteId: channel.remote_id)
                let lastDownloadDate = entriesLastUpdate[key]
                entriesLastUpdate[key] = currentDate.timeIntervalSince1970
                
                if let lastDownloadDate, currentDate.timeIntervalSince1970 - lastDownloadDate <= MAX_REFRESH_INTERVAL {
                    SALog.debug("Last entry older then refresh interval, but download already scheduled - skipping")
                    return
                }
                
                SALog.debug("Last entry older then refresh interval, scheduling download")
                downloadChannelMeasurementsUseCase.invoke(ChannelWithChildren(channel: channel))
                return
            }
            
            SALog.debug("No action performed for \(channel.remote_id)")
        }
    }
    
    private struct EntryKey: Hashable {
        let profileId: Int32
        let remoteId: Int32
    }
}
