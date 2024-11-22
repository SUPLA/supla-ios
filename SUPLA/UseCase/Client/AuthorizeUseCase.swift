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

protocol AuthorizeUseCase {
    func invoke(userName: String, password: String) -> Completable
}

class AuthorizationError: Error {
    let errorMessage: String
    
    init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
}

final class AuthorizeUseCaseImpl: AuthorizeUseCase {
    @Singleton<NotificationCenterWrapper> private var notificationCenterWrapper
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<ThreadHandler> private var threadHandler
    
    func invoke(userName: String, password: String) -> Completable {
        Completable.create { completable in
            var result: AuthorizationMessageObserver.AuthorizationResult? = nil
            
            let observer = AuthorizationMessageObserver()
            observer.resultObserver = { result = $0 }
            self.notificationCenterWrapper.registerObserver(
                observer,
                selector: #selector(observer.onMessageReceived(notification:)),
                name: NSNotification.Name.saSuperuserAuthorization
            )
            self.suplaClientProvider.forcedProvide().superuserAuthorizationRequest(
                withEmail: userName,
                andPassword: password
            )
            self.waitForResponse { result != nil }
            self.notificationCenterWrapper.unregisterObserver(observer)
            
            guard let result = result else {
                completable(.error(AuthorizationError(errorMessage: Strings.AuthorizationDialog.timeout)))
                return Disposables.create()
            }
            if (result.success) {
                completable(.completed)
                return Disposables.create()
            }
            completable(.error(AuthorizationError(errorMessage: result.error ?? Strings.Status.errorUnknown)))
            return Disposables.create()
        }
    }
    
    private func waitForResponse(_ resultAvailable: () -> Bool) {
        for _ in 0 ..< 10 {
            if (resultAvailable()) {
                return
            }
            threadHandler.sleep(1)
        }
    }
}

private class AuthorizationMessageObserver {
    @Singleton<NotificationCenterWrapper> private var notificationCenterWrapper
    
    var resultObserver: (AuthorizationResult) -> Void = { _ in }
    
    @objc func onMessageReceived(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let result = userInfo["result"],
              let authorizationResult = result as? SASuperuserAuthorizationResult
        else { return }
        
        if (authorizationResult.success) {
            resultObserver(AuthorizationResult(success: true))
        } else {
            resultObserver(AuthorizationResult(success: false, error: errorString(authorizationResult.code)))
        }
        
        notificationCenterWrapper.unregisterObserver(self)
    }
    
    private func errorString(_ errorCode: Int32) -> String {
        switch (errorCode) {
        case SUPLA_RESULTCODE_UNAUTHORIZED: Strings.Status.errorInvalidData
        case SUPLA_RESULTCODE_TEMPORARILY_UNAVAILABLE: Strings.Status.errorUnavailable
        default: Strings.Status.errorUnknown
        }
    }
    
    struct AuthorizationResult {
        let success: Bool
        let error: String?
        
        init(success: Bool, error: String? = nil) {
            self.success = success
            self.error = error
        }
    }
}
