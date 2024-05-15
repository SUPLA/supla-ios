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

@testable import SUPLA
import RxSwift

final class DeleteAllProfileDataUseCaseMock: DeleteAllProfileDataUseCase {
    var parameters: [AuthProfileItem] = []
    var returns: Observable<Void> = .empty()
    func invoke(profile: AuthProfileItem) -> Observable<Void> {
        parameters.append(profile)
        return returns
    }
}

final class DeleteProfileUseCaseMock: DeleteProfileUseCase {
    var parameters: [ProfileID] = []
    var returns: Observable<DeleteProfileResult> = .empty()
    func invoke(profileId: ProfileID) -> Observable<DeleteProfileResult> {
        parameters.append(profileId)
        return returns
    }
}

final class SaveOrCreateProfileUseCaseMock: SaveOrCreateProfileUseCase {
    var parameters: [(ProfileID?, String, Bool, AuthInfo)] = []
    var returns: Observable<SaveOrCreateProfileResult> = .empty()
    func invoke(profileId: ProfileID?, name: String, advancedMode: Bool, authInfo: AuthInfo) -> Observable<SaveOrCreateProfileResult> {
        parameters.append((profileId, name, advancedMode, authInfo))
        return returns
    }
}

final class ActivateProfileUseCaseMock: ActivateProfileUseCase {
    var parameters: [(ProfileID, Bool)] = []
    var returns: Observable<Bool> = .empty()
    func invoke(profileId: ProfileID, force: Bool) -> Observable<Bool> {
        parameters.append((profileId, force))
        return returns
    }
}

final class LoadActiveProfileUrlUseCaseMock: LoadActiveProfileUrlUseCase {
    var calls: Int = 0
    var returns: Single<CloudUrl> = .never()
    func invoke() -> Single<CloudUrl> {
        calls += 1
        return returns
    }
}
