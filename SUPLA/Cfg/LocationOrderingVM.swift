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
import RxRelay

class LocationOrderingVM {
    struct Inputs {
        let commitChangesTrigger: Observable<Void>
    }
    
    let locations = BehaviorRelay<[_SALocation]>(value: [_SALocation]())
    
    private let _ctx: NSManagedObjectContext
    private let _disposeBag = DisposeBag()
    
    init(managedObjectContext: NSManagedObjectContext) {
        _ctx = managedObjectContext
        locations.accept(try! fetchLocations())
    }

    func bind(inputs: Inputs) {
        inputs.commitChangesTrigger.subscribe { _ in
            self.saveNewOrder()
        }.disposed(by: _disposeBag)
    }
    
    private func fetchLocations() throws -> [_SALocation] {
        let profileManager = MultiAccountProfileManager(context: _ctx)
        
        let fr = _SALocation.fetchRequest()
        fr.predicate = NSPredicate(
            format: "visible = true AND profile = %@",
            profileManager.getCurrentProfile()!
        )
        fr.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(
                key: "caption",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )
        
        ]
        var result = [_SALocation]()
        for location in try _ctx.fetch(fr) {
            result.append(location)
        }
        return result
    }
    
    private func saveNewOrder() {
        var pos = Int16(0)
        for elt in self.locations.value {
            elt.sortOrder = NSNumber(value: pos)
            pos += 1
        }
        if _ctx.hasChanges { try! _ctx.save() }
    }
}
