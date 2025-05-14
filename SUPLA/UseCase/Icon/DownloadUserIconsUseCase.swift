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

enum DownloadUserIcons {
    static let iconsLimitPerRequest: Int = 10
    
    protocol UseCase {
        func invoke() -> Observable<Result>
    }
    
    final class Implementation: UseCase {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaCloudService> private var suplaCloudService
        @Singleton<UserIcons.UseCase> private var userIconsUseCase
        @Singleton<UpdateEventsManager> private var updateEventsManager
        @Singleton<GetAllIconsToDownload.UseCase> private var getAllIconsToDownloadUseCase
        
        func invoke() -> Observable<Result> {
            getAllIconsToDownloadUseCase.invoke()
                .map { ResultTo(iconIds: $0) }
                .flatMap { self.downloadIcons($0) }
                .flatMap { resultTo in
                    self.profileRepository.getActiveProfile()
                        .map { resultTo.changing(path: \.profile, to: $0) }
                }
                .map { self.storeIcons($0) }
        }
        
        private func downloadIcons(_ resultTo: ResultTo) -> Observable<ResultTo> {
            let limitedSize = Array(resultTo.iconIds.prefix(iconsLimitPerRequest))
            return suplaCloudService.getUserIcons(limitedSize.map { $0.id })
                .map { icons in
                    let needsRepetition = resultTo.iconIds.count > iconsLimitPerRequest
                    return resultTo.changing(path: \.icons, to: icons)
                        .changing(path: \.result, to: needsRepetition ? Result.repeat : Result.finished)
                }
        }
        
        private func storeIcons(_ resultTo: ResultTo) -> Result {
            guard let profile = resultTo.profile else { return .error }
            
            let idToSubjectTypeMap = resultTo.iconIds.reduce(into: [Int32: UserIconData]()) { $0[$1.id] = $1 }
            SALog.debug("Got \(resultTo.icons.count) icons to download")
            for icon in resultTo.icons {
                for type in UserIcons.IconType.allCases {
                    storeIcon(type, icon, profile)
                }
                
                emitUpdateEvents(idToSubjectTypeMap[icon.id])
            }
                
            return resultTo.result
        }
        
        private func storeIcon(
            _ type: UserIcons.IconType,
            _ icon: SuplaCloudClient.UserIcon,
            _ profile: AuthProfileItem
        ) {
            if let imageData = type.getData(at: type.index, from: icon.images, orFrom: icon.imagesDark) {
                SALog.debug("Storing image with id \(icon.id) of type \(type)")
                userIconsUseCase.storeIconData(imageData, profileId: profile.id, iconId: icon.id, type: type)
            }
        }
        
        private func emitUpdateEvents(_ userIcon: UserIconData?) {
            if let userIcon {
                switch (userIcon.subjectType) {
                case .channel: updateEventsManager.emitChannelUpdate(remoteId: Int(userIcon.subjectId))
                case .group: updateEventsManager.emitGroupUpdate(remoteId: Int(userIcon.subjectId))
                case .scene: updateEventsManager.emitSceneUpdate(sceneId: Int(userIcon.subjectId))
                }
            }
        }
    }
    
    enum Result {
        case error
        case finished
        case `repeat`
    }
    
    struct ResultTo: Changeable {
        var iconIds: [UserIconData] = []
        var icons: [SuplaCloudClient.UserIcon] = []
        var result: Result = .error
        var profile: AuthProfileItem? = nil
    }
}
