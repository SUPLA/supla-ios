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
    
extension ProfileChooserFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton var coordinator: SuplaAppCoordinator
        @Singleton var activateProfileUseCase: ActivateProfileUseCase
        
        @Singleton<ProfileRepository> var profileRepository
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            Task {
                let profiles = await profileRepository.getAllProfiles()
                await MainActor.run { state.profiles = profiles }
            }
        }
        
        func onDismiss() {
            coordinator.dismiss(animated: true)
        }
        
        func onProfileSelected(_ profile: ProfileDto) {
            activateProfileUseCase.invoke(profileId: profile.id, force: false)
                .asDriverWithoutError()
                .drive(
                    onCompleted: { [weak self] in self?.coordinator.dismiss(animated: true) }
                )
                .disposed(by: disposeBag)
        }
    }
}
