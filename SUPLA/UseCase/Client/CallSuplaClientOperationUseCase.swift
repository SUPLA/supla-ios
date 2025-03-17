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

protocol CallSuplaClientOperationUseCase {
    func invoke(remoteId: Int32, type: SubjectType, operation: SuplaClientOperation) -> Completable
}

final class CallSuplaClientOperationUseCaseImpl: CallSuplaClientOperationUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<VibrationService> private var vibrationService
    
    func invoke(remoteId: Int32, type: SubjectType, operation: SuplaClientOperation) -> Completable {
        Completable.create { completable in
            
            if (self.performOperation(remoteId, type, operation)) {
                self.vibrationService.vibrate()
            }
            
            completable(.completed)
            return Disposables.create()
        }
    }
    
    
    private func performOperation(_ remoteId: Int32, _ type: SubjectType, _ operation: SuplaClientOperation) -> Bool {
        let client = suplaClientProvider.provide()
        switch(operation) {
        case .moveUp: 
            return client?.cg(remoteId, open: 2, group: type.isGroup) == true
        case .moveDown:
            return client?.cg(remoteId, open: 1, group: type.isGroup) == true
        case .recalibrate:
            return client?.deviceCalCfgCommand(SUPLA_CALCFG_CMD_RECALIBRATE, cg: remoteId, group: type.isGroup) == true
        case .muteAlarmSound:
            return client?.deviceCalCfgCommand(SUPLA_CALCFG_CMD_MUTE_ALARM_SOUND, cg: remoteId, group: type.isGroup) == true
        }
    }
    
}

enum SuplaClientOperation {
    case moveUp
    case moveDown
    case recalibrate
    case muteAlarmSound
}
