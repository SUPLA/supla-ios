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
    static func updateChannel(suplaChannel: TSC_SuplaChannel_D) -> Bool {
        return UpdateChannelUseCase().invoke(suplaChannel: suplaChannel)
    }
    
    @objc
    static func updateChannelValue(suplaChannelValue: TSC_SuplaChannelValue_B) -> Bool {
        return UpdateChannelValueUseCase().invoke(suplaChannelValue: suplaChannelValue)
    }
    
    @objc
    static func updateChannelExtendedValue(suplaChannelExtendedValue: TSC_SuplaChannelExtendedValue) -> Bool {
        return UpdateChannelExtendedValueUseCase().invoke(suplaChannelExtendedValue: suplaChannelExtendedValue)
    }
    
    // Mark: Groups
    
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
    static func updateChannelGroups() -> [NSNumber] {
        return MagicUpdateGroupsUseCase().invoke()
    }
}
