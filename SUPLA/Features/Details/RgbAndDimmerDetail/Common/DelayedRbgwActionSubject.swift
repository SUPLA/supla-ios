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

protocol DelayedRgbwActionSubject {
    func emit(data: RgbwActionData)
    func sendImmediately(data: RgbwActionData) -> Observable<RequestResult>
}

final class DelayedRgbwActionSubjectImpl: DelayedCommandSubject<RgbwActionData>, DelayedRgbwActionSubject {
    
    @Singleton private var executeRgbActionUseCase: ExecuteRgbAction.UseCase
    
    init() {
        super.init(mode: .sample, delay: .milliseconds(250))
    }
    
    override func execute(data: RgbwActionData) -> Observable<RequestResult> {
        SALog.debug("Executing delayed RGBW action with \(data)")
        
        return executeRgbActionUseCase.invoke(
            type: data.type,
            remoteId: data.remoteId,
            brightness: data.brightness,
            color: data.color,
            onOff: false,
            vibrate: false,
            dimmerCct: data.dimmerCct
        )
    }
    
}

struct RgbwActionData: DelayableData, Equatable {
    let remoteId: Int32
    let type: SubjectType
    let brightness: Int
    let color: HsvColor
    let dimmerCct: Int
    var sent: Bool = false
    
    
    func sentState() -> DelayableData {
        var copy = self
        copy.sent = true
        return copy
    }
}
