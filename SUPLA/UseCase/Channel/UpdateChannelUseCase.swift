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
                            .ifEmpty(switchTo: self.createChannel(remoteId: suplaChannel.Id, location))
                            .map { (location, $0) }
                    }
                    .flatMapFirst { (location, channel) in
                        self.channelRepository
                            .findMaxPositionInLocation(location.location_id?.int32Value ?? 0)
                            .map { (location, channel, $0) }
                    }
                    .map { (location, channel, position) in
                        self.update(channel: channel, suplaChannel, location, position)
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

    private func createChannel(remoteId: Int32, _ location: _SALocation) -> Observable<SAChannel> {
        return channelRepository.create()
            .flatMapFirst { channel in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        channel.remote_id = remoteId
                        channel.profile = profile

                        return channel
                    }
            }
            .flatMapFirst { channel in
                self.channelRepository
                    .findMaxPositionInLocation(location.location_id?.int32Value ?? 0)
                    .map { position in
                        self.updatePosition(channel, location, position)
                        return channel
                    }
            }
    }

    private func update(
        channel: SAChannel,
        _ suplaChannel: TSC_SuplaChannel_E,
        _ location: _SALocation,
        _ position: Int32
    ) -> (Bool, SAChannel) {
        var changed = false

        let caption = String.fromC(suplaChannel.Caption)
        if (channel.caption != caption) {
            channel.caption = caption
            changed = true
        }
        if (channel.setChannelLocation(location)) {
            updatePosition(channel, location, position)
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

    private func updatePosition(_ channel: SAChannel, _ location: _SALocation, _ position: Int32) {
        if (position > 0 && channel.location_id != location.location_id?.int32Value) {
            channel.position = position + 1
        } else if (position <= 1 && channel.position != 0) {
            channel.position = 0
        }
    }
}
