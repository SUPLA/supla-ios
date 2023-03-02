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
import RxSwift
import RxCocoa

@objc
class ScenesVM: NSObject {

    struct Section {
        var location: _SALocation
        var scenes: [Scene]
    }
    
    struct Inputs {
        var sectionVisibilityToggle: Observable<Int>
    }

    private let _db: SADatabase
    private let _disposeBag = DisposeBag()

    private let _bitCollapse = Int16(0x4)

    var sections = BehaviorRelay<[Section]>(value: [])
    var sectionSorter = PublishSubject<[Section]>()
    
    private var _swipedItemsCounter = 0
    private var _reloadPending = false

    @objc
    init(database: SADatabase) {
        _db = database
        super.init()

        reloadScenes()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadScenes), name: Notification.Name("kSA-N01"), object: nil)
    }
    
    func bind(inputs: Inputs) {
        inputs.sectionVisibilityToggle.subscribe { [weak self] in
            self?.toggleSectionCollapsed($0)
        }.disposed(by: _disposeBag)
        
        sectionSorter.subscribe { [weak self] in
            self?.persistSortedSections($0)
        }.disposed(by: _disposeBag)
    }
    
    func isSectionCollapsed(_ sec: Int) -> Bool {
        return sections.value[sec].location.collapsed & _bitCollapse == _bitCollapse
    }
    
    func openingItem() {
        _swipedItemsCounter = _swipedItemsCounter + 1
    }
    
    func closingItem() {
        _swipedItemsCounter = _swipedItemsCounter - 1
        
        if (_reloadPending) {
            reloadScenes()
        }
        
    }
    
    private func toggleSectionCollapsed(_ sec: Int) {
        sections.value[sec].location.collapsed  ^= _bitCollapse
        reloadScenes()
    }
    
    private func persistSortedSections(_ secs: [Section]) {
        for s in secs {
            var so = Int32(0)
            for scn in s.scenes {
                scn.sortOrder = so
                so += 1
            }
        }
        sections.accept(secs)
    }
    
    @objc private func reloadScenes() {
        if (_swipedItemsCounter > 0) {
            _reloadPending = true
            return
        }
        _reloadPending = false
        
        var loc: _SALocation?
        var locScenes = [Scene]()
        var secs = [Section]()
        var i = 0
        
        let allScenes = _db.fetchScenes()
        
        while i < allScenes.count {
            if loc == nil {
                loc = allScenes[i].location
            }
            if loc!.collapsed & _bitCollapse == 0 {
                locScenes.append(allScenes[i])
            }
            i += 1
            if i == allScenes.count ||
                allScenes[i].location != loc {
                secs.append(Section(location: loc!, scenes: locScenes))
                locScenes = [Scene]()
                loc = nil
            }
        }

        sections.accept(secs)
    }
}
