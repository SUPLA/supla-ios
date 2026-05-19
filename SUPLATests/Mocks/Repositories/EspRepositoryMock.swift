/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can freely redistribute it and/or
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

import Collections

@testable import SUPLA

final class EspRepositoryMock: EspRepository {
    var getMock: FunctionMock<Void, Esp.RequestResult> = .init()
    func get() async -> Esp.RequestResult {
        getMock.handle(())
    }

    var postMock: FunctionMock<OrderedDictionary<String, String>, Esp.RequestResult> = .init()
    func post(_ data: OrderedDictionary<String, String>) async -> Esp.RequestResult {
        postMock.handle(data)
    }

    var loginMock: FunctionMock<Void, Esp.RequestResult> = .init()
    func login() async -> Esp.RequestResult {
        loginMock.handle(())
    }

    var loginWithPasswordMock: FunctionMock<(String, OrderedDictionary<String, String>), Esp.RequestResult> = .init()
    func login(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult {
        loginWithPasswordMock.handle((password, fieldsMap))
    }

    var setupMock: FunctionMock<Void, Esp.RequestResult> = .init()
    func setup() async -> Esp.RequestResult {
        setupMock.handle(())
    }

    var setupWithPasswordMock: FunctionMock<(String, OrderedDictionary<String, String>), Esp.RequestResult> = .init()
    func setup(password: String, fieldsMap: inout OrderedDictionary<String, String>) async -> Esp.RequestResult {
        setupWithPasswordMock.handle((password, fieldsMap))
    }
}
