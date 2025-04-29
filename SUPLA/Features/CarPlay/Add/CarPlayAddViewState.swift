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
    
extension CarPlayAddFeature {
    class ViewState: ObservableObject {
        @Published var profiles: SelectableList<ProfileItem>? = nil {
            didSet { updateSaveDisabled() }
        }
        @Published var subjectType: SubjectType = .channel
        @Published var subjects: SelectableList<SubjectItem>? = nil {
            didSet { updateSaveDisabled() }
        }
        @Published var caption: String = "" {
            didSet { updateSaveDisabled() }
        }
        @Published var actions: SelectableList<CarPlayAction>? = nil {
            didSet { updateSaveDisabled() }
        }
        
        @Published private(set) var saveDisabled: Bool = true
        @Published var showDelete: Bool = false
        
        private func updateSaveDisabled() {
            saveDisabled = profiles?.selected == nil ||
            subjects?.selected == nil ||
            caption.isEmpty ||
            actions?.selected == nil
        }
    }
    
    struct ProfileItem: PickerItem {
        var id: Int32
        var label: String
    }
    
    struct SubjectItem: SubjectPickerItem {
        var id: String
        var remoteId: Int32
        var label: String
        var actions: [CarPlayAction]
        var icon: IconResult?
        var isLocation: Bool
    }
}
