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
    case betaCloud
    case privateCloud(url: URL)
}

extension CloudUrl {
    var urlString: String {
        switch (self) {
        case .suplaCloud: return "https://cloud.supla.org"
        case .betaCloud: return "https://beta-cloud.supla.org"
        case .privateCloud(let url): return url.absoluteString
        }
    }

    var url: URL {
        switch (self) {
        case .suplaCloud: return URL(string: "https://cloud.supla.org")!
        case .betaCloud: return URL(string: "https://beta-cloud.supla.org")!
        case .privateCloud(let url): return url
        }
    }
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
                guard let address = profile?.server?.address
                else { return .suplaCloud }

                if (address.hasSuffix("supla.org") == false),
                   let url = URL(string: "https://\(address)")
                {
                    return .privateCloud(url: url)
                } else if (address.hasSuffix("beta-cloud.supla.org")) {
                    return .betaCloud
                } else {
                    return .suplaCloud
                }
            }
    }
}
