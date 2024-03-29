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

class SuplaCloudConfigHolderMock: SuplaCloudConfigHolder {
    var token: SAOAuthToken? = nil
    
    var url: String? = nil
    
    var cleanCalls: Int = 0
    func clean() {
        cleanCalls += 1
    }
    
    var requireUrlCalls: Int = 0
    var requireUrlReturns: () throws -> String = { "" }
    func requireUrl() throws -> String {
        requireUrlCalls += 1
        return try requireUrlReturns()
    }
    
    var requireTokenCalls: Int = 0
    var requireTokenReturns: () throws -> SAOAuthToken = { SAOAuthToken() }
    func requireToken() throws -> SAOAuthToken {
        requireTokenCalls += 1
        return try requireTokenReturns()
    }
}
