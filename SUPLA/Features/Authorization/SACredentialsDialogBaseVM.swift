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

class SACredentialsDialogVM: BaseViewModel<SACredentialsDialogViewState, SACredentialsDialogViewEvent> {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SuplaAppProvider> private var suplaAppProvider

    override func defaultViewState() -> SACredentialsDialogViewState { SACredentialsDialogViewState() }

    override func onViewDidLoad() {
        profileRepository.getActiveProfile()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] profile in
                    let isCloud = profile.authInfo?.serverForCurrentAuthMethod.contains(".supla.org") == true
                    let nameEnabled = self?.suplaAppProvider.provide().isClientRegistered() == true

                    self?.updateView {
                        $0.changing(path: \.userName, to: profile.authInfo?.emailAddress ?? "")
                            .changing(path: \.isCloudAccount, to: isCloud)
                            .changing(path: \.userNameEnabled, to: nameEnabled)
                    }
                }
            )
            .disposed(by: self)
    }

    final func isAuthorized() -> Bool {
        return suplaAppProvider.provide().isClientAuthorized()
    }

    final func onOk(userName: String, password: String, _ onAuthorized: @escaping () -> Void) {
        if (isAuthorized()) {
            onAuthorized()
            return
        }

        doAuthorization(userName: userName, password: password, onAuthorized)
    }

    func doAuthorization(userName: String, password: String, _ onAuthorized: @escaping () -> Void) {
        fatalError("doAuthorization(username:, password:, onAuthorized:) needs to be implemented")
    }
}

struct SACredentialsDialogViewState: ViewState {
    var userName: String = ""
    var isCloudAccount: Bool = false
    var userNameEnabled: Bool = false
    var error: String? = nil
    var loading = false
}

enum SACredentialsDialogViewEvent: ViewEvent {
    case dismiss
}
