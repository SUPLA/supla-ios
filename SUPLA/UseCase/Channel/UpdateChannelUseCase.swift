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

final class UpdateChannelUseCase {
    
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaChannel: TSC_SuplaChannel_D) -> Bool {
        var changed = false
        
        do {
            changed = try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    self.locationRepository
                        .getLocation(for: profile, with: suplaChannel.LocationID)
                        .flatMapFirst { location in
                            self.channelRepository
                                .getChannel(for: profile, with: suplaChannel.Id)
                                .ifEmpty(switchTo: self.createChannel(remoteId: suplaChannel.Id))
                                .map { scene in (location, scene) }
                        }
                }
                .map { tuple in self.updateChannel(channel: tuple.1, suplaChannel: suplaChannel, location: tuple.0) }
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.channelRepository.save(tuple.1).map { true }
                    }
                    
                    return Observable.just(false)
                }
                .toBlocking()
                .first() ?? false
            
            if (changed) {
                listsEventsManager.emitChannelChange(remoteId: Int(suplaChannel.Id))
            }
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func createChannel(remoteId: Int32) -> Observable<SAChannel> {
        return channelRepository.create()
            .flatMapFirst { channel in
                return self.profileRepository.getActiveProfile()
                    .map { profile in
                        channel.remote_id = remoteId
                        channel.profile = profile
                        
                        return channel
                    }
            }
    }
    
    private func updateChannel(channel: SAChannel, suplaChannel: TSC_SuplaChannel_D, location: _SALocation) -> (Bool, SAChannel) {
        var changed = false
        
        let caption = String.fromC(suplaChannel.Caption)
        if (channel.caption != caption) {
            channel.caption = caption
            changed = true
        }
        if (channel.setChannelLocation(location)) {
            changed = true
        }
        if (channel.setChannelFunction(suplaChannel.Func)) {
            changed = true
        }
        if (channel.setItemVisible(1)) {
            changed = true
        }
        if (channel.setChannelAltIcon(suplaChannel.AltIcon)) {
            changed = true
        }
        if (channel.setLocationId(suplaChannel.LocationID)) {
            changed = true
        }
        if (channel.setRemoteId(suplaChannel.Id)) {
            changed = true
        }
        if (channel.setUserIconId(suplaChannel.UserIcon)) {
            changed = true
        }
        if (channel.setChannelProtocolVersion(Int32(suplaChannel.ProtocolVersion))) {
            changed = true
        }
        if (channel.setDeviceId(suplaChannel.DeviceID)) {
            changed = true
        }
        if (channel.setManufacturerId(Int32(suplaChannel.ManufacturerID))) {
            changed = true
        }
        if (channel.setProductId(Int32(suplaChannel.ProductID))) {
            changed = true
        }
        if (channel.setChannelType(suplaChannel.Type)) {
            changed = true
        }
        if (channel.setChannelFlags(Int32(suplaChannel.Flags))) {
            changed = true
        }
        
        return (changed, channel)
    }
}
