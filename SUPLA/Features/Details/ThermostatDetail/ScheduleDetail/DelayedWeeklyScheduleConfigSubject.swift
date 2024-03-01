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

protocol DelayedWeeklyScheduleConfigSubject {
    func emit(data: WeeklyScheduleConfigData)
    func sendImmediately(data: WeeklyScheduleConfigData) -> Observable<RequestResult>
}

final class DelayedWeeklyScheduleConfigSubjectImpl: DelayedCommandSubject<WeeklyScheduleConfigData>, DelayedWeeklyScheduleConfigSubject {
    
    @Singleton<SetChannelConfigUseCase> private var setChannelConfigUseCase
    
    override func execute(data: WeeklyScheduleConfigData) -> Observable<RequestResult> {
        SALog.debug("Executing delayed weekly schedule config with \(data)")
        
        return setChannelConfigUseCase.invoke(
            remoteId: data.remoteId,
            config: SuplaChannelWeeklyScheduleConfig(
                remoteId: data.remoteId,
                channelFunc: nil,
                programConfigurations: data.programs,
                schedule: data.schedule
            )
        )
    }
}

struct WeeklyScheduleConfigData: DelayableData, Equatable {
    let remoteId: Int32
    let programs: [SuplaWeeklyScheduleProgram]
    let schedule: [SuplaWeeklyScheduleEntry]
    var sent: Bool = false
    
    func sentState() -> DelayableData {
        var copy = self
        copy.sent = true
        return copy
    }
}
