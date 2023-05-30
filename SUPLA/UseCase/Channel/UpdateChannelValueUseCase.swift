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

final class UpdateChannelValueUseCase {
    
    @Singleton<ChannelValueRepository> private var channelValueRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaChannelValue: TSC_SuplaChannelValue_B) -> Bool {
        var changed = false
        
        do {
            changed = try channelValueRepository
                .getChannelValue(channelRemoteId: Int(suplaChannelValue.Id))
                .ifEmpty(switchTo: createChannelValue(channelRemoteId: suplaChannelValue.Id))
                .map { value in
                    if (value.setValueSwift(suplaChannelValue.value)) {
                        changed = true
                    }
                    if (value.setOnlineState(suplaChannelValue.online)) {
                        changed = true
                    }
                    return value
                }
                .flatMapFirst { (value: SAChannelValue) in
                    let channelUpdateQuery = SAChannel.fetchRequest()
                        .filtered(by: NSPredicate(format: "remote_id = %i AND (value = nil OR value <> %@)", suplaChannelValue.Id, value))
                        .ordered(by: "remote_id")

                    return self.channelRepository.query(channelUpdateQuery)
                        .map { channels in
                            channels.forEach { channel in
                                channel.value = value
                                changed = true
                            }

                            return value
                        }
                }
                .flatMapFirst { value in
                    let groupsUpadteQuery = SAChannelGroupRelation.fetchRequest()
                        .filtered(by: NSPredicate(format: "channel_id = %i AND (value = nil OR value <> %@)", suplaChannelValue.Id, value))
                        .ordered(by: "channel_id")

                    return self.channelGroupRelationRepository.query(groupsUpadteQuery)
                        .map { groups in
                            groups.forEach { group in
                                group.value = value
                                changed = true
                            }

                            return value
                        }
                }
                .flatMapFirst { value in
                    if (changed) {
                        return self.channelValueRepository.save(value).map { true }
                    }
                    
                    return Observable.just(false)
                }
                .toBlocking()
                .first() ?? false
            
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func createChannelValue(channelRemoteId: Int32) -> Observable<SAChannelValue> {
        return channelValueRepository.create()
            .flatMapFirst { value in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        value.initWithChannelId(channelRemoteId)
                        value.profile = profile
                        
                        return value
                    }
            }
    }
}

