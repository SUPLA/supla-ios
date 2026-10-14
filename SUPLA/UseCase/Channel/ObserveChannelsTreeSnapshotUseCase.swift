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

struct ObserveChannelsTreeSnapshot {
    struct Snapshot {
        let channelsWithChildren: [Int32: ChannelWithChildren]
    }

    protocol UseCase {
        func invoke() -> Observable<Snapshot>
    }

    final class Implementation: UseCase {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<ChannelRelationRepository> private var channelRelationRepository
        @Singleton<ChannelValueRepository> private var channelValueRepository
        @Singleton<ChannelStateRepository> private var channelStateRepository
        @Singleton<ChannelExtendedValueRepository> private var channelExtendedValueRepository
        @Singleton<ChannelConfigRepository> private var channelConfigRepository
        @Singleton<CreateChannelWithChildrenUseCase> private var createChannelWithChildrenUseCase

        private lazy var snapshot = profileRepository.getActiveProfile()
            .flatMapLatest { [weak self] profile -> Observable<Snapshot> in
                guard let self else { return .empty() }
                return Observable.combineLatest(
                    self.channelRepository.observeAllVisibleChannels(forProfile: profile),
                    self.channelRelationRepository.observeParentsMap(for: profile),
                    self.channelValueRepository.observeAll(for: profile),
                    self.channelStateRepository.observeAll(for: profile),
                    self.channelExtendedValueRepository.observeAll(for: profile),
                    self.channelConfigRepository.observeAll(for: profile)
                ) { channels, parentsMap, _, _, _, _ in
                    let channelsWithChildren = channels.reduce(into: [Int32: ChannelWithChildren]()) { result, channel in
                        result[channel.remote_id] = self.createChannelWithChildrenUseCase.invoke(
                            channel,
                            allChannels: channels,
                            parentsMap: parentsMap
                        )
                    }
                    return Snapshot(channelsWithChildren: channelsWithChildren)
                }
            }
            .share(replay: 1, scope: .forever)

        func invoke() -> Observable<Snapshot> {
            snapshot
        }
    }
}
