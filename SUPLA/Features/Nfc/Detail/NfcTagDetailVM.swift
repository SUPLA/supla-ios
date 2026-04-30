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
    
extension NfcTagDetailFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton private var readNfcItemUseCase: ReadNfcItem.UseCase
        @Singleton private var lockNfcTagUseCase: LockNfcTag.UseCase
        @Singleton private var coordinator: SuplaAppCoordinator
        
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ProfileRepository> private var profileRepository
        
        private let uuid: String
        private var titleSetter: ((String) -> Void)? = nil
        
        init(uuid: String) {
            self.uuid = uuid
            super.init(state: ViewState())
        }
        
        func setTitleSetter(_ setter: ((String) -> Void)?) {
            titleSetter = setter
        }
        
        override func onViewWillAppear() {
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                guard let tag = try? await readNfcItemUseCase.invoke(uuid).awaitFirstElement() else { return }
                let profilesCount = await profileRepository.getProfileCount()
                
                await MainActor.run {
                    state.tagName = tag.name
                    state.tagUuid = tag.uuid
                    state.tagLocked = tag.readOnly
                    state.subjectName = tag.subjectName
                    state.actionId = tag.action
                    state.lastReadingItems = tag.readingItems
                    state.profileName = profilesCount > 1 ? tag.profileName : nil
                    
                    titleSetter?(tag.name)
                }
            }
        }
        
        func onDelete() {
            if (state.tagLocked) {
                state.dialog = .deleteLockedTag
            } else {
                state.dialog = .deleteTag
            }
        }
        
        func onInfoClick() {
            state.dialog = .info
        }
        
        func onLockClick() {
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                do {
                    let result = try await lockNfcTagUseCase.invoke(state.tagUuid, name: state.tagName)
                    if (result == .success) {
                        await nfcTagItemRepository.markReadOnly(uuid: state.tagUuid)
                        await MainActor.run {
                            state.tagLocked = true
                        }
                    }
                } catch {
                    SALog.warning("Lock failed with error: \(String(describing: error))")
                    if !(error is NfcError) {
                        await MainActor.run {
                            state.dialog = .lockFailed
                        }
                    }
                }
            }
        }
        
        func onEditClick() {
            coordinator.navigateToEditNfcTag(uuid: uuid)
        }
        
        func onDeleteClick() {
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                let deleted = await nfcTagItemRepository.delete(byUuid: uuid)
                
                await MainActor.run {
                    if (deleted) {
                        coordinator.popViewController()
                    }
                }
            }
        }
        
        func onDismissDialogs() {
            state.dialog = nil
        }
    }
}
