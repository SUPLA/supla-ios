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

import RxRelay
import RxSwift

protocol ApplicationEventsManager {
    func emit(_ event: ApplicationEvent)
    func observe() -> Observable<ApplicationEvent>
    func observe(event: ApplicationEvent) -> Observable<Void>
}

class ApplicationEventsManagerImpl: ApplicationEventsManager {
    
    private let subject = PublishRelay<ApplicationEvent>()
    
    func emit(_ event: ApplicationEvent) {
        subject.accept(event)
    }
    
    func observe() -> Observable<ApplicationEvent> {
        subject.asObservable()
    }
    
    func observe(event: ApplicationEvent) -> Observable<Void> {
        subject.asObservable().filter { $0 == event }.map { _ in () }
    }
}

enum ApplicationEvent {
    case newNotification
}
