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

final class SaveIconUseCase {
    
    @Singleton<UserIconRepository> private var userIconRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(remoteId: Int32, images: [String], darkImages: [String]?) {
        do {
            try profileRepository.getActiveProfile()
                .flatMapFirst { profile in
                    self.userIconRepository.getIcon(for: profile, withId: remoteId)
                        .ifEmpty(switchTo: self.createIcon(remoteId: remoteId, profile: profile))
                }
                .map { icon in
                    icon.uimage1 = self.image(at: 0, in: images)
                    icon.uimage2 = self.image(at: 1, in: images)
                    icon.uimage3 = self.image(at: 2, in: images)
                    icon.uimage4 = self.image(at: 3, in: images)
                    
                    if let darkImages = darkImages {
                        icon.uimage1_dark = self.image(at: 0, in: darkImages)
                        icon.uimage2_dark = self.image(at: 1, in: darkImages)
                        icon.uimage3_dark = self.image(at: 2, in: darkImages)
                        icon.uimage4_dark = self.image(at: 3, in: darkImages)
                    }
                    
                    return icon
                }
                .flatMapFirst { (icon: SAUserIcon) in
                    if (icon.isEmpty()) {
                        return self.userIconRepository.delete(icon)
                    } else {
                        return self.userIconRepository.save(icon)
                    }
                }
                .toBlocking()
                .first()
        } catch {
            
        }
    }
    
    private func createIcon(remoteId: Int32, profile: AuthProfileItem) -> Observable<SAUserIcon> {
        userIconRepository.create()
            .map { icon in
                icon.remote_id = remoteId
                icon.profile = profile
                
                return icon
            }
    }
    
    private func image(at index: Int, in data: [String]) -> NSData? {
        if (data.count > index) {
            return NSData(base64Encoded: data[index])
        }
        return nil
    }
}
