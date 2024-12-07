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
@testable import SUPLA

extension XCTestCase {
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
        
        // arrange
        let expectation = expectation(description: "expectingFatalError")
        var assertionMessage: String? = nil
        
        // override fatalError. This will pause forever when fatalError is called.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            unreachable()
        }
        
        // act, perform on separate thead because a call to fatalError pauses forever
        DispatchQueue.global(qos: .userInitiated).async {
            testcase()
        }
        
        waitForExpectations(timeout: 2) { _ in
            // assert
            XCTAssertEqual(assertionMessage, expectedMessage)
            
            // clean up
            FatalErrorUtil.restoreFatalError()
        }
    }
    
    func XCTAssertTuple<A: Equatable, B: Equatable>(_ first: (A, B), _ second : (A, B)) {
        XCTAssertEqual(first.0, second.0)
        XCTAssertEqual(first.1, second.1)
    }
    
    func XCTAssertTuple<A: Equatable, B: Equatable, C: Equatable>(_ first: (A, B, C), _ second : (A, B, C)) {
        XCTAssertEqual(first.0, second.0)
        XCTAssertEqual(first.1, second.1)
        XCTAssertEqual(first.2, second.2)
    }
    
    func XCTAssertTuple<A: Equatable, B: Equatable, C: Equatable, D:Equatable>(_ first: (A, B, C, D), _ second : (A, B, C, D)) {
        XCTAssertEqual(first.0, second.0)
        XCTAssertEqual(first.1, second.1)
        XCTAssertEqual(first.2, second.2)
        XCTAssertEqual(first.3, second.3)
    }
    
    func XCTAssertTuple<A: Equatable, B: Equatable, C: Equatable, D:Equatable, E: Equatable>(_ first: (A, B, C, D, E), _ second : (A, B, C, D, E)) {
        XCTAssertEqual(first.0, second.0)
        XCTAssertEqual(first.1, second.1)
        XCTAssertEqual(first.2, second.2)
        XCTAssertEqual(first.3, second.3)
        XCTAssertEqual(first.4, second.4)
    }
    
    func XCTAssertTuple<A: Equatable, B: Equatable, C: Equatable, D:Equatable, E: Equatable, F: Equatable>(_ first: (A, B, C, D, E, F), _ second : (A, B, C, D, E, F)) {
        XCTAssertEqual(first.0, second.0)
        XCTAssertEqual(first.1, second.1)
        XCTAssertEqual(first.2, second.2)
        XCTAssertEqual(first.3, second.3)
        XCTAssertEqual(first.4, second.4)
        XCTAssertEqual(first.5, second.5)
    }
    
    func XCTAssertTuples<A: Equatable, B: Equatable>(_ first: [(A, B)], _ second: [(A, B)]) {
        XCTAssertEqual(first.count, second.count)
        for i in 0..<first.count {
            XCTAssertTuple(first[i], second[i])
        }
    }
    
    func XCTAssertTuples<A: Equatable, B: Equatable, C: Equatable>(_ first: [(A, B, C)], _ second: [(A, B, C)]) {
        XCTAssertEqual(first.count, second.count)
        for i in 0..<first.count {
            XCTAssertTuple(first[i], second[i])
        }
    }
    
    func XCTAssertTuples<A: Equatable, B: Equatable, C: Equatable, D: Equatable>(_ first: [(A, B, C, D)], _ second: [(A, B, C, D)]) {
        XCTAssertEqual(first.count, second.count)
        for i in 0..<first.count {
            XCTAssertTuple(first[i], second[i])
        }
    }
    
    func XCTAssertTuples<A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable>(_ first: [(A, B, C, D, E)], _ second: [(A, B, C, D, E)]) {
        XCTAssertEqual(first.count, second.count)
        for i in 0..<first.count {
            XCTAssertTuple(first[i], second[i])
        }
    }
    
    func XCTAssertTuples<A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable>(_ first: [(A, B, C, D, E, F)], _ second: [(A, B, C, D, E, F)]) {
        XCTAssertEqual(first.count, second.count)
        for i in 0..<first.count {
            XCTAssertTuple(first[i], second[i])
        }
    }
    
    func XCTAssertAwait(timeout: TimeInterval, condition: () -> Bool, sleepTimeMs: Double = 0.001, test: () -> Void) {
        let endTime = Date().timeIntervalSince1970 + timeout
        
        while (endTime > Date().timeIntervalSince1970) {
            if (condition()) {
                test()
                return
            }
            Thread.sleep(forTimeInterval: sleepTimeMs)
        }
        
        XCTFail("Time is up!")
    }
}
