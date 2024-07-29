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

protocol LoginUseCase {
    func invoke(userName: String, password: String) -> Completable
}

final class LoginUseCaseImpl: LoginUseCase {
    @Singleton<NotificationCenterWrapper> private var notificationCenterWrapper
    @Singleton<SuplaAppProvider> private var suplaAppProvider
    @Singleton<ThreadHandler> private var threadHandler
    
    func invoke(userName: String, password: String) -> Completable {
        Completable.create { completable in
            var result: AuthorizationResult? = nil
            
            let registerObserver = RegisteredMessageObserver { result = $0 }
            let registerErrorObserver = RegisterErrorMessageObserver { result = $0 }
            self.register(registerObserver, registerErrorObserver)
            
            self.suplaAppProvider.initClientWithOneTimePassword(password)
            self.waitForResponse { result != nil }
            
            self.notificationCenterWrapper.unregisterObserver(registerObserver)
            self.notificationCenterWrapper.unregisterObserver(registerErrorObserver)
            
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
    
    private func register(_ registeredObserver: RegisteredMessageObserver, _ registerErrorObserver: RegisterErrorMessageObserver) {
        notificationCenterWrapper.registerObserver(
            registeredObserver,
            selector: #selector(registeredObserver.onMessageReceived(notification:)),
            name: NSNotification.Name.saRegistered
        )
        
        notificationCenterWrapper.registerObserver(
            registerErrorObserver,
            selector: #selector(registerErrorObserver.onMessageReceived(notification:)),
            name: NSNotification.Name.saRegisterError
        )
    }
    
    private func waitForResponse(_ resultAvailable: () -> Bool) {
        for _ in 0 ..< 10 {
            if (resultAvailable()) {
                return
            }
            threadHandler.sleep(1)
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

private class RegisteredMessageObserver {
    @Singleton<NotificationCenterWrapper> private var notificationCenterWrapper
    
    var resultObserver: (LoginUseCaseImpl.AuthorizationResult) -> Void = { _ in }
    
    init(resultObserver: @escaping (LoginUseCaseImpl.AuthorizationResult) -> Void) {
        self.resultObserver = resultObserver
    }
    
    @objc func onMessageReceived(notification: Notification) {
        resultObserver(LoginUseCaseImpl.AuthorizationResult(success: true))
        notificationCenterWrapper.unregisterObserver(self)
    }
}

private class RegisterErrorMessageObserver {
    @Singleton<NotificationCenterWrapper> private var notificationCenterWrapper
    
    var resultObserver: (LoginUseCaseImpl.AuthorizationResult) -> Void = { _ in }
    
    init(resultObserver: @escaping (LoginUseCaseImpl.AuthorizationResult) -> Void) {
        self.resultObserver = resultObserver
    }
    
    @objc func onMessageReceived(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let result = userInfo["code"],
              let resultCode = result as? NSNumber
        else { return }
        
        resultObserver(LoginUseCaseImpl.AuthorizationResult(success: false, error: SuplaResultCode.from(value: Int32(truncating: resultCode)).getTextMessage(authDialog: true)))
        
        notificationCenterWrapper.unregisterObserver(self)
    }
}
