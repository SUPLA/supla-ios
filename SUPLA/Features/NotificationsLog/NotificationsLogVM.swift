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

extension NotificationsLogFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<NotificationRepository> private var notificationRepository
        @Singleton<ApplicationEventsManager> private var applicationEventsManager
        
        private var currentFilter: String? = nil
        private var previousFilter: String? = nil
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            Task {
                await reloadList(force: true)
            }
            
            applicationEventsManager.observe(event: .newNotification)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in
                        Task { await self?.reloadList(force: true) }
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func delete(notification: NotificationDto) {
            Task {
                await self.notificationRepository.delete(notification)
                await self.reloadList(force: true)
            }
        }
        
        func deleteAll() {
            hideDeleteDialog()
            Task {
                await self.notificationRepository.deleteAll()
                await self.reloadList(force: true)
            }
        }
        
        func deleteOlderThanMonth() {
            hideDeleteDialog()
            Task {
                await self.notificationRepository.deleteOlderThanMonth()
                await self.reloadList(force: true)
            }
        }
        
        @objc func showDeleteDialog() {
            state.showDeleteDialog = true
        }
        
        func hideDeleteDialog() {
            state.showDeleteDialog = false
        }
        
        func onSearchTextChanged(_ text: String) {
            currentFilter = text
            Task {
                await reloadList(force: false)
            }
        }
        
        private func reloadList(force: Bool) async {
            let notifications = await getNotifications(force: force)
            await MainActor.run {
                self.state.notifications = notifications
            }
        }
        
        private func getNotifications(force: Bool) async -> [NotificationDto] {
            let filter = currentFilter?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let filter, filter.count > 1 {
                if (force || filter != previousFilter) {
                    previousFilter = filter
                    return await notificationRepository.getAll(filter: filter)
                } else {
                    previousFilter = filter
                    return state.notifications
                }
            } else if (force || previousFilter != nil) {
                previousFilter = nil
                return await notificationRepository.getAll()
            }
            
            return state.notifications
        }
    }
}
