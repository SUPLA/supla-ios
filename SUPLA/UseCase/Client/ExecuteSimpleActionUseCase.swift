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

protocol ExecuteSimpleActionUseCase {
    func invoke(action: Action, type: SubjectType, remoteId: Int32) -> Observable<Void>
}

final class ExecuteSimpleActionUseCaseImpl: ExecuteSimpleActionUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<VibrationService> private var vibrationService
    
    func invoke(action: Action, type: SubjectType, remoteId: Int32) -> Observable<Void> {
        Observable.create { observer in
            SALog.debug("Executing action \(action) for \(type) with remoteId \(remoteId)")
            
            let suplaClient = self.suplaClientProvider.provide()
            let result = suplaClient?.executeAction(
                parameters: .simple(action: action, subjectType: type, subjectId: remoteId)
            )
            
            if (result == true) {
                self.vibrationService.vibrate()
            }
            
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
