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

protocol DelayedThermostatActionSubject {
    func emit(data: ThermostatActionData)
    func sendImmediately(data: ThermostatActionData) -> Observable<RequestResult>
}

final class DelayedThermostatActionSubjectImpl: DelayedCommandSubject<ThermostatActionData>, DelayedThermostatActionSubject {
    
    @Singleton<ExecuteThermostatActionUseCase> private var executeThermostatActionUseCase
    
    override func execute(data: ThermostatActionData) -> Observable<RequestResult> {
        NSLog("Executing delayed thermostat action with \(data)")
        
        return executeThermostatActionUseCase.invoke(
            type: .channel,
            remoteId: data.remoteId,
            mode: data.mode,
            setpointTemperatureHeat: data.setpointHeat,
            setpointTemperatureCool: data.setpointCool,
            durationInSec: data.durationInSec
        )
    }
    
}

struct ThermostatActionData: DelayableData {
    let remoteId: Int32
    var mode: SuplaHvacMode? = nil
    var setpointHeat: Float? = nil
    var setpointCool: Float? = nil
    var durationInSec: Int32? = nil
    var sent: Bool = false
    
    
    func sentState() -> DelayableData {
        var copy = self
        copy.sent = true
        return copy
    }
}
