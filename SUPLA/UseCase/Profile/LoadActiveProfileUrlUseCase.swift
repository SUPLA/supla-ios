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

enum CloudUrl {
    case suplaCloud
    case privateCloud(url: URL)
}

protocol LoadActiveProfileUrlUseCase {
    func invoke() -> Single<CloudUrl>
}

final class LoadActiveProfileUrlUseCaseImpl: LoadActiveProfileUrlUseCase {
    @Singleton<ProfileRepository> private var profileRepository

    func invoke() -> Single<CloudUrl> {
        profileRepository.getActiveProfile()
            .first()
            .map { profile in
                guard let authInfo = profile?.authInfo else { return .suplaCloud }

                if (authInfo.emailAuth == true) {
                    if (authInfo.serverForEmail.hasSuffix("supla.org") == false), let url = URL(string: "https://\(authInfo.serverForEmail)") {
                        return .privateCloud(url: url)
                    } else {
                        return .suplaCloud
                    }
                } else {
                    if (authInfo.serverForAccessID.hasSuffix("supla.org") == false), let url = URL(string: "https://\(authInfo.serverForAccessID)") {
                        return .privateCloud(url: url)
                    } else {
                        return .suplaCloud
                    }
                }
            }
    }
}
