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

final class SAAuthorizationDialogVM: BaseViewModel<SAAuthorizationDialogViewState, SAAuthorizationDialogViewEvent> {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    @Singleton<AuthorizeUseCase> private var authorizationUseCase
    @Singleton<SuplaSchedulers> private var schedulers
    
    override func defaultViewState() -> SAAuthorizationDialogViewState { SAAuthorizationDialogViewState() }
    
    override func onViewDidLoad() {
        profileRepository.getActiveProfile()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] profile in
                    let isCloud = profile.authInfo?.serverForCurrentAuthMethod.contains(".supla.org") == true
                    let nameEnabled = self?.suplaClientProvider.provide().isRegistered() == true
                    
                    self?.updateView {
                        $0.changing(path: \.userName, to: profile.authInfo?.emailAddress ?? "")
                            .changing(path: \.isCloudAccount, to: isCloud)
                            .changing(path: \.userNameEnabled, to: nameEnabled)
                    }
                }
            )
            .disposed(by: self)
    }
    
    func isAuthorized() -> Bool {
        let client = suplaClientProvider.provide()
        return client.isRegistered() && client.isSuperuserAuthorized()
    }
    
    func onOk(userName: String, password: String, _ onAuthorized: @escaping () -> Void) {
        if (isAuthorized()) {
            onAuthorized()
            return
        }
        
        authorizationUseCase.invoke(userName: userName, password: password)
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .do(
                onSubscribe: { [weak self] in self?.updateView { $0.changing(path: \.loading, to: true) }},
                onDispose: { [weak self] in self?.updateView { $0.changing(path: \.loading, to: false) }}
            )
            .subscribe(
                onCompleted: onAuthorized,
                onError: { [weak self] error in
                    if let authorizationError = error as? AuthorizationError {
                        self?.updateView { $0.changing(path: \.error, to: authorizationError.errorMessage) }
                    } else {
                        self?.updateView { $0.changing(path: \.error, to: Strings.General.unknownError) }
                    }
                }
            )
            .disposed(by: self)
    }
}

struct SAAuthorizationDialogViewState: ViewState {
    var userName: String = ""
    var isCloudAccount: Bool = false
    var userNameEnabled: Bool = false
    var error: String? = nil
    var loading = false
}

enum SAAuthorizationDialogViewEvent: ViewEvent {
    case dismiss
}
