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

import UIKit
import RxCocoa
import RxSwift
import RxRelay
import RxDataSources
import CoreData

class ProfilesVM {
    
    struct Inputs {
        var onActivate: Observable<ProfileID>
        var onEdit: Observable<ProfileID>
        var onAddNew: Observable<Void>
    }
    
    let reloadTrigger = PublishSubject<Void>()
    let dismissTrigger = PublishSubject<Void>()
    let openProfileTrigger = PublishSubject<ProfileID?>()

    let profileItems = BehaviorRelay<[ProfileListItem]>(value: [])
    
    private let _profileManager: ProfileManager
    private let _disposeBag = DisposeBag()
    
    init(profileManager: ProfileManager) {
        _profileManager = profileManager

        reloadProfiles()
        
        reloadTrigger.subscribe { [weak self]  _ in
            self?.reloadProfiles()
        }.disposed(by: _disposeBag)
    }
    
    func bind(inputs: Inputs) {
        inputs.onAddNew.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.openProfileTrigger.on(.next(nil))
            
        }.disposed(by: _disposeBag)

        inputs.onEdit.subscribe { [weak self] profileID in
            guard let self = self,
                  let profileID = profileID.element else { return }
          self.openProfileTrigger.on(.next(profileID))
        }.disposed(by: _disposeBag)

        inputs.onActivate.subscribe { [weak self] id in
            guard let self = self, let id = id.element else { return }

            if self._profileManager.activateProfile(id: id, force: false) {
                self.dismissTrigger.on(.next(()))
            }
        }.disposed(by: _disposeBag)
    }
                        
    private func reloadProfiles() {
        profileItems.accept(_profileManager.getAllProfiles()
            .map { ProfileListItem.profileItem(id: $0.objectID,
                                               name: $0.displayName,
                                               isActive: $0.isActive) })

    }
}


enum ProfileListItem {
    case profileItem(id: ProfileID, name: String, isActive: Bool)
    case addNewProfileItem
}

enum ProfilesListModel {
    case profileSection(items: [ProfileListItem])
    case commandSection(items: [ProfileListItem])
}


extension ProfilesListModel: SectionModelType {
    typealias Item = ProfileListItem

    init(original: ProfilesListModel, items: [Item]) {
        switch original {
        case .profileSection(items: _):
            self = .profileSection(items: items)
        case .commandSection(items: _):
            self = .commandSection(items: items)
        }
    }
    
    var items: [ProfileListItem] {
        switch self {
        case .profileSection(items: let items):
            return items
        case .commandSection(items: let items):
            return items
        }
    }
}


