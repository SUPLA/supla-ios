//
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

protocol DisconnectUseCase {
    func invoke(reason: SuplaAppState.Reason?) -> Completable
    func invokeSynchronous(reason: SuplaAppState.Reason?)
}

extension DisconnectUseCase {
    func invoke() -> Completable {
        self.invoke(reason: nil)
    }
    
    func invokeSynchronous() {
        invokeSynchronous(reason: nil)
    }
}

final class DisconnectUseCaseImpl: DisconnectUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<SuplaAppProvider> private var suplaAppProvider
    @Singleton<UpdateEventsManager> private var updateEventsManager
    
    func invoke(reason: SuplaAppState.Reason? = nil) -> Completable {
        Completable.create { completable in
            self.invokeSynchronous(reason: reason)
            
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func invokeSynchronous(reason: SuplaAppState.Reason? = nil) {
        let suplaApp = suplaAppProvider.provide()
        
        if (suplaApp.isClientWorking()) {
            let suplaClient = suplaClientProvider.provide()
            suplaClient.cancel(reason: reason)
            
            while (!suplaClient.isFinished()) {
                usleep(1000)
            }
        }
        
        suplaApp.cancelAllRestApiClientTasks()
        suplaAppProvider.revokeOAuthToken()
        
        updateEventsManager.cleanup()
        updateEventsManager.emitChannelsUpdate()
        updateEventsManager.emitGroupsUpdate()
        updateEventsManager.emitScenesUpdate()
    }
}

@objc class DisconnectUseCaseLegacyWrapper: NSObject {
    @objc static func cancelWithAddWizardStartedReason() {
        @Singleton var disconnectUseCase: DisconnectUseCase
        disconnectUseCase.invokeSynchronous(reason: .addWizardStarted)
    }
}
