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

class ProfilesVM {
    
    struct Inputs {
        var onActivate: Observable<Int>
        var onEdit: Observable<Int>
        var onAddNew: Observable<Void>
    }
    
    private let _profileManager: ProfileManager
    private let _disposeBag = DisposeBag()
    
    init(profileManager: ProfileManager) {
        _profileManager = profileManager
    }
    
    func bind(inputs: Inputs) {
        inputs.onAddNew.subscribe { _ in
            // TODO: create new profile and open editor
            print("triggering new item")
        }.disposed(by: _disposeBag)

        inputs.onEdit.subscribe { id in
            print("will edit profile: \(id)")
        }.disposed(by: _disposeBag)

        inputs.oActivate.subscribe { id in
            print("will activate profile: \(id)")
        }
    }
}


enum ProfileListItem {
    case profileItem(id: Int, name: String, isActive: Bool)
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


