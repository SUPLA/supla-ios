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

protocol SceneRepository: RepositoryProtocol where T == SAScene {
    func getAllProfileScenes(profile: AuthProfileItem) -> Observable<[SAScene]>
}

final class SceneRepositoryImpl: Repository<SAScene>, SceneRepository {
    
    func getAllProfileScenes(profile: AuthProfileItem) -> Observable<[SAScene]> {
        let fetchRequest = SAScene.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "profile = %@ AND visible > 0", profile)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "location.sortOrder", ascending: true),
            NSSortDescriptor(key: "location.caption", ascending: true),
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "caption", ascending: true),
            NSSortDescriptor(key: "sceneId", ascending: true)
        ]
        return self.query(fetchRequest)
    }
}
