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
    
import CoreNFC

private let MIN_TIME_BETWEEN_RELOADS: TimeInterval = 1

extension NfcTagsListFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton private var prepareNfcTagUseCase: PrepareNfcTag.UseCase
        @Singleton private var readNfcItemsUseCase: ReadNfcItems.UseCase
        @Singleton private var coordinator: SuplaAppCoordinator
        @Singleton private var dateProvider: DateProvider
        
        @Singleton<NfcTagItemRepository> private var nfcTagItemRepository
        
        private var lastReloadTime: TimeInterval = 0
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            state.nfcState = NFCNDEFReaderSession.readingAvailable ? .available : .unavailable
            reloadItems()
        }
        
        override func onViewWillAppear() {
            if (dateProvider.currentTimestamp() - lastReloadTime) > MIN_TIME_BETWEEN_RELOADS {
                reloadItems()
            }
        }
        
        func onItemClick(uuid: String) {
            hideDialog()
            coordinator.navigateToNfcTagDetail(uuid: uuid)
        }
        
        func onNewItem() {
            Task {
                do {
                    let result = try await prepareNfcTagUseCase.invoke()
                    SALog.debug("Got result: \(result)")
                    
                    switch (result) {
                    case .uuid(let uuid, let readOnly): await handleScannedTag(uuid: uuid, readOnly: readOnly)
                    case .busy: break
                    }
                } catch {
                    SALog.debug("Got error: \(error)")
                }
            }
        }
        
        func hideDialog() {
            state.dialog = nil
        }
        
        private func handleScannedTag(uuid: String, readOnly: Bool) async {
            let tag = await nfcTagItemRepository.find(byUuid: uuid)
            
            if let tag {
                await MainActor.run { state.dialog = .duplicate(uuid: uuid, name: tag.name) }
            } else {
                await MainActor.run { coordinator.navigateToEditNfcTag(uuid: uuid, readOnly: readOnly) }
            }
        }
        
        private func reloadItems() {
            state.loading = true
            lastReloadTime = dateProvider.currentTimestamp()
            readNfcItemsUseCase.invoke()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] items in
                        self?.state.loading = false
                        self?.state.items = items
                    }
                )
                .disposed(by: disposeBag)
        }
    }
}
