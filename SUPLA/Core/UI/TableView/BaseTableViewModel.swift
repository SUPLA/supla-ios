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
import RxCocoa
import RxDataSources

class BaseTableViewModel<S : ViewState, E : ViewEvent>: BaseViewModel<S, E> {
    
    let listItems = BehaviorRelay<[List]>(value: [])
    
    @Singleton<ToggleLocationUseCase> private var toggleLocationUseCase
    
    func toggleLocation(remoteId: Int) {
        toggleLocationUseCase.invoke(remoteId: remoteId, collapsedFlag: getCollapsedFlag())
            .subscribe(onNext: { self.reloadTable() })
            .disposedBy(self)
    }
    
    func reloadTable() {
        fatalError("reloadTable() has not been implemented")
    }
    
    func getCollapsedFlag() -> CollapsedFlag {
        fatalError("getCollapsedFlag() has not been implemented")
    }
}

enum List {
    case list(items: [ListItem])
}

enum ListItem {
    case location(location: _SALocation)
    case scene(scene: SAScene)
    case channelBase(channelBase: SAChannelBase)
}

extension List : SectionModelType {
    typealias Item = ListItem
    
    var items: [ListItem] {
        switch self {
        case .list(let items):
            return items.map { $0 }
        }
    }
    
    init(original: List, items: [ListItem]) {
        switch original {
        case .list:
            self = .list(items: items)
        }
    }
}
