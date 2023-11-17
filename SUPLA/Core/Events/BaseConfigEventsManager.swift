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

class BaseConfigEventsManager<T> {
    
    private var subjects: [Int32: PublishRelay<T>] = [:]
    
    private let syncedQueue: DispatchQueue
    
    init(queueLabel: String) {
        self.syncedQueue = DispatchQueue(label: queueLabel, attributes: .concurrent)
    }
    
    func observeConfig(id: Int32) -> Observable<T> {
        getSubject(id: id).asObservable()
    }
    
    internal func getSubject(id: Int32) -> PublishRelay<T> {
        return syncedQueue.sync(execute: {
            if let subject = subjects[id] {
                return subject
            }
            
            let subject = PublishRelay<T>()
            subjects[id] = subject
            return subject
        })
    }
}
