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

import RxSwift
import SharedCore
@testable import SUPLA

final class ExecuteSimpleActionUseCaseMock: ExecuteSimpleActionUseCase {
    var returns: Observable<Void> = Observable.empty()
    var parameters: [(Action, SUPLA.SubjectType, Int32)] = []
    func invoke(action: Action, type: SUPLA.SubjectType, remoteId: Int32) -> Observable<Void> {
        parameters.append((action, type, remoteId))
        return returns
    }
}

final class ExecuteThermostatActionUseCaseMock: ExecuteThermostatActionUseCase {
    var parameters: [(SUPLA.SubjectType, Int32, SuplaHvacMode?, Float?, Float?, Int32?)] = []
    var returns: Observable<RequestResult> = .empty()
    func invoke(
        type: SUPLA.SubjectType,
        remoteId: Int32,
        mode: SuplaHvacMode?,
        setpointTemperatureHeat: Float?,
        setpointTemperatureCool: Float?,
        durationInSec: Int32?
    ) -> Observable<RequestResult> {
        parameters.append((type, remoteId, mode, setpointTemperatureHeat, setpointTemperatureCool, durationInSec))
        return returns
    }
}

final class ExecuteRollerShutterActionUseCaseMock: ExecuteRollerShutterActionUseCase {
    var parameters: [(Action, SUPLA.SubjectType, Int32, CGFloat)] = []
    var returns: Completable = .empty()
    func invoke(action: Action, type: SUPLA.SubjectType, remoteId: Int32, percentage: CGFloat) -> Completable {
        parameters.append((action, type, remoteId, percentage))
        return returns
    }
}

final class CallSuplaClientOperationUseCaseMock: CallSuplaClientOperationUseCase {
    var parameters: [(Int32, SUPLA.SubjectType, SuplaClientOperation)] = []
    var returns: Completable = .empty()
    func invoke(remoteId: Int32, type: SUPLA.SubjectType, operation: SuplaClientOperation) -> Completable {
        parameters.append((remoteId, type, operation))
        return returns
    }
}

final class ExecuteFacadeBlindActionUseCaseMock: ExecuteFacadeBlindActionUseCase {
    var parameters: [(Action, SUPLA.SubjectType, Int32, CGFloat, CGFloat)] = []
    var returns: Completable = .empty()
    func invoke(action: Action, type: SUPLA.SubjectType, remoteId: Int32, position: CGFloat, tilt: CGFloat) -> Completable {
        parameters.append((action, type, remoteId, position, tilt))
        return returns
    }
    
    
}

final class AuthorizeUseCaseMock: AuthorizeUseCase {
    var parameters: [(String, String)] = []
    var returns: Completable = .empty()
    func invoke(userName: String, password: String) -> Completable {
        parameters.append((userName, password))
        return returns
    }
}

final class DisconnectUseCaseMock: DisconnectUseCase {
    var invokeCounter = 0
    var invokeReturns: Completable = .empty()
    func invoke(reason: SuplaAppState.Reason?) -> Completable {
        invokeCounter += 1
        return invokeReturns
    }
    
    var invokeSynchronousCounter = 0
    func invokeSynchronous(reason: SuplaAppState.Reason?) {
        invokeSynchronousCounter += 1
    }
}

final class ReconnectUseCaseMock: ReconnectUseCase {
    var invokeCounter = 0
    var returns: Completable = .empty()
    func invoke() -> Completable {
        invokeCounter += 1
        return returns
    }
}
