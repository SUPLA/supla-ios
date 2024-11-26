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

protocol DownloadOcrPhotoUseCase {
    func invoke(remoteId: Int32) -> Completable
}

final class DownloadOcrPhotoUseCaseImpl: DownloadOcrPhotoUseCase {
    
    @Singleton<SuplaCloudService> var cloudService
    @Singleton<StoreChannelOcrPhotoUseCase> var storeChannelOcrPhotoUseCase
    @Singleton<ProfileRepository> var profileRepository
    @Singleton<UserStateHolder> var userStateHolder
    
    func invoke(remoteId: Int32) -> Completable {
        Completable.create { subscriber in
            do {
                let photo = try self.cloudService.getImpulseCounterPhoto(remoteId: remoteId).subscribeSynchronous()
                let profile = try self.profileRepository.getActiveProfile().subscribeSynchronous()
                
                if let profile, let photo {
                    self.storeChannelOcrPhotoUseCase.invoke(remoteId: remoteId, profileId: Int64(profile.id), photo: photo)
                    self.userStateHolder.setPhotoCreationTime(photo.createdAt, profileId: profile.id, remoteId: remoteId)
                }
                subscriber(.completed)
            } catch {
                SALog.error("Could not download photo \(String(describing: error))")
                subscriber(.error(error))
            }
            
            return Disposables.create {}
        }
    }
}
