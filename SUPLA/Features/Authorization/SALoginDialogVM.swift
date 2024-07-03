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
    

final class SALoginDialogVM: SACredentialsDialogVM {
    @Singleton<LoginUseCase> private var loginUseCase
    @Singleton<SuplaSchedulers> private var schedulers

    override func doAuthorization(userName: String, password: String, _ onAuthorized: @escaping () -> Void) {
        loginUseCase.invoke(userName: userName, password: password)
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
                        self?.updateView { $0.changing(path: \.error, to: Strings.Status.errorUnknown) }
                    }
                }
            )
            .disposed(by: self)
    }
}

