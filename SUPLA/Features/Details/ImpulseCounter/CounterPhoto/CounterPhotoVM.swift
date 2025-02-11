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
    
import RxSwift
import SharedCore

extension CounterPhotoFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<SuplaSchedulers> var schedulers
        @Singleton<UserStateHolder> var userStateHolder
        @Singleton<ValuesFormatter> var valuesFormatter
        @Singleton<SuplaCloudService> var suplaCloudService
        @Singleton<CacheFileAccessProxy> var cacheFileAccessProxy
        @Singleton<OcrImageNamingProvider> var ocrImageNamingProvider
        @Singleton<DownloadOcrPhotoUseCase> var downloadOcrPhotoUseCase
        @Singleton<LoadActiveProfileUrlUseCase> var loadActiveProfileUrlUseCase
        
        private let dateFormatter = ISO8601DateFormatter()
        
        init() {
            super.init(state: ViewState())
        }
        
        func onRefresh(_ remoteId: Int32) async {
            Task {
                do {
                    if let data = try getLoadingObservable(remoteId).subscribeSynchronous() {
                        await updateView(data: data, remoteId: remoteId)
                    }
                } catch {
                    await setError()
                }
            }
        }
        
        func loadData(_ remoteId: Int32) {
            state.loading = true
            getLoadingObservable(remoteId)
                .asDriver()
                .drive(onNext: { [weak self] result in
                    self?.state.loading = false
                    switch result {
                    case .success(let data):
                        self?.state.loadingError = false
                        self?.handlePhoto(latest: data.0)
                        self?.handlePhotos(photos: data.1)
                        self?.state.configurationAddress = "\(data.2.urlString)/channels/\(remoteId)/ocr-settings"
                    case .error:
                        self?.state.loadingError = true
                    }
                })
                .disposed(by: disposeBag)
        }
        
        private func getLoadingObservable(_ remoteId: Int32) -> Observable<(ImpulseCounterPhotoDto, [ImpulseCounterPhotoDto], CloudUrl)> {
            Observable.zip(
                suplaCloudService.getImpulseCounterPhoto(remoteId: remoteId),
                suplaCloudService.getImpulseCounterPhotoHistory(remoteId: remoteId),
                loadActiveProfileUrlUseCase.invoke().asObservable()
            ) { photo, photos, url in (photo, photos, url) }
        }
        
        private func handlePhoto(latest: SharedCore.ImpulseCounterPhotoDto) {
            state.latestPhoto = OcrPhoto(
                id: latest.id,
                date: formatDate(isoDate: latest.createdAt),
                original: latest.imageData,
                cropped: latest.imageCroppedData,
                value: .waiting
            )
        }
        
        private func handlePhotos(photos: [SharedCore.ImpulseCounterPhotoDto]) {
            state.photos = photos.map { photo in
                OcrPhoto(
                    id: photo.id,
                    date: formatDate(isoDate: photo.createdAt),
                    original: photo.imageData,
                    cropped: photo.imageCroppedData,
                    value: getOcrValue(photo: photo)
                )
            }
        }
        
        private func getOcrValue(photo: SharedCore.ImpulseCounterPhotoDto) -> OcrValue {
            if (photo.processedAt == nil) {
                .waiting
            } else if photo.measurementValid, let value = photo.resultMeasurement {
                .success(value: value.stringValue)
            } else if let value = photo.resultMeasurement {
                .warning(value: value.stringValue)
            } else {
                .error
            }
        }
        
        private func formatDate(isoDate: String) -> String {
            valuesFormatter.getFullDateString(date: dateFormatter.date(from: isoDate)) ?? NO_VALUE_TEXT
        }
        
        @MainActor
        private func updateView(data: (ImpulseCounterPhotoDto, [ImpulseCounterPhotoDto], CloudUrl), remoteId: Int32) {
            state.loadingError = false
            handlePhoto(latest: data.0)
            handlePhotos(photos: data.1)
            state.configurationAddress = "\(data.2.urlString)/channels/\(remoteId)/ocr-settings"
        }
        
        @MainActor
        private func setError() {
            state.loadingError = true
        }
    }
}

extension SharedCore.ImpulseCounterPhotoDto {
    var imageCroppedData: Data? {
        if let imageCropped,
           let data = Data(base64Encoded: imageCropped, options: .ignoreUnknownCharacters)
        {
            data
        } else {
            nil
        }
    }
    
    var imageData: Data? {
        if let image,
           let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)
        {
            data
        } else {
            nil
        }
    }
}
