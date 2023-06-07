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

protocol SwapChannelPositionsUseCase {
    func invoke(firstRemoteId: Int32, secondRemoteId: Int32, locationId: Int) -> Observable<Void>
}

final class SwapChannelPositionsUseCaseImpl: SwapChannelPositionsUseCase {
    
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(firstRemoteId: Int32, secondRemoteId: Int32, locationId: Int) -> Observable<Void> {
        return profileRepository.getActiveProfile()
            .flatMapFirst { profile in
                self.channelRepository.getAllVisibleChannels(forProfile: profile, inLocation: locationId)
            }
            .map { channels in
                if (channels.count < 2) {
                    return false // nothing to do, there is at most only one channel
                }
                guard
                    let firstChannel = channels.first(where: { $0.remote_id == firstRemoteId }),
                    let secondChannel = channels.first(where: { $0.remote_id == secondRemoteId }),
                    let sourcePosition = channels.firstIndex(of: firstChannel),
                    let destinationPosition = channels.firstIndex(of: secondChannel)
                else {
                    return false
                }
                
                var newList = channels
                newList.remove(at: sourcePosition)
                newList.insert(firstChannel, at: destinationPosition)
                for position in 0...newList.count-1 {
                    newList[position].position = Int32(position)
                }
                
                return true
            }
            .flatMapFirst { save in
                if (save) {
                    return self.channelRepository.save()
                } else {
                    return Observable.just(())
                }
            }
    }
}
