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

protocol InsertNotificationUseCase {
    func invoke(userInfo: [AnyHashable: Any]) -> Observable<Void>
}

final class InsertNotificationUseCaseImpl: InsertNotificationUseCase {
    @Singleton<NotificationRepository> private var notificationRepository
    @Singleton<ApplicationEventsManager> private var applicationEventsManager

    func invoke(userInfo: [AnyHashable: Any]) -> Observable<Void> {
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any]
        let title = alert?["title"] as? String ?? ""
        let body = alert?["body"] as? String ?? ""
        let profileName = userInfo["profileName"] as? String

        return notificationRepository.create()
            .map {
                $0.title = title
                $0.message = body
                $0.profileName = profileName
                $0.date = Date()

                return $0
            }
            .flatMap { self.notificationRepository.save($0) }
            .do(onCompleted: { self.applicationEventsManager.emit(.newNotification) })
    }
}
