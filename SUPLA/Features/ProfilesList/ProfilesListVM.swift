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
    
extension ProfilesListFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<UpdateProfilesOrder.UseCase> private var updateProfilesOrderUseCase
        @Singleton<ActivateProfileUseCase> private var activateProfileUseCase
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SuplaAppCoordinator> private var coordinator
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewWillAppear() {
            profileRepository.getAllProfiles()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] profiles in
                    self?.state.items = profiles.map { $0.asDto }
                })
                .disposed(by: disposeBag)
        }
        
        func onNewProfile() {
            coordinator.navigateToProfile(profileId: nil)
        }
        
        func onEditProfile(_ profile: ProfileDto) {
            coordinator.navigateToProfile(profileId: profile.id)
        }
        
        func onActivateProfile(_ profile: ProfileDto) {
            activateProfileUseCase.invoke(profileId: profile.id!, force: true)
                .asDriverWithoutError()
                .drive(
                    onCompleted: { [weak self] in
                        self?.coordinator.popToStatus()
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func onMoved(_ from: IndexSet, _ to: Int) {
            var items = state.items
            items.move(fromOffsets: from, toOffset: to)
            
            var order: Int32 = 0
            updateProfilesOrderUseCase.invoke(
                items: items.map {
                    order += 1
                    return UpdateProfilesOrder.Item(id: $0.id!, position: order)
                }
            )
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] _ in
                    self?.onViewWillAppear()
                }
            )
            .disposed(by: disposeBag)
        }
    }
}
