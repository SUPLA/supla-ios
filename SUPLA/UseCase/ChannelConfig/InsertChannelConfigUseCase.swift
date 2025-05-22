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

protocol InsertChannelConfigUseCase {
    func invoke(config: SuplaChannelConfig?, result: SuplaConfigResult) -> Observable<Void>
}

final class InsertChannelConfigUseCaseImpl: InsertChannelConfigUseCase {
    @Singleton<ChannelConfigRepository> private var channelConfigRepository
    @Singleton<ChannelRepository> private var channelRepository
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<GeneralPurposeMeterItemRepository> private var generalPurposeMeterItemRepository
    @Singleton<DownloadEventsManager> private var downloadEventManager
    
    func invoke(config: SuplaChannelConfig?, result: SuplaConfigResult) -> Observable<Void> {
        if (result != .resultTrue) {
            return Observable.just(())
        }
        
        if let suplaConfig = config as? SuplaChannelContainerConfig {
            SALog.info("Saving config (remoteId: `\(suplaConfig.remoteId)`, function: `\(suplaConfig.channelFunc ?? -1)`)")
            return getOrCreateConfig(suplaConfig.remoteId, suplaConfig: suplaConfig)
                .map { self.updateConfig($0, suplaConfig) }
                .flatMap { self.channelConfigRepository.save($0) }
        }
        
        if let suplaConfig = config as? SuplaChannelHvacConfig {
            SALog.info("Saving config (remoteId: `\(suplaConfig.remoteId)`, function: `\(suplaConfig.channelFunc ?? -1)`)")
            return getOrCreateConfig(suplaConfig.remoteId, suplaConfig: suplaConfig)
                .map { self.updateConfig($0, suplaConfig) }
                .flatMap { self.channelConfigRepository.save($0) }
        }
        
        if let suplaConfig = config as? SuplaChannelGeneralPurposeMeasurementConfig {
            SALog.info("Saving config (remoteId: `\(suplaConfig.remoteId)`, function: `\(suplaConfig.channelFunc ?? -1)`")
            return getOrCreateConfig(suplaConfig.remoteId)
                .map { self.updateConfig($0, suplaConfig) }
                .flatMap { self.channelConfigRepository.save($0) }
        }
        
        if let suplaConfig = config as? SuplaChannelGeneralPurposeMeterConfig {
            SALog.info("Saving config (remoteId: `\(suplaConfig.remoteId)`, function: `\(suplaConfig.channelFunc ?? -1)`)")
            return getOrCreateConfig(suplaConfig.remoteId, suplaConfig: suplaConfig)
                .map { self.updateConfig($0, suplaConfig) }
                .flatMap { self.channelConfigRepository.save($0) }
        }
        
        if let suplaConfig = config as? SuplaChannelFacadeBlindConfig {
            SALog.info("Saving config (remoteId: `\(suplaConfig.remoteId)`, function: `\(suplaConfig.channelFunc ?? -1)`)")
            return getOrCreateConfig(suplaConfig.remoteId, suplaConfig: suplaConfig)
                .map { self.updateConfig($0, suplaConfig) }
                .flatMap { self.channelConfigRepository.save($0) }
        }
        
        SALog.info("Got config which cannot be stored (remoteId: `\(config?.remoteId ?? -1)`, function: `\(config?.channelFunc ?? -1)`)")
        
        if let config = config,
           shouldHandle(config)
        {
            // if could not store try to delete
            return profileRepository.getActiveProfile()
                .flatMap { profile in
                    self.channelRepository.getChannel(for: profile, with: config.remoteId)
                        .map { (profile, $0) }
                }
                .flatMap { self.channelConfigRepository.deleteAllFor(channel: $0.1, profile: $0.0) }
        }
        
        return Observable.just(())
    }
    
