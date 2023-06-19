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

final class UpdateChannelIconRelationsUseCase {
    
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke() {
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    let request = SAChannel.fetchRequest()
                        .filtered(by: NSPredicate(format: "((usericon_id <> 0 AND usericon = nil) OR (usericon != nil AND usericon.remote_id != usericon_id)) AND profile = %@", profile))
                        .ordered(by: "remote_id")
                    return self.channelRepository.query(request)
                }
                .flatMapFirst { Observable.from($0) }
                .flatMap { channel in
                    if (channel.usericon_id != 0) {
                        return self.updateRelation(channel: channel)
                    } else if(channel.usericon != nil) {
                        return self.removeRelation(channel: channel)
                    } else {
                        return Observable.just(())
                    }
                }
                .toBlocking()
                .first()
            
        } catch {
            NSLog("Channels icons update failed with error \(error)")
        }
    }
    
    private func updateRelation(channel: SAChannel) -> Observable<Void> {
        self.userIconRepository.getIcon(for: channel.profile, withId: channel.usericon_id)
            .flatMapFirst { icon in
                if (icon != channel.usericon) {
                    channel.usericon = icon
                    self.listsEventsManager.emitChannelChange(remoteId: Int(channel.remote_id))
                    return self.userIconRepository.save()
                } else {
                    return Observable.just(())
                }
            }
    }
    
    private func removeRelation(channel: SAChannel) -> Observable<Void> {
        channel.usericon = nil
        self.listsEventsManager.emitChannelChange(remoteId: Int(channel.remote_id))
        return self.channelRepository.save()
    }
}
