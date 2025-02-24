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
    
    func provide() -> SuplaClientProtocol? { suplaClientMock }
    
    func forcedProvide() -> any SuplaClientProtocol { suplaClientMock }
}

class SuplaClientProtocolMock: NSObject, SuplaClientProtocol {
    
    var cancelCalls: Int = 0
    func cancel() { cancelCalls += 1 }
    
    var reconnectCalls: Int = 0
    func reconnect() { reconnectCalls += 1 }
    
    var isCancelledCalls = 0
    var isCancelledReturns = false
    func isCancelled() -> Bool {
        isCancelledCalls += 1
        return isCancelledReturns
    }
    
    var isFinishedCalls = 0
    var isFinishedReturns = false
    func isFinished() -> Bool {
        isFinishedCalls += 1
        return isFinishedReturns
    }
    
    var executeActionParameters: [(Int32, Int32, Int32, UnsafeMutableRawPointer?, Int32)] = []
    var executeActionReturns = false
    func executeAction(_ actionId: Int32, subjecType subjectType: Int32, subjectId: Int32, parameters: UnsafeMutableRawPointer!, length: Int32) -> Bool {
        // As the parametets memory is fried after end of the execute action we need to make
        // a copy of it to assert values inside the object
        var parametersCopy: UnsafeMutableRawPointer? = nil
        if (parameters != nil) {
            parametersCopy = UnsafeMutableRawPointer.allocate(byteCount: Int(length), alignment: MemoryLayout<UInt8>.alignment)
            parametersCopy?.copyMemory(from: parameters, byteCount: Int(length))
        }
        
        executeActionParameters.append((actionId, subjectType, subjectId, parametersCopy, length))
        return executeActionReturns
    }
    
    var timerArmParameters: [(Int32, Bool, Int32)] = []
    var timerArmReturns = false
    func timerArm(for remoteId: Int32, withTurnOn on: Bool, withTime milis: Int32) -> Bool {
        timerArmParameters.append((remoteId, on, milis))
        return timerArmReturns
    }
    
    var getChannelConfigParameters: [UnsafeMutablePointer<TCS_GetChannelConfigRequest>] = []
    var getChannelConfigReturns = false
    func getChannelConfig(_ configRequest: UnsafeMutablePointer<TCS_GetChannelConfigRequest>!) -> Bool {
        // As the parametets memory is fried after end of the execute action we need to make
        // a copy of it to assert values inside the object
        let configRequestCopy = UnsafeMutablePointer<TCS_GetChannelConfigRequest>.allocate(capacity: 1)
        configRequestCopy.update(from: configRequest, count: 1)
        getChannelConfigParameters.append(configRequestCopy)
        
        return getChannelConfigReturns
    }
    
    var setChannelConfigParameters: [UnsafeMutablePointer<TSCS_ChannelConfig>] = []
    var setChannelConfigReturns = false
    func setChannelConfig(_ config: UnsafeMutablePointer<TSCS_ChannelConfig>!) -> Bool {
        // As the parametets memory is fried after end of the execute action we need to make
        // a copy of it to assert values inside the object
        let configRequestCopy = UnsafeMutablePointer<TSCS_ChannelConfig>.allocate(capacity: 1)
        configRequestCopy.update(from: config, count: 1)
        setChannelConfigParameters.append(configRequestCopy)
        
        return setChannelConfigReturns
    }
    
    var oAuthTokenRequestCalls = 0
    var oAuthTokenRequestReturns = false
    func oAuthTokenRequest() -> Bool {
        oAuthTokenRequestCalls += 1
        return oAuthTokenRequestReturns
    }
    
    var getDeficeConfigParameters: [UnsafeMutablePointer<TCS_GetDeviceConfigRequest>] = []
    var getDeviceConfigReturns = false
    func getDeviceConfig(_ configRequest: UnsafeMutablePointer<TCS_GetDeviceConfigRequest>!) -> Bool {
        let configRequestCopy = UnsafeMutablePointer<TCS_GetDeviceConfigRequest>.allocate(capacity: 1)
        configRequestCopy.update(from: configRequest, count: 1)
        getDeficeConfigParameters.append(configRequestCopy)
        
        return getDeviceConfigReturns
    }
    
    var cgParameters: [(Int32, CChar, Bool)] = []
    var cgReturns: Bool = false
    func cg(_ ID: Int32, open: CChar, group: Bool) -> Bool {
        cgParameters.append((ID, open, group))
        return cgReturns
    }
    
    var deviceCalCfgCommandParameters: [(Int32, Int32, Bool)] = []
    var deviceCalCfgCommandReturns: Bool = false
    func deviceCalCfgCommand(_ command: Int32, cg ID: Int32, group: Bool) -> Bool {
        deviceCalCfgCommandParameters.append((command, ID, group))
        return deviceCalCfgCommandReturns
    }
    
    var isRegisteredCalls = 0
    var isRegisteredReturns = false
    func isRegistered() -> Bool {
        isRegisteredCalls += 1
        return isRegisteredReturns
    }
    
    var isSuperuserAuthorizedCalls = 0
    var isSuperuserAuthorizedReturns = false
    func isSuperuserAuthorized() -> Bool {
        isSuperuserAuthorizedCalls += 1
        return isSuperuserAuthorizedReturns
    }
    
    var superuserAuthorizationRequestParameters: [(String, String)] = []
    func superuserAuthorizationRequest(withEmail email: String!, andPassword password: String!) {
        superuserAuthorizationRequestParameters.append((email, password))
    }
    
    var getServerTimeDiffInSecMock: FunctionMock<Void, Int32> = .init()
    func getServerTimeDiffInSec() -> Int32 {
        getServerTimeDiffInSecMock.handle(())
    }
    
    func channelStateRequest(withChannelId channelId: Int32) {
    }
}
