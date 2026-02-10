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
    
extension EditTagFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaAppCoordinator> private var coordinator
        
        private let uuid: String
        private let readOnly: Bool?
        private var selections: [ActionSelection.Selection] = []
        
        init(uuid: String, readOnly: Bool? = nil) {
            self.uuid = uuid
            self.readOnly = readOnly
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                guard let profiles = try? await profileRepository.getAllProfiles().awaitFirstElement()?.toActionSelectionItems() else { return }
                
                if let tag = await nfcTagItemRepository.find(byUuid: uuid) {
                    await handleExistingTag(tag, profiles)
                } else {
                    await handleNewTag(profiles)
                }
            }
        }
        
        func onSubjectTypeChanged(_ type: SubjectType) {
            guard let profile = state.profiles?.selected else { return }
            
            let lastSubjectId = selections.lastSubjectId(profile.id, type)
            let lastAction = selections.lastAction(profile.id, type, lastSubjectId)
            
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                let subjects = await ActionSelection.getSubjects(profile.id, type)
                
                await MainActor.run {
                    self.state.subjects = subjects?.asSelectableList(selectedId: lastSubjectId)
                    self.state.actions = self.state.subjects?.selected?.actions.asSelectableList(selectedAction: lastAction)
                }
            }
        }
        
        func onSubjectChanged(_ item: ActionSelection.SubjectItem?) {
            guard let item, let profile = state.profiles?.selected else { return }
            let subjectType = state.subjectType
            let lastAction = selections.lastAction(profile.id, subjectType, item.remoteId)
            
            state.subjects = state.subjects?.changing(path: \.selected, to: item)
            state.actions = item.actions.asSelectableList(selectedAction: lastAction)
        }
        
        func onActionChanged(_ action: ActionId?) {
            state.actions = state.actions?.changing(path: \.selected, to: action)

            if let action,
               let profileId = state.profiles?.selected?.id,
               let subjectId = state.subjects?.selected?.remoteId
            {
                let selection = ActionSelection.Selection(
                    profileId: profileId,
                    subjectType: state.subjectType,
                    subjectId: subjectId,
                    action: action
                )

                selections.removeAll { $0.hashValue == selection.hashValue }
                selections.append(selection)
            }
        }
        
        func onSave() {
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                let success = await nfcTagItemRepository.save(
                    uuid: uuid,
                    name: state.tagName,
                    profileId: state.profiles?.selected?.id,
                    subjectType: state.subjectType,
                    subjectId: state.subjects?.selected?.remoteId,
                    actionId: state.actions?.selected,
                    readOnly: readOnly
                )
                
                await MainActor.run {
                    if (success) {
                        coordinator.popViewController()
                    }
                }
            }
        }
        
        private func handleExistingTag(_ tag: SANfcTagItem, _ profiles: SelectableList<ActionSelection.ProfileItem>) async {
            let tagName = tag.name ?? ""
            let profileId = tag.profileId?.int32Value ?? profiles.selected?.id
            let subjectId = tag.subjectId?.int32Value
            let actionId = tag.action
            let subjects = await ActionSelection.getSubjects(profileId, tag.subjectType ?? .channel)
            
            await MainActor.run {
                self.state.uuid = uuid
                self.state.tagName = tagName
                self.state.profiles = profiles
                
                if let selectableSubjects = subjects?.asSelectableList(selectedId: subjectId) {
                    self.state.subjects = selectableSubjects
                    self.state.actions = selectableSubjects.selected?.actions.asSelectableList(selectedAction: actionId)
                }
            }
        }
        
        private func handleNewTag(_ profiles: SelectableList<ActionSelection.ProfileItem>) async {
            let profileId = profiles.selected?.id
            let subjects = await ActionSelection.getSubjects(profileId, .channel)
            
            await MainActor.run {
                self.state.uuid = uuid
                self.state.tagName = ""
                self.state.profiles = profiles
                
                if let selectableSubjects = subjects?.asSelectableList() {
                    self.state.subjects = selectableSubjects
                    self.state.actions = selectableSubjects.selected?.actions.asSelectableList()
                }
            }
        }
    }
}

