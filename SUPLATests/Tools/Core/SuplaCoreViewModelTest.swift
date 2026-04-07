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
    
import XCTest
import Combine

@testable import SUPLA

extension SuplaCore {
    class ViewModelTest<S : ObservableObject>: XCTestCase {
        private var cancellables: Set<AnyCancellable> = []
        
        func observe<T>(_ value: Published<T>.Publisher, count: Int) -> ObservationState<T> {
            let state = ObservationState<T>(expectation(description: "ViewModel field changed"))
            
            value.dropFirst()
                .sink { value in
                    state.receivedValues.append(value)
                    if (state.receivedValues.count == count) {
                        state.exp.fulfill()
                    }
                }
                .store(in: &cancellables)
            
            return state
        }
    }
}

class ObservationState<T> {
    let exp: XCTestExpectation
    var receivedValues: [T] = []
    
    init(_ exp: XCTestExpectation) {
        self.exp = exp
    }
}