    private func getOrCreateConfig(
        _ channelRemoteId: Int32,
        suplaConfig: SuplaChannelConfig? = nil
    ) -> Observable<(SAChannelConfig)> {
        return channelConfigRepository.getConfig(channelRemoteId: channelRemoteId)
            .compactMap { $0 }
            .flatMap { config in
                if let suplaConfig = suplaConfig as? SuplaChannelGeneralPurposeMeterConfig,
                   let meterConfig = config.configAsSuplaConfig() as? SuplaChannelGeneralPurposeMeterConfig,
                   self.shouldCleanupHistory(meterConfig, suplaConfig)
                {
                    SALog.info("Triggering history deletion for \(channelRemoteId)")
                    return self.profileRepository.getActiveProfile()
                        .flatMap { self.generalPurposeMeterItemRepository.deleteAll(remoteId: channelRemoteId, serverId: $0.server?.id) }
                        .map { _ in
                            self.downloadEventManager.emitProgressState(remoteId: channelRemoteId, state: .refresh)
                            return config
                        }
                }
                
                return Observable.just(config)
            }
            .ifEmpty(switchTo: createConfig(channelRemoteId))
    }
    
    private func createConfig(_ channelRemoteId: Int32) -> Observable<SAChannelConfig> {
        profileRepository.getActiveProfile()
            .flatMap { profile in
                self.channelRepository.getChannel(for: profile, with: channelRemoteId)
                    .map { (profile, $0) }
            }
            .flatMap { (profile, channel) in
                self.channelConfigRepository.create()
                    .map { config in
                        config.profile = profile
                        config.channel = channel
                       
                        return config
                    }
            }
    }
    
    private func updateConfig(
        _ config: SAChannelConfig,
        _ suplaConfig: SuplaChannelGeneralPurposeMeasurementConfig
    ) -> SAChannelConfig {
        config.config = suplaConfig.toJson()
        config.config_type = Int32(ChannelConfigType.generalPurposeMeasurement.rawValue)
        config.config_crc32 = suplaConfig.crc32
        
        return config
    }
    
    private func updateConfig(
        _ config: SAChannelConfig,
        _ suplaConfig: SuplaChannelGeneralPurposeMeterConfig
    ) -> SAChannelConfig {
        config.config = suplaConfig.toJson()
        config.config_type = Int32(ChannelConfigType.generalPurposeMeter.rawValue)
        config.config_crc32 = suplaConfig.crc32
        
        return config
    }
    
    private func updateConfig(
        _ config: SAChannelConfig,
        _ suplaConfig: SuplaChannelFacadeBlindConfig
    ) -> SAChannelConfig {
        config.config = suplaConfig.toJson()
        config.config_type = Int32(ChannelConfigType.facadeBlind.rawValue)
        config.config_crc32 = suplaConfig.crc32
        
        return config
    }
    
    private func updateConfig(
        _ config: SAChannelConfig,
        _ suplaConfig: SuplaChannelContainerConfig
    ) -> SAChannelConfig {
        config.config = suplaConfig.toJson()
        config.config_type = Int32(ChannelConfigType.container.rawValue)
        config.config_crc32 = suplaConfig.crc32
        
        return config
    }
    
    private func updateConfig(
        _ config: SAChannelConfig,
        _ suplaConfig: SuplaChannelHvacConfig
    ) -> SAChannelConfig {
        config.config = suplaConfig.toJson()
        config.config_type = Int32(ChannelConfigType.hvac.rawValue)
        config.config_crc32 = suplaConfig.crc32
        
        return config
    }
    
    private func shouldHandle(_ config: SuplaChannelConfig) -> Bool {
        config.channelFunc == SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
            || config.channelFunc == SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
            || config.channelFunc == SUPLA_CHANNELFNC_VERTICAL_BLIND
            || config.channelFunc == SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
            || config.channelFunc == SUPLA_CHANNELFNC_CONTAINER
            || config.channelFunc == SUPLA_CHANNELFNC_WATER_TANK
            || config.channelFunc == SUPLA_CHANNELFNC_SEPTIC_TANK
    }
    
    private func shouldCleanupHistory(_ oldConfig: SuplaChannelConfig, _ newConfig: SuplaChannelGeneralPurposeMeterConfig) -> Bool {
        if let oldConfig = oldConfig as? SuplaChannelGeneralPurposeMeterConfig {
            return oldConfig.counterType != newConfig.counterType || oldConfig.fillMissingData != newConfig.fillMissingData
        }
        
        return true
    }
}
