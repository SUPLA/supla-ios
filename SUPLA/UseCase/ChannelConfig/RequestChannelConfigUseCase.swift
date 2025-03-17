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

protocol RequestChannelConfigUseCase {
    func invoke(suplaChannel: TSC_SuplaChannel_E, profile: AuthProfileItem) -> Observable<Void>
}

final class RequestChannelConfigUseCaseImpl: RequestChannelConfigUseCase {
    @Singleton<ChannelConfigRepository> private var channelConfigRepository
    @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase

    func invoke(suplaChannel: TSC_SuplaChannel_E, profile: AuthProfileItem) -> Observable<Void> {
        if (shouldObserveChannelConfig(suplaChannel)) {
            return channelConfigRepository.getConfig(channelRemoteId: suplaChannel.Id)
                .flatMap { config in
                    if (config != nil && config!.config_crc32 == suplaChannel.DefaultConfigCRC32) {
                        SALog.debug("Channel config not asked (remoteId: `\(suplaChannel.Id)`")
                        return Observable.just(())
                    }

                    SALog.debug("Channel config asked (remoteId: `\(suplaChannel.Id)`")
                    return self.getChannelConfigUseCase
                        .invoke(remoteId: suplaChannel.Id, type: .defaultConfig)
                        .flatMap { _ in Observable.just(()) }
                }
        }

        return Observable.just(())
    }

    private func shouldObserveChannelConfig(_ suplaChannel: TSC_SuplaChannel_E) -> Bool {
        suplaChannel.Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER ||
            suplaChannel.Func == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT ||
            suplaChannel.Func == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND ||
            suplaChannel.Func == SUPLA_CHANNELFNC_VERTICAL_BLIND ||
            suplaChannel.Func == SUPLA_CHANNELFNC_CONTAINER ||
            suplaChannel.Func == SUPLA_CHANNELFNC_WATER_TANK ||
            suplaChannel.Func == SUPLA_CHANNELFNC_SEPTIC_TANK
    }
}
