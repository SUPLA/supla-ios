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

protocol UpdateChannelUseCase {
    func invoke(suplaChannel: TSC_SuplaChannel_E) -> Observable<Bool>
}

final class UpdateChannelUseCaseImpl: UpdateChannelUseCase {
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<ChannelConfigRepository> private var channelConfigRepository
    @Singleton<RequestChannelConfigUseCase> private var requestChannelConfigUseCase

    func invoke(suplaChannel: TSC_SuplaChannel_E) -> Observable<Bool> {
        return profileRepository.getActiveProfile()
            .flatMapFirst { profile in
                self.locationRepository
                    .getLocation(for: profile, with: suplaChannel.LocationID)
                    .flatMapFirst { location in
                        self.channelRepository
                            .getChannel(for: profile, with: suplaChannel.Id)
                            .ifEmpty(switchTo: self.createChannel(remoteId: suplaChannel.Id))
                            .map { (location, $0) }
                    }
                    .map { (location, channel) in
                        self.updateChannel(channel: channel, suplaChannel: suplaChannel, location: location)
                    }
                    .flatMapFirst { (changed, channel) in
                        if (changed) {
                            return self.channelRepository.save(channel).map { true }
                        }

                        return Observable.just(false)
                    }
                    .flatMap { changed in
                        self.requestChannelConfigUseCase.invoke(suplaChannel: suplaChannel, profile: profile)
                            .map { _ in changed }
                    }
            }
            .do(
                onNext: {
                    if ($0) {
                        self.updateEventsManager.emitChannelUpdate(remoteId: Int(suplaChannel.Id))
                    }
                }
            )
    }

    private func createChannel(remoteId: Int32) -> Observable<SAChannel> {
        return channelRepository.create()
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        channel.remote_id = remoteId
                        channel.profile = profile

                        return channel
                    }
            }
    }

    private func updateChannel(channel: SAChannel, suplaChannel: TSC_SuplaChannel_E, location: _SALocation) -> (Bool, SAChannel) {
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
        if (channel.setChannelFlags(Int64(suplaChannel.Flags))) {
            changed = true
        }

        return (changed, channel)
    }
}
