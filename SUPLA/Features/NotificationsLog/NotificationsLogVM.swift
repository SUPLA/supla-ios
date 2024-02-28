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

class NotificationsLogVM: BaseViewModel<NotificationsLogViewState, NotificationsLogViewEvent> {
    @Singleton<NotificationRepository> private var notificationRepository
    @Singleton<ApplicationEventsManager> private var applicationEventsManager
    
    override func defaultViewState() -> NotificationsLogViewState { NotificationsLogViewState() }
    
    override func onViewDidLoad() {
        notificationRepository.getAll()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] items in
                    self?.updateView { $0.changing(path: \.items, to: items) }
                }
            )
            .disposed(by: self)
        
        observeAndReloadList { applicationEventsManager.observe(event: .newNotification) }
    }
    
    func delete(_ notification: SANotification) {
        observeAndReloadList { notificationRepository.delete(notification) }
    }
    
    func deleteAll() {
        observeAndReloadList { notificationRepository.deleteAll() }
    }
    
    func deleteOlderThanMonth() {
        observeAndReloadList { notificationRepository.deleteOlderThanMonth() }
    }
    
    private func observeAndReloadList(_ observable: () -> Observable<Void>) {
        observable()
            .flatMap { [weak self] _ in
                self?.notificationRepository.getAll() ?? Observable.just([])
            }
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] items in
                    self?.updateView { $0.changing(path: \.items, to: items) }
                }
            )
            .disposed(by: self)
    }
}

enum NotificationsLogViewEvent: ViewEvent {}

struct NotificationsLogViewState: ViewState {
    var items: [SANotification] = []
}
