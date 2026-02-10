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

import SwiftUI
    
struct NfcTagItem: Identifiable {
    var id: String { uuid }
    
    let uuid: String
    let name: String
    let icon: IconResult?
    let profileId: Int32?
    let profileName: String?
    let subjectType: SubjectType?
    let subjectId: Int32?
    let subjectName: String?
    let action: ActionId?
    let readOnly: Bool
    let subjectNotExists: Bool
    let readingItems: [NfcTagReadingItem]
    
    var noAction: Bool {
        subjectName == nil || action == nil
    }
}

struct NfcTagReadingItem {
    let date: Date
    let result: NfcCallResult
    
    var resultIconText: String {
        switch (result) {
        case .success: "✓"
        case .failure,
             .actionMissing: "𐄂"
        }
    }
    
    var resultIconColor: Color {
        switch (result) {
        case .success: .Supla.primary
        case .failure,
             .actionMissing: .Supla.error
        }
    }
    
    var resultText: String {
        switch (result) {
        case .success: Strings.Nfc.Detail.actionCompleted
        case .failure: Strings.Nfc.Detail.actionFailure
        case .actionMissing: Strings.Nfc.Detail.actionMissing
        }
    }
}

extension SANfcTagItem {
    var readingItems: [NfcTagReadingItem] {
        callItems?.compactMap { $0 as? SANfcCallItem }
            .compactMap {
                if let date = $0.date {
                    NfcTagReadingItem(date: date, result: $0.result)
                } else {
                    nil
                }
            }
            .sorted(by: {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970 }) ?? []
    }
    
    var lastReadingItems: [NfcTagReadingItem] {
        Array(readingItems.prefix(10))
    }
    
    func toItem(_ subjectNotExists: Bool) -> NfcTagItem {
        NfcTagItem(
            uuid: uuid ?? "",
            name: name ?? "",
            icon: .suplaIcon(name: .Icons.fncUnknown),
            profileId: profileId?.int32Value,
            profileName: nil,
            subjectType: subjectType,
            subjectId: subjectId?.int32Value,
            subjectName: nil,
            action: nil,
            readOnly: readOnly,
            subjectNotExists: subjectNotExists,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with channel: SAChannel) -> NfcTagItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return NfcTagItem(
            uuid: uuid ?? "",
            name: name ?? "",
            icon: getIcon(for: channel),
            profileId: profileId?.int32Value,
            profileName: channel.profile.name,
            subjectType: subjectType,
            subjectId: subjectId?.int32Value,
            subjectName: getCaptionUseCase.invoke(data: channel.shareable).string,
            action: action,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with group: SAChannelGroup) -> NfcTagItem {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return NfcTagItem(
            uuid: uuid ?? "",
            name: name ?? "",
            icon: getIcon(for: group),
            profileId: profileId?.int32Value,
            profileName: group.profile.name,
            subjectType: subjectType,
            subjectId: subjectId?.int32Value,
            subjectName: getCaptionUseCase.invoke(data: group.shareable).string,
            action: action,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    func toItem(with scene: SAScene) -> NfcTagItem {
        @Singleton<GetSceneIconUseCase> var getSceneIconUseCase
        
        return NfcTagItem(
            uuid: uuid ?? "",
            name: name ?? "",
            icon: getSceneIconUseCase.invoke(scene),
            profileId: profileId?.int32Value,
            profileName: scene.profile?.name,
            subjectType: subjectType,
            subjectId: subjectId?.int32Value,
            subjectName: scene.caption,
            action: action,
            readOnly: readOnly,
            subjectNotExists: false,
            readingItems: lastReadingItems
        )
    }
    
    private func getIcon(for base: SAChannelBase) -> IconResult {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        return if let action {
            getChannelBaseIconUseCase.stateIcon(base, state: action.state(base.func))
        } else {
            .suplaIcon(name: .Icons.fncUnknown)
        }
    }
}
