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

private let FIRST_STAGE_LOCK_TIME_SECS: TimeInterval = 5
private let SECOND_STAGE_LOCK_TIME_SECS: TimeInterval = 60
private let THIRD_STAGE_LOCK_TIME_SECS: TimeInterval = 300
private let FOURTH_STAGE_LOCK_TIME_SECS: TimeInterval = 600

protocol CheckPinUseCase {
    func invoke(unlockAction: LockScreenFeature.UnlockAction, pinAction: CheckPinAction) -> Single<CheckPinResult>
}

final class CheckPinUseCaseImpl: CheckPinUseCase {
    @Singleton<GlobalSettings> private var settings
    @Singleton<DateProvider> private var dateProvider
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SuplaAppStateHolder> private var stateHandler
    
    func invoke(unlockAction: LockScreenFeature.UnlockAction, pinAction: CheckPinAction) -> Single<CheckPinResult> {
        Single.create { single in
            let lockScreenSettings = self.settings.lockScreenSettings
            
            if (pinAction.inAuthorized(pinSum: lockScreenSettings.pinSum)) {
                self.settings.lockScreenSettings = lockScreenSettings.copy(failsCount: .value(0), lockTime: .value(nil))
                single(.success(.unlocked))
            } else {
                single(.success(self.onWrongPin(lockScreenSettings)))
            }
            
            return Disposables.create()
        }
        .flatMap { self.checkProfileExist(unlockAction, $0) }
    }
    
    private func checkProfileExist(_ unlockAction: LockScreenFeature.UnlockAction, _ result: CheckPinResult) -> Single<CheckPinResult> {
        if (result == .unlocked) {
            profileRepository.getActiveProfile()
                .map { _ in CheckPinResult.unlocked }
                .ifEmpty(switchTo: Observable.just(CheckPinResult.unlockedNoAccount))
                .map { self.performActionSpecificWork(unlockAction, result: $0) }
                .asSingle()
        } else {
            Single.just(result)
        }
    }
    
    private func onWrongPin(_ lockScreenSettings: LockScreenSettings) -> CheckPinResult {
        
        let lockTime = getLockTime(lockScreenSettings)
        settings.lockScreenSettings = lockScreenSettings.copy(
            failsCount: .value(lockScreenSettings.failsCount + 1),
            lockTime: .value(lockTime)
        )
        
        return .failure
    }
    
    private func getLockTime(_ lockScreenSettings: LockScreenSettings) -> TimeInterval? {
        if (lockScreenSettings.failsCount == 5) {
            dateProvider.currentTimestamp() + FIRST_STAGE_LOCK_TIME_SECS
        } else if (lockScreenSettings.failsCount == 10) {
            dateProvider.currentTimestamp() + SECOND_STAGE_LOCK_TIME_SECS
        } else if (lockScreenSettings.failsCount == 15) {
            dateProvider.currentTimestamp() + THIRD_STAGE_LOCK_TIME_SECS
        } else if (lockScreenSettings.failsCount >= 20) {
            dateProvider.currentTimestamp() + FOURTH_STAGE_LOCK_TIME_SECS
        } else {
            lockScreenSettings.lockTime
        }
    }
    
    private func performActionSpecificWork(_ unlockAction: LockScreenFeature.UnlockAction, result: CheckPinResult) -> CheckPinResult {
        switch (unlockAction) {
        case .authorizeApplication:
            if (result == .unlocked) {
                stateHandler.handle(event: .unlock)
            } else if (result == .unlockedNoAccount) {
                stateHandler.handle(event: .noAccount)
            }
        case .turnOffPin:
            settings.lockScreenSettings = LockScreenSettings.DEFAULT
        case .confirmAuthorizeApplication:
            settings.lockScreenSettings = settings.lockScreenSettings.copy(scope: .value(.application))
        case .confirmAuthorizeAccounts:
            settings.lockScreenSettings = settings.lockScreenSettings.copy(scope: .value(.accounts))
        case .authorizeAccountsCreate, .authorizeAccountsEdit: break
        }
        return result
    }
}

enum CheckPinResult {
    case unlocked
    case unlockedNoAccount
    case failure
}

enum CheckPinAction: Equatable {
    case checkPin(pin: String)
    case biometricGranted
    case biometricRejected
    
    func inAuthorized(pinSum: String?) -> Bool {
        switch (self) {
        case .checkPin(let pin): pin.sha1() == pinSum
        case .biometricGranted: true
        case .biometricRejected: false
        }
    }
}
