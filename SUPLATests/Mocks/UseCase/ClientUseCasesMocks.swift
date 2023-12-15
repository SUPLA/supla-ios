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
import RxSwift

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
