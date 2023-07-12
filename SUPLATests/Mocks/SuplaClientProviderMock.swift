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


@testable import SUPLA

class SuplaClientProviderMock: SuplaClientProvider {
    var suplaClientMock = SuplaClientProtocolMock()
    
    func provide() -> SuplaClientProtocol { suplaClientMock }
}

class SuplaClientProtocolMock: NSObject, SuplaClientProtocol {
    
    var cancelCalls: Int = 0
    func cancel() { cancelCalls += 1 }
    
    var reconnectCalls: Int = 0
    func reconnect() { reconnectCalls += 1 }
    
    var executeActionReturns = false
    func executeAction(_ actionId: Int32, subjecType subjectType: Int32, subjectId: Int32, rsParameters: UnsafeMutablePointer<TAction_RS_Parameters>!, rgbwParameters: UnsafeMutablePointer<TAction_RGBW_Parameters>!) -> Bool {
        executeActionReturns
    }
    
    var timerArmReturns = false
    func timerArm(for remoteId: Int32, withTurnOn on: Bool, withTime milis: Int32) -> Bool {
        timerArmReturns
    }
}
