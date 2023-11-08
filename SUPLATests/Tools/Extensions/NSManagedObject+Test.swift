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

var sharedTestContext: NSManagedObjectContext = {
    let container = NSPersistentContainer(name: "SUPLA")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
        if let error = error {
            fatalError("Failed to load store for test: \(error)")
        }
    }
    return container.newBackgroundContext()
}()

public extension NSManagedObject {
    convenience init(testContext: NSManagedObjectContext?) {
        let context = testContext ?? sharedTestContext
        var name = String(describing: type(of: self))
        if (name == "_SALocation") {
            name = "SALocation"
        }
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
