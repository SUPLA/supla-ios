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

extension CreateProfileFeature {
    class ViewController: SuplaCore.BaseViewController<ViewState, View, ViewModel> {
        
        @Singleton<GlobalSettings> var settings
        
        private let profileId: Int32?

        init(viewModel: ViewModel, profileId: Int32?) {
            self.profileId = profileId
            super.init(viewModel: viewModel)

            contentView = View(
                viewState: state,
                onAdvancedAuthorizationChange: viewModel.onToggleAdvancedState(_:),
                onServerAutoDetectChange: viewModel.onServerAutoDetectChange(_:),
                onLogout: { viewModel.logoutAccount(profileId: profileId) },
                onDelete: { viewModel.removeAccount(profileId: profileId) },
                onSave: { viewModel.save(profileId: profileId) },
                onCreateAccount: { viewModel.createNewAccount() }
            )
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            viewModel.loadData(profileId: profileId)
            
            navigationItem.setHidesBackButton(!settings.anyAccountRegistered, animated: true)
            title = getTitle()
        }
        
        private func getTitle() -> String {
            if (!settings.anyAccountRegistered) {
                return Strings.appName
            } else if (profileId != nil) {
                return Strings.CreateProfile.modificationTitle
            } else {
                return Strings.CreateProfile.creationTitle
            }
        }
        
        static func create(profileId: Int32?) -> UIViewController {
            let viewModel = ViewModel()
            return ViewController(viewModel: viewModel, profileId: profileId)
        }
    }
}

extension CreateProfileFeature.ViewController: NavigationSubcontroller {
    func screenTakeoverAllowed() -> Bool {
        return false
    }
}
