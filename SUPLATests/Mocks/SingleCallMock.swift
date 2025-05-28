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

final class SingleCallMock: SingleCall {
    
    var registerPushTokenCalls = 0
    func registerPushToken(_ authorizationEntity: SingleCallAuthorizationEntity, _ protocolVersion: Int32, _ tokenDetails: TCS_PnClientToken) throws {
        registerPushTokenCalls += 1
    }
    
    func executeAction(_ action: SUPLA.Action, subjectType: SUPLA.SubjectType, subjectId: Int32, authorizationEntity: SingleCallAuthorizationEntity) throws {
    }
    
    var getValueMock: FunctionMock<(Int32, SUPLA.SingleCallAuthorizationEntity), SUPLA.SingleCallResult> = .init()
    func getValue(channelId: Int32, authorizationEntity: SUPLA.SingleCallAuthorizationEntity) -> SUPLA.SingleCallResult {
        getValueMock.handle((channelId, authorizationEntity))
    }
}
