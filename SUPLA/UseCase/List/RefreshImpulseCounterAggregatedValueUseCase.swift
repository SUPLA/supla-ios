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
    
enum RefreshImpulseCounterAggregatedValue {
    protocol UseCase {
        func invoke(profileId: Int32, remoteId: Int32) async
    }
    
    class Implementation: UseCase {
        @Singleton<DateProvider> private var dateProvider
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelValueRepository> private var channelValueRepository
        @Singleton<ChannelExtendedValueRepository> private var channelExtendedValueRepository
        @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
        
        private let formatter = ImpulseCounterValueFormatter()
        
        func invoke(profileId: Int32, remoteId: Int32) async {
            let settings = userStateHolder.getImpulseCounterSettings(profileId: profileId, remoteId: remoteId)
            if (settings.showOnList == .noAggregation) {
                SALog.warning("Refresh impulse counter aggregated value started for no aggregation!")
                return
            }
            guard let profile = try? await profileRepository.getProfile(withId: profileId).awaitFirstElement(),
                  let profile
            else {
                SALog.warning("Could not find profile for given profile id: \(profileId)")
                return
            }
            guard let serverId = profile.server?.id else {
                SALog.warning("Found profile has no server assigned")
                return
            }
            
            let currentDate = dateProvider.currentDate()
            guard let entriesStartDate = settings.showOnList.aggregationStartDate(currentDate: currentDate) else {
                SALog.error("Got nil as entries start date")
                await channelValueRepository.updateAggregatedValue(profileId, remoteId, NO_VALUE_TEXT)
                return
            }
            
            guard let entries = try? await impulseCounterMeasurementItemRepository
                .findMeasurements(remoteId: remoteId, serverId: serverId, startDate: entriesStartDate, endDate: currentDate)
                .awaitFirstElement(),
                entries.isEmpty == false
            else {
                SALog.info("No entries to update")
                await channelValueRepository.updateAggregatedValue(profileId, remoteId, NO_VALUE_TEXT)
                return
            }
            
            let unit = try? await channelExtendedValueRepository.getChannelValue(for: profile, with: remoteId).awaitFirstElement()?.impulseCounter().unit()
            let aggregatedValue = entries.reduce(0.0) { $0 + $1.calculated_value }
            let formatted = formatter.format(value: aggregatedValue, format: withUnit(unit: unit, showNoValueText: false))
            
            SALog.debug("Aggregated value set to \(formatted)")
            await channelValueRepository.updateAggregatedValue(profileId, remoteId, formatted)
        }
    }
}
