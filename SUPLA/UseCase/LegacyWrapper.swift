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

@objc
final class UseCaseLegacyWrapper: NSObject {
    // MARK: Scenes
    
    @objc
    static func changeScenesVisibility(from: Int16, to: Int16) -> Bool {
        return ChangeScenesVisibilityUseCase().invoke(from: from, to: to)
    }
    
    @objc
    static func updateScene(scene: TSC_SuplaScene) -> Bool {
        return UpdateSceneUseCase().invoke(suplaScene: scene)
    }
    
    @objc
    static func updateSceneState(state: TSC_SuplaSceneState, clientId: Int) -> Bool {
        return UpdateSceneStateUseCase().invoke(state: state, clientId: clientId)
    }
    
    @objc
    static func updateSceneIconsRelation() {
        UpdateSceneIconRelationsUseCase().invoke()
    }
    
    // MARK: Locations
    
    @objc
    static func updateLocation(suplaLocation: TSC_SuplaLocation) -> Bool {
        return UpdateLocationUseCase().invoke(suplaLocation: suplaLocation)
    }
    
    // MARK: Channels
    
    @objc
    static func changeChannelsVisibility(from: Int16, to: Int16) -> Bool {
        return ChangeChannelsVisibilityUseCase().invoke(from: from, to: to)
    }
    
    @objc
    static func updateChannel(suplaChannel: TSC_SuplaChannel_E) -> Bool {
        @Singleton<UpdateChannelUseCase> var updateChannelUseCase
        do {
            return try updateChannelUseCase.invoke(suplaChannel: suplaChannel).subscribeSynchronous() ?? false
        } catch {
            SALog.error("Group total count update failed \(error)")
            return false
        }
    }
    
    @objc
    static func updateChannelValue(suplaChannelValue: TSC_SuplaChannelValue_B) -> Bool {
        return UpdateChannelValueUseCase().invoke(suplaChannelValue: suplaChannelValue)
    }
    
    @objc
    static func updateChannelExtendedValue(suplaChannelExtendedValue: TSC_SuplaChannelExtendedValue) -> Bool {
        return UpdateChannelExtendedValueUseCase().invoke(suplaChannelExtendedValue: suplaChannelExtendedValue)
    }
    
    @objc
    static func updateChannelIconsRelation() {
        UpdateChannelIconRelationsUseCase().invoke()
    }
    
    // MARK: Groups
    
    @objc
    static func changeGroupsVisibility(from: Int16, to: Int16) -> Bool {
        return ChangeGroupsVisibilityUseCase().invoke(from: from, to: to)
    }
    
    @objc
    static func updateGroup(suplaGroup: TSC_SuplaChannelGroup_B) -> Bool {
        return UpdateGroupUseCase().invoke(suplaGroup: suplaGroup)
    }
    
    @objc
    static func updateGroupRelation(suplaGroupRelation: TSC_SuplaChannelGroupRelation) -> Bool {
        return UpdateChannelGroupRelationUseCase().invoke(suplaGroupRelation: suplaGroupRelation)
    }
    
    @objc
    static func changeChannelGroupRelationsVisibility(from: Int16, to: Int16) -> Bool {
        return ChangeChannelGroupRelationsVisibilityUseCase().invoke(from: from, to: to)
    }
    
    @objc
    static func updateChannelGroups() -> [Int32] {
        @Singleton<UpdateChannelGroupTotalValueUseCase> var updateChannelGroupTotalValueUseCase
        do {
            return try updateChannelGroupTotalValueUseCase.invoke().subscribeSynchronous() ?? []
        } catch {
            SALog.error("Group total count update failed \(error)")
            return []
        }
    }
    
    @objc
    static func updateGroupIconsRelation() {
        UpdateGroupIconRelationsUseCase().invoke()
    }
    
    // MARK: Icons
    
    @objc
    static func getAllIconsToDownload() -> [Int32] {
        return GetAllIconsToDownloadUseCase().invoke()
    }
    
    @objc
    static func saveIcon(remoteId: NSNumber, images: [String], darkImages: [String]?) {
        SaveIconUseCase().invoke(remoteId: Int32(remoteId as! Int), images: images, darkImages: darkImages)
    }
    
    @objc
    static func insertChannelRelation(relation: TSC_SuplaChannelRelation) {
        do {
            try InsertChannelRelationForProfileUseCase().invoke(suplaRelation: relation).subscribeSynchronous()
        } catch {
            SALog.error("Could not insert relation `\(relation)` because of `\(error)`")
        }
    }
    
    @objc
    static func markChannelRelationsAsRemovable() {
        do {
            try MarkChannelRelationsAsRemovableUseCase().invoke().subscribeSynchronous()
        } catch {
            SALog.error("Could not mark relations as removable because of `\(error)`")
        }
    }
    
    @objc
    static func deleteRemovableRelations() {
        do {
            try DeleteRemovableChannelRelationsUseCase().invoke().subscribeSynchronous()
        } catch {
            SALog.error("Could not delete removable relations because of `\(error)`")
        }
    }
    
    @objc
    static func getChannelCount() -> Int {
        @Singleton<ProfileRepository> var profileRepository;
        @Singleton<ChannelRepository> var channelRepository;
        
        do {
            return try profileRepository.getActiveProfile()
                .flatMapFirst { channelRepository.getAllChannels(forProfile: $0) }
                .map { $0.count }
                .subscribeSynchronous() ?? 0
        } catch {
            return 0
        }
    }
    
    @objc
    static func loadServerHostName() -> String? {
        do {
            return try UpdateServerHostNameUseCase().invoke().subscribeSynchronous()
        } catch {
            SALog.error("Could not load server address because of \(error)")
            return nil
        }
    }
    
    @objc
    static func updatePreferredProtocolVersion(_ version: Int) {
        do {
            try UpdatePreferredProtocolVersionUseCase().invoke(version: version).subscribeSynchronous()
        } catch {
            SALog.error("Could not update preferred protocol version to \(version)")
        }
    }
    
    @objc
    static func insertChannelConfig(_ suplaResult: UInt8, _ suplaConfig: TSCS_ChannelConfig, _ crc32: Int64) {
        @Singleton<InsertChannelConfigUseCase> var insertChannelConfigUseCase
        let result = SuplaConfigResult.from(value: suplaResult)
        let config = SuplaChannelConfig.from(suplaConfig: suplaConfig, crc32: crc32)
        
        do {
            try insertChannelConfigUseCase.invoke(config: config, result: result).subscribeSynchronous()
        } catch {
            SALog.error("Could not insert config of channel id `\(config.remoteId)`")
        }
    }
    
    @objc
    static func getChannelIcon(_ channel: SAChannelBase, _ iconType: IconType) -> UIImage? {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        return getChannelBaseIconUseCase.invoke(channel: channel, type: iconType)
    }
    
    @objc
    static func getChannelBaseCaption(_ channelBase: SAChannelBase) -> String {
        @Singleton<GetChannelBaseCaptionUseCase> var getChannelBaseCaptionUseCase
        return getChannelBaseCaptionUseCase.invoke(channelBase: channelBase)
    }
    
    @objc
    static func getActivePercentage(_ channelGroup: SAChannelGroup) -> Int32 {
        @Singleton<GetGroupActivePercentageUseCase> var getGroupActivePercentageUseCase
        return Int32(getGroupActivePercentageUseCase.invoke(channelGroup))
    }
}
