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
    
extension CallNfcActionFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        @Singleton<ReadNfcItem.UseCase> private var readNfcItemUseCase
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<SingleCall> private var singleCall
        
        private let url: URL
        
        init(url: URL) {
            self.url = url
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            guard let tagId = url.nfcTagId() else {
                state.step = .failure(type: .unknownUrl)
                return
            }
            
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                
                guard let tag = await readNfcItemUseCase.invoke(tagId) else {
                    await MainActor.run { state.step = .failure(type: .tagNotFound(uuid: tagId)) }
                    return
                }
                
                await MainActor.run {
                    state.tagData = TagData(name: tag.name, action: tag.action, subjectName: tag.subjectName ?? "")
                }
                
                guard let profileId = tag.profileId,
                      let profile = await profileRepository.getProfile(withId: profileId),
                      let subjectType = tag.subjectType,
                      let subjectId = tag.subjectId,
                      let actionId = tag.action else {
                    await nfcTagItemRepository.addCallItem(toTagWithUuid: tag.uuid, result: .actionMissing)
                    await MainActor.run { state.step = .failure(type: .tagNotConfigured(uuid: tagId)) }
                    return
                }
                
                do {
                    try singleCall.executeAction(
                        actionId,
                        subjectType: subjectType,
                        subjectId: subjectId,
                        authorizationEntity: profile.authorizationEntity
                    )
                    await nfcTagItemRepository.addCallItem(toTagWithUuid: tag.uuid, result: .success)
                    
                    await MainActor.run { state.step = .success }
                    
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    
                    await MainActor.run { coordinator.dismiss() }
                } catch {
                    await nfcTagItemRepository.addCallItem(toTagWithUuid: tag.uuid, result: .failure)
                    await MainActor.run { handleError(error, uuid: tagId) }
                }
            }
        }
        
        func onClose() {
            coordinator.dismiss()
        }
        
        func configureTag(_ uuid: String) {
            coordinator.dismiss()
            coordinator.navigateToEditNfcTag(uuid: uuid)
        }
        
        func addTag(_ uuid: String) {
            coordinator.dismiss()
            coordinator.navigateToEditNfcTag(uuid: uuid)
        }
        
        private func handleError(_ error: Error, uuid: String) {
            guard let singleCallError = error as? SingleCallError else {
                state.step = .failure(type: .actionFailed)
                return
            }

            return switch (singleCallError.errorCode) {
            case SUPLA_RESULTCODE_CHANNEL_IS_OFFLINE:
                state.step = .failure(type: .channelOffline)
            case SUPLA_RESULTCODE_CHANNELNOTFOUND:
                state.step = .failure(type: .channelNotFound(uuid: uuid))
            case SUPLA_RESULTCODE_INACTIVE:
                state.step = .failure(type: .actionFailed)
            default:
                state.step = .failure(type: .actionFailed)
            }
        }
    }
}
