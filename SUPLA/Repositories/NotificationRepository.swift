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

protocol NotificationRepository: RepositoryProtocol where T == SANotification {
    func getAll(filter: String?) async -> [NotificationDto]
    func delete(_ notification: NotificationDto) async
    func deleteAll() async
    func deleteOlderThanMonth() async
}

extension NotificationRepository {
    func getAll() async -> [NotificationDto] { await getAll(filter: nil) }
}

class NotificationRepositoryImpl: Repository<SANotification>, NotificationRepository {
    func getAll(filter: String? = nil) async -> [NotificationDto] {
        let context = context
        return await context.perform {
            var request = SANotification.fetchRequest()
                .ordered(by: "date", ascending: false)
            
            if let filter {
                let pattern = "*\(filter)*"

                let predicates = [
                    NSPredicate(format: "title LIKE[c] %@", pattern),
                    NSPredicate(format: "message LIKE[c] %@", pattern),
                    NSPredicate(format: "profileName LIKE[c] %@", pattern)
                ]
                
                request = request.filtered(by: NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
            }
            
            return try? context.fetch(request).map { $0.dto }
        } ?? []
    }

    func delete(_ notification: NotificationDto) async {
        guard let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: notification.id) else { return }

        let context = context
        await context.perform {
            guard let object = try? context.existingObject(with: id) else { return }
            context.delete(object)
            try? context.save()
        }
    }

    func deleteAll() async {
        let context = context
        await context.perform {
            try? context.fetch(SANotification.fetchRequest()).forEach { context.delete($0) }
            try? context.save()
        }
    }

    func deleteOlderThanMonth() async {
        let context = context
        await context.perform {
            let request = SANotification.fetchRequest()
                .filtered(by: NSPredicate(format: "date < %@", Date().shift(days: -30) as NSDate))
            
            try? context.fetch(request).forEach { context.delete($0) }
            try? context.save()
        }
    }
}
