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
    
protocol CreateCarPlayItemUseCase {
    func invoke(
        profileId: Int32,
        subjectType: SubjectType,
        subjectId: Int32,
        caption: String,
        action: CarPlayAction
    ) -> Observable<Void>
}

final class CreateCarPlayItemUseCaseImpl: CreateCarPlayItemUseCase {
    @Singleton<CarPlayItemRepository> private var carPlayItemRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    func invoke(
        profileId: Int32,
        subjectType: SubjectType,
        subjectId: Int32,
        caption: String,
        action: CarPlayAction
    ) -> Observable<Void> {
        profileRepository.getProfile(withId: profileId)
            .flatMapFirst { profile in
                Observable.zip(
                    self.carPlayItemRepository.create(),
                    self.carPlayItemRepository.findMaxOrder()
                ) { carPlayItem, order in
                    carPlayItem.profile = profile
                    carPlayItem.subjectTypeRaw = subjectType.rawValue
                    carPlayItem.subjectId = subjectId
                    carPlayItem.caption = caption
                    carPlayItem.actionRaw = action.id
                    carPlayItem.order = order + 1
                    return carPlayItem
                }
            }
            .flatMap { _ in self.carPlayItemRepository.save() }
    }
}
