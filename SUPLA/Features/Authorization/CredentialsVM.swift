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

extension CredentialsFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<AuthorizeUseCase> private var authorizationUseCase
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaAppProvider> private var suplaAppProvider
        @Singleton<SuplaSchedulers> private var schedulers
        @Singleton<LoginUseCase> private var loginUseCase

        private let requestType: RequestType
        private let onAuthorized: () -> Void
        private let onDismissed: () -> Void

        init(
            requestType: RequestType,
            onAuthorized: @escaping () -> Void,
            onDismissed: @escaping () -> Void
        ) {
            self.requestType = requestType
            self.onAuthorized = onAuthorized
            self.onDismissed = onDismissed
            super.init(state: ViewState())

            if (isAuthorized()) {
                onAuthorized()
                state.visible = false
            } else {
                state.visible = true
            }
        }

        override func onViewAppear() {
            profileRepository.getActiveProfile()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] profile in
                        let isCloud = profile.server?.address?.contains(".supla.org") == true
                        let nameEnabled = self?.suplaAppProvider.provide().isClientRegistered() == true

                        self?.state.userName = profile.email ?? ""
                        self?.state.isCloudAccount = isCloud
                        self?.state.userNameEnabled = nameEnabled
                    }
                )
                .disposed(by: disposeBag)
        }

        func onDismiss() {
            onDismissed()
        }

        func onAuthorize() {
            if (isAuthorized()) {
                onAuthorized()
                return
            }

            switch (requestType) {
            case .authorize: authorize()
            case .login: login()
            }
        }

        private func authorize() {
            authorizationUseCase.invoke(userName: state.userName, password: state.password)
                .subscribe(on: schedulers.background)
                .observe(on: schedulers.main)
                .do(
                    onSubscribe: { [weak self] in self?.state.loading = true },
                    onDispose: { [weak self] in self?.state.loading = false }
                )
                .subscribe(
                    onCompleted: onAuthorized,
                    onError: { [weak self] error in
                        if let authorizationError = error as? AuthorizationError {
                            self?.state.error = authorizationError.errorMessage
                        } else {
                            self?.state.error = Strings.Status.errorUnknown
                        }
                    }
                )
                .disposed(by: disposeBag)
        }

        private func login() {
            loginUseCase.invoke(userName: state.userName, password: state.password)
                .subscribe(on: schedulers.background)
                .observe(on: schedulers.main)
                .do(
                    onSubscribe: { [weak self] in self?.state.loading = true },
                    onDispose: { [weak self] in self?.state.loading = false }
                )
                .subscribe(
                    onCompleted: onAuthorized,
                    onError: { [weak self] error in
                        if let authorizationError = error as? AuthorizationError {
                            self?.state.error = authorizationError.errorMessage
                        } else {
                            self?.state.error = Strings.Status.errorUnknown
                        }
                    }
                )
                .disposed(by: disposeBag)
        }

        private func isAuthorized() -> Bool {
            return suplaAppProvider.provide().isClientAuthorized()
        }
    }
}
