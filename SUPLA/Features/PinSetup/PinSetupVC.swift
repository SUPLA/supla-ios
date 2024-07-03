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

extension PinSetupFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        private let scope: LockScreenScope

        init(viewModel: ViewModel, scope: LockScreenScope) {
            self.scope = scope
            super.init(viewModel: viewModel)
            
            contentView = PinSetupFeature.View(
                viewState: state,
                onPinChange: { viewModel.onPinChange($0) },
                onSave: { viewModel.onSaveClick(.application) },
                onAppear: { viewModel.onAppear() }
            )
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            title = Strings.PinSetup.title
        }

        static func create(scope: LockScreenScope) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(viewModel: viewModel, scope: scope)
        }
    }
}
