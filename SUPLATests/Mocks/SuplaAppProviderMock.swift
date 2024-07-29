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
    

@testable import SUPLA

class SuplaAppProviderMock: SuplaAppProvider {
    var suplaAppMock = SuplaAppApiMock()
    
    func provide() -> SuplaAppApi { suplaAppMock }
    
    var revokeOAuthTokenCalls = 0
    func revokeOAuthToken() {
        revokeOAuthTokenCalls += 1
    }
    
    var initClientWithOneTimePasswordParameters: [String] = []
    func initClientWithOneTimePassword(_ password: String) {
        initClientWithOneTimePasswordParameters.append(password)
    }
    
    var initSuplaClientCalls = 0
    func initSuplaClient() {
        initSuplaClientCalls += 1
    }
    
    
}

class SuplaAppApiMock: NSObject, SuplaAppApi {
    
    var cancelAllRestApiClientTasksCalls = 0
    func cancelAllRestApiClientTasks() {
        cancelAllRestApiClientTasksCalls += 1
    }
    
    var isClientRegisteredCalls = 0
    var isClientRegisteredReturns = false
    func isClientRegistered() -> Bool {
        isClientRegisteredCalls += 1
        return isClientRegisteredReturns
    }
    
    var isClientWorkingCalls = 0
    var isClientWorkingReturns = false
    func isClientWorking() -> Bool {
        isClientWorkingCalls += 1
        return isClientWorkingReturns
    }
    
    var isClientAuthorizedCalls = 0
    var isClientAuthroziedReturns = false
    func isClientAuthorized() -> Bool {
        isClientAuthorizedCalls += 1
        return isClientAuthroziedReturns
    }
    
}
