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

protocol ColorListItemRepository: RepositoryProtocol where T == SAColorListItem {
    func find(byRemoteId remoteId: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> Observable<[SAColorListItem]>
    func delete(byRemoteId remoteId: Int32, andIdx idx: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> Observable<Void>
    func deleteUnusedColors(byRemoteId remoteId: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> Observable<Void>
}

final class ColorListItemRepositoryImpl: Repository<SAColorListItem>, ColorListItemRepository {
    func find(byRemoteId remoteId: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> RxSwift.Observable<[SAColorListItem]> {
        let group = subject == .group ? 1 : 0
        let request = SAColorListItem.fetchRequest()
            .filtered(by: NSPredicate(format: "remote_id = %d AND group = %d AND raw_type = %d AND profile.isActive = 1", remoteId, group, type.rawValue))
            .ordered(by: "idx")
        return query(request)
    }
    
    func delete(byRemoteId remoteId: Int32, andIdx idx: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> Observable<Void> {
        let group = subject == .group ? 1 : 0
        return queryItem(NSPredicate(format: "remote_id = %d AND group = %d AND raw_type = %d AND idx = %d AND profile.isActive = 1", remoteId, group, type.rawValue, idx))
            .flatMap {
                if let item = $0 {
                    self.delete(item)
                } else {
                    Observable.just(())
                }
            }
            .flatMap { self.save() }
    }
    
    func deleteUnusedColors(byRemoteId remoteId: Int32, forSubject subject: SubjectType, andType type: ColorListItemType) -> Observable<Void> {
        let group = subject == .group ? 1 : 0
        return deleteAll(
            SAColorListItem.fetchRequest()
                .filtered(by: NSPredicate(format: "remote_id = %d AND group = %d AND raw_type = %d AND profile.isActive = 1 AND color = NULL", remoteId, group, type.rawValue))
        )
    }
}
