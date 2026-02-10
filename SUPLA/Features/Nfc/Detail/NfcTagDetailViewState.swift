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

extension NfcTagDetailFeature {
    class ViewState: ObservableObject {
        @Published var tagName: String = ""
        @Published var tagUuid: String = ""
        @Published var tagLocked: Bool = false
        @Published var actionId: ActionId? = nil
        @Published var subjectName: String? = nil
        @Published var lastReadingItems: [NfcTagReadingItem] = []
        @Published var dialog: DialogType? = nil
        
        init(
            tagName: String = "",
            tagUuid: String = "",
            tagLocked: Bool = false,
            actionId: ActionId? = nil,
            subjectName: String? = nil,
            lastReadingItems: [NfcTagReadingItem] = [],
            dialog: DialogType? = nil
        ) {
            self.tagName = tagName
            self.tagUuid = tagUuid
            self.tagLocked = tagLocked
            self.actionId = actionId
            self.subjectName = subjectName
            self.lastReadingItems = lastReadingItems
            self.dialog = dialog
        }
    }
    
    enum DialogType {
        case deleteTag
        case deleteLockedTag
        case info
        case lockFailed
    }
}
