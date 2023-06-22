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

final class UpdateChannelExtendedValueUseCase {
    
    @Singleton<ChannelExtendedValueRepository> private var channelExtendedValueRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaChannelExtendedValue: TSC_SuplaChannelExtendedValue) -> Bool {
        var changed = false
        
        do {
            return try profileRepository.getActiveProfile()
                .flatMapFirst{ profile in
                    self.channelExtendedValueRepository
                        .getChannelValue(for: profile, with: suplaChannelExtendedValue.Id)
                        .ifEmpty(switchTo: self.createValue(channelRemoteId: suplaChannelExtendedValue.Id))
                }
                .map { value in
                    if (value.setValueSwift(suplaChannelExtendedValue.value)) {
                        changed = true
                    }
                    
                    return value
                }
                .flatMapFirst { value in
                    let channelsUpdateQuery = SAChannel.fetchRequest()
                        .filtered(by: NSPredicate(
                            format: "remote_id = %i AND (ev = nil OR ev <> %@)",
                            suplaChannelExtendedValue.Id, value
                        ))
                        .ordered(by: "remote_id")
                    
                    return self.channelRepository.query(channelsUpdateQuery)
                        .map { channels in
                            channels.forEach { channel in
                                channel.ev = value
                                changed = true
                            }
                            return value
                        }
                }
                .flatMapFirst { value in
                    if (changed) {
                        return self.channelExtendedValueRepository.save(value).map { true }
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
    
    func createValue(channelRemoteId: Int32) -> Observable<SAChannelExtendedValue> {
        return channelExtendedValueRepository.create()
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
