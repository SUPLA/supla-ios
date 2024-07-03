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

extension LockScreenFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        override var navigationBarHidden: Bool { unlockAction == .authorizeApplication }
        override var preferredStatusBarStyle: UIStatusBarStyle { unlockAction == .authorizeApplication ? .darkContent : .lightContent }

        private let unlockAction: UnlockAction

        init(viewModel: ViewModel, unlockAction: UnlockAction) {
            self.unlockAction = unlockAction
            super.init(viewModel: viewModel)

            contentView = LockScreenFeature.View(
                viewState: state,
                onPinChange: { viewModel.onPinChange($0) },
                onBiometricShow: { viewModel.onViewAppeared() },
                onPinForgotten: { viewModel.onPinForgotten() }
            )
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            viewModel.setUnlockAction(unlockAction)

            switch (unlockAction) {
            case .authorizeAccountsCreate, .authorizeAccountsEdit:
                title = Strings.Profiles.Title.short
            default:
                title = Strings.PinSetup.title
            }
        }

        static func create(unlockAction: UnlockAction) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(viewModel: viewModel, unlockAction: unlockAction)
        }
    }
}
