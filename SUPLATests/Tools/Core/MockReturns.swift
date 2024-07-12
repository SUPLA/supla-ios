//
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
    


class MockReturns<T> {
    
    private let values: [T]
    private let empty: Bool
    private var idx = 0
    
    private init(values: [T]) {
        self.values = values
        self.empty = false
    }
    
    private init() {
        self.values = []
        self.empty = true
    }
    
    func next() -> T {
        if (empty) {
            fatalError("Not mocked!")
        }
        
        if (idx >= values.count) {
            return values.last!
        }
        
        let returns = values[idx]
        idx += 1
        return returns
    }
    
    static func single<V>(_ value: V) -> MockReturns<V> {
        MockReturns<V>(values: [value])
    }
    
    static func many<V>(_ values: [V]) -> MockReturns<V> {
        MockReturns<V>(values: values)
    }
    
    static func empty<V>() -> MockReturns<V> {
        MockReturns<V>()
    }
}
