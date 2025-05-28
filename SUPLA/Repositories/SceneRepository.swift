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

import Foundation
import CoreData
import RxSwift
import RxBlocking

protocol SceneRepository: RepositoryProtocol, CaptionChangeUseCaseImpl.Updater where T == SAScene {
    func getAllVisibleScenes(forProfile profile: AuthProfileItem) -> Observable<[SAScene]>
    func getAllVisibleScenes(forProfileId profileId: Int32) -> Observable<[SAScene]>
    func getAllVisibleScenes(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAScene]>
    func getAllScenes() -> Observable<[SAScene]>
    func getAllScenes(forProfile profile: AuthProfileItem) -> Observable<[SAScene]>
    func getScene(for profile: AuthProfileItem, with sceneId: Int32) -> Observable<SAScene>
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
    func getAllIcons(for profile: AuthProfileItem) -> Observable<[UserIconData]>
}

final class SceneRepositoryImpl: Repository<SAScene>, SceneRepository {

    func getAllVisibleScenes(forProfile profile: AuthProfileItem) -> Observable<[SAScene]> {
        getAllVisibleScenes(forProfileId: profile.id)
    }
    
    func getAllVisibleScenes(forProfileId profileId: Int32) -> Observable<[SAScene]> {
        let fetchRequest = SAScene.fetchRequest()
            .filtered(by: NSPredicate(format: "profile.id = %d AND visible > 0", profileId))
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "location.sortOrder", ascending: true),
            NSSortDescriptor(key: "location.caption", ascending: true),
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "caption", ascending: true),
            NSSortDescriptor(key: "sceneId", ascending: true)
        ]
        return self.query(fetchRequest)
    }
    
    func getAllVisibleScenes(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAScene]> {
        let fetchRequest = SAScene.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@ AND visible > 0 AND location.caption = %@", profile, locationCaption))
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "location.sortOrder", ascending: true),
            NSSortDescriptor(key: "location.caption", ascending: true),
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "caption", ascending: true),
            NSSortDescriptor(key: "sceneId", ascending: true)
        ]
        return self.query(fetchRequest)
    }
    
    func getAllScenes(forProfile profile: AuthProfileItem) -> Observable<[SAScene]> {
        let fetchRequest = SAScene.fetchRequest()
            .filtered(by: NSPredicate(format: "profile = %@", profile))
            .ordered(by: "sceneId")
        
        return self.query(fetchRequest)
    }
    
    func getAllScenes() -> Observable<[SAScene]> {
        return self.query(SAScene.fetchRequest().ordered(by: "sceneId"))
    }
    
    func getScene(for profile: AuthProfileItem, with sceneId: Int32) -> Observable<SAScene> {
        queryItem(NSPredicate(format: "sceneId = %d AND profile = %@", sceneId, profile))
            .compactMap { $0 }
    }
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAScene.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
    
    func getAllIcons(for profile: AuthProfileItem) -> Observable<[UserIconData]> {
        let request = SAScene.fetchRequest()
            .filtered(by: NSPredicate(format: "usericon_id > 0 AND visible > 0 AND profile = %@", profile))
            .ordered(by: "usericon_id")
        
        return query(request)
            .map { scenes in
                var resultSet: Set<UserIconData> = []
                scenes.forEach { resultSet.insert(.sceneIconData($0.usericon_id, sceneId: $0.sceneId)) }
                return Array(resultSet)
            }
    }
    
    func update(caption: String, remoteId: Int32) -> Observable<Void> {
        queryItem(NSPredicate(format: "sceneId = %d AND profile.isActive = 1", remoteId))
            .compactMap { $0 }
            .map {
                $0.caption = caption
                return $0
            }
            .flatMapFirst { self.save($0) }
    }
}
