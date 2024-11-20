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
    
import SharedCore

extension CounterPhotoFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<OcrImageNamingProvider> var ocrImageNamingProvider: OcrImageNamingProvider
        @Singleton<LoadActiveProfileUrlUseCase> var loadActiveProfileUrlUseCase: LoadActiveProfileUrlUseCase
        @Singleton<CacheFileAccessProxy> var cacheFileAccessProxy: CacheFileAccessProxy
        @Singleton<UserStateHolder> var userStateHolder: UserStateHolder
        @Singleton<ValuesFormatter> var valuesFormatter: ValuesFormatter
        @Singleton<DownloadOcrPhotoUseCase> var downloadOcrPhotoUseCase
        @Singleton<SuplaSchedulers> var schedulers
        
        init() {
            super.init(state: ViewState())
        }
        
        func onRefresh(_ remoteId: Int32, _ profileId: Int64) async {
            triggerPhotoDownload(remoteId, profileId)
            await updateImagesState(remoteId, profileId)
        }
        
        func loadData(_ remoteId: Int32, _ profileId: Int64) {
            loadActiveProfileUrlUseCase.invoke()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] url in
                        guard let self else { return }
                        
                        state.configurationAddress = "\(url.urlString)/channels/\(remoteId)/ocr-settings"
                        updateImages(remoteId, profileId)
                    }
                )
                .disposed(by: disposeBag)
        }
        
        private func triggerPhotoDownload(_ remoteId: Int32, _ profileId: Int64) {
            do {
                let _ = try downloadOcrPhotoUseCase.invoke(remoteId: remoteId).toBlocking().first()
            } catch {
                SALog.error("Photo update failed: \(String(describing: error))")
            }
        }
        
        @MainActor
        private func updateImagesState(_ remoteId: Int32, _ profileId: Int64) {
            updateImages(remoteId, profileId)
        }
        
        private func updateImages(_ remoteId: Int32, _ profileId: Int64) {
            guard let cacheDir = cacheFileAccessProxy.cacheDir else { return }
            
            let ocrImageName = ocrImageNamingProvider.imageName(profileId: Int64(profileId), remoteId: remoteId)
            let ocrCroppedImageName = ocrImageNamingProvider.imageCroppedName(profileId: Int64(profileId), remoteId: remoteId)
            let ocrImageFile = CacheFileAccessFile(name: ocrImageName, directory: ocrImageNamingProvider.directory)
            let ocrCroppedImageFile = CacheFileAccessFile(name: ocrCroppedImageName, directory: ocrImageNamingProvider.directory)
            
            do {
                state.image = try Data(contentsOf: ocrImageFile.file(cacheDir))
                state.imageCropped = try Data(contentsOf: ocrCroppedImageFile.file(cacheDir))
                state.date = valuesFormatter.getFullDateString(date: userStateHolder.getPhotoCreationTime(profileId: profileId, remoteId: remoteId))
            } catch {
                SALog.error("Failed to load images from files: \(String(describing: error))")
            }
        }
    }
}
