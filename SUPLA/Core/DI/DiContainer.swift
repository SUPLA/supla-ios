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

import SharedCore
import Foundation

protocol DiContainerProtocol {
    func register<Component>(type: Component.Type, _ component: Any)
    func resolve<Component>(type: Component.Type) -> Component?
}

@objc
final class DiContainer: NSObject, DiContainerProtocol {
    static let shared = DiContainer()
    
    override private init() {}
    
    var components: [String: Any] = [:]
    var producers: [String: () -> Any] = [:]
    
    func register<Component>(type: Component.Type, _ component: Any) {
        if (!(component is Component)) {
            fatalError("Registered component (type: `\(String(reflecting: type))` does not implement defined protocol")
        }
        let typeName = String(reflecting: type)
        components[typeName] = component
    }
    
    func register<Component>(type: Component.Type, producer: @escaping () -> Any) {
        let typeName = String(reflecting: type)
        producers[typeName] = producer
    }
    
    func resolve<Component>(type: Component.Type) -> Component? {
        let typeName = String(reflecting: type)
        return components[typeName] as? Component
    }
    
    func producer<Component>(type: Component.Type) -> Component? {
        let typeName = String(reflecting: type)
        if let producer = producers[typeName] {
            return producer() as? Component
        }
        
        return nil
    }
}
