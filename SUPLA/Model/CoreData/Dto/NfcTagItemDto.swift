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
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

struct NfcTagItemDto {
    let uuid: String
    let name: String
    let date: Date
    let readOnly: Bool

    let profileId: Int32?
    let subjectType: SubjectType?
    let subjectId: Int32?
    let actionId: ActionId?
    
    let nfcCallItems: [NfcCallItemDto]
}

extension SANfcTagItem {
    var dto: NfcTagItemDto {
        NfcTagItemDto(
            uuid: uuid ?? "",
            name: name ?? "",
            date: Date(timeIntervalSince1970: date),
            readOnly: readOnly,
            profileId: profileId.map(\.int32Value),
            subjectType: subjectType,
            subjectId: subjectId?.int32Value,
            actionId: action,
            nfcCallItems: callItemsDto
        )
    }
}

extension NfcTagItemDto {
    
    var lastReadingItems: [NfcCallItemDto] {
        Array(nfcCallItems.prefix(10))
    }
    
    func toItem(_ subjectNotExists: Bool) -> NfcTagDataDto {
        NfcTagDataDto(
            uuid: uuid,
            name: name,
            icon: .suplaIcon(name: .Icons.fncUnknown),
            profileId: profileId,
            profileName: nil,
            subjectType: subjectType,
            subjectId: subjectId,
            subjectName: nil,
            action: nil,
            readOnly: readOnly,
            subjectNotExists: subjectNotExists,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with channel: SAChannel) -> NfcTagDataDto {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return NfcTagDataDto(
            uuid: uuid,
            name: name,
            icon: getIcon(for: channel),
            profileId: profileId,
            profileName: channel.profile.displayName,
            subjectType: subjectType,
            subjectId: subjectId,
            subjectName: getCaptionUseCase.invoke(data: channel.shareable).string,
            action: actionId,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with group: SAChannelGroup) -> NfcTagDataDto {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return NfcTagDataDto(
            uuid: uuid,
            name: name,
            icon: getIcon(for: group),
            profileId: profileId,
            profileName: group.profile.displayName,
            subjectType: subjectType,
            subjectId: subjectId,
            subjectName: getCaptionUseCase.invoke(data: group.shareable).string,
            action: actionId,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with scene: SAScene) -> NfcTagDataDto {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase
        
        return NfcTagDataDto(
            uuid: uuid,
            name: name,
            icon: getSceneIconUseCase.invoke(scene),
            profileId: profileId,
            profileName: scene.profile?.displayName,
            subjectType: subjectType,
            subjectId: subjectId,
            subjectName: scene.caption,
            action: actionId,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    private func getIcon(for base: SAChannelBase) -> IconResult {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        return if let actionId {
            getChannelBaseIconUseCase.stateIcon(base, state: actionId.state(base.func))
        } else {
            .suplaIcon(name: .Icons.fncUnknown)
        }
    }
}
