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

extension ActionSelection {
    class ViewState: ObservableObject {
        @Published var profiles: SelectableList<ActionSelection.ProfileItem>? = nil {
            didSet { updateSaveDisabled() }
        }
        @Published var subjectType: SubjectType = .channel
        @Published var subjects: SelectableList<ActionSelection.SubjectItem>? = nil {
            didSet { updateSaveDisabled() }
        }
        @Published var actions: SelectableList<ActionId>? = nil {
            didSet { updateSaveDisabled() }
        }
        func updateSaveDisabled() {}
    }
    
    struct ProfilePicker: View {
        let profiles: SelectableList<ProfileItem>
        let disabled: Bool
        let onProfileChanged: ((ProfileItem?) -> Void)?
        
        init(profiles: SelectableList<ProfileItem>, disabled: Bool = false, onProfileChanged: ((ProfileItem?) -> Void)? = nil) {
            self.profiles = profiles
            self.disabled = disabled
            self.onProfileChanged = onProfileChanged
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.General.profile)
                    .padding(.leading, Distance.small)
                SuplaCore.Picker(profiles, onChange: { onProfileChanged?($0) })
                    .style(.dialog)
                    .disabled(disabled)
            }
        }
    }
    
    struct SubjectsPicker: View {
        let subjectType: SubjectType
        let subjects: SelectableList<SubjectItem>
        let disabled: Bool
        let onSubjectChanged: ((SubjectItem?) -> Void)?
        
        init(subjectType: SubjectType, subjects: SelectableList<SubjectItem>, disabled: Bool = false, onSubjectChanged: ((SubjectItem?) -> Void)? = nil) {
            self.subjectType = subjectType
            self.subjects = subjects
            self.disabled = disabled
            self.onSubjectChanged = onSubjectChanged
        }
                               
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: subjectType.name)
                    .padding(.leading, Distance.small)
                SuplaCore.SubjectPicker(subjects, onChange: { onSubjectChanged?($0) })
                    .disabled(disabled)
            }
        }
    }
    
    struct ActionsPicker: View {
        let actions: SelectableList<ActionId>
        let disabled: Bool
        let onActionChanged: ((ActionId?) -> Void)?
        
        init(actions: SelectableList<ActionId>, disabled: Bool = false, onActionChanged: ((ActionId?) -> Void)? = nil) {
            self.actions = actions
            self.disabled = disabled
            self.onActionChanged = onActionChanged
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                LabelText(text: Strings.General.action)
                    .padding(.leading, Distance.small)
                SuplaCore.Picker(actions, onChange: { onActionChanged?($0) })
                    .style(.dialog)
            }
        }
    }
}
