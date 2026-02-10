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

protocol NfcTagItemRepository: RepositoryProtocol where T == SANfcTagItem {
    func findAll() async -> [NfcTagItemDto]
    func find(byUuid uuid: String) async -> NfcTagItemDto?
    func save(
        uuid: String,
        name: String,
        profileId: Int32?,
        subjectType: SubjectType?,
        subjectId: Int32?,
        actionId: ActionId?,
        readOnly: Bool?
    ) async -> Bool
    func delete(byUuid uuid: String) async -> Bool
    
    func markReadOnly(uuid: String) async
    func addCallItem(toTagWithUuid uuid: String, result: NfcCallResult) async
}

final class NfcTagItemRepositoryImpl: Repository<SANfcTagItem>, NfcTagItemRepository {
    func findAll() async -> [NfcTagItemDto] {
        let context = context
        
        return await context.perform {
            if let items = try? context.fetch(SANfcTagItem.fetchRequest().ordered(by: "name")) {
                items.map { $0.dto }
            } else {
                []
            }
        }
    }
    
    func find(byUuid uuid: String) async -> NfcTagItemDto? {
        let context = context
        
        return await context.perform {
            try? context.fetch(SANfcTagItem.fetchRequest().filtered(by: NSPredicate(format: "uuid = %@", uuid))).first?.dto
        }
    }
    
    func save(
        uuid: String,
        name: String,
        profileId: Int32?,
        subjectType: SubjectType?,
        subjectId: Int32?,
        actionId: ActionId?,
        readOnly: Bool?
    ) async -> Bool {
        let context = context
        do {
            try await context.perform {
                let request = SANfcTagItem.fetchRequest().filtered(by: NSPredicate(format: "uuid = %@", uuid))
                if let tag = try? context.fetch(request).first {
                    tag.name = name
                    tag.profileId = profileId?.let { NSNumber(value: $0) }
                    tag.subjectTypeRaw = subjectType?.let { NSNumber(value: $0.rawValue) }
                    tag.subjectId = subjectId?.let { NSNumber(value: $0) }
                    tag.actionIdRaw = actionId?.let { NSNumber(value: $0.id) }
                    if let readOnly {
                        tag.readOnly = readOnly
                    }
                } else {
                    let tagCall: SANfcCallItem = context.create()
                    tagCall.date = Date().timeIntervalSince1970
                    tagCall.resultRaw = NfcCallResult.tagAdded.rawValue
                    
                    let tag: SANfcTagItem = context.create()
                    tag.uuid = uuid
                    tag.date = Date().timeIntervalSince1970
                    tag.name = name
                    tag.profileId = profileId?.let { NSNumber(value: $0) }
                    tag.subjectTypeRaw = subjectType?.let { NSNumber(value: $0.rawValue) }
                    tag.subjectId = subjectId?.let { NSNumber(value: $0) }
                    tag.actionIdRaw = actionId?.let { NSNumber(value: $0.id) }
                    tag.readOnly = readOnly ?? false
                    tag.callItems = NSOrderedSet(array: [tagCall])
                }
                
                try context.save()
            }
            return true
        } catch {
            return false
        }
    }
    
    func markReadOnly(uuid: String) async {
        let context = context
        do {
            try await context.perform {
                let request = SANfcTagItem.fetchRequest().filtered(by: NSPredicate(format: "uuid = %@", uuid))
                if let tag = try? context.fetch(request).first {
                    tag.readOnly = true
                    try context.save()
                }
            }
        } catch {
            SALog.error("Failed to mark tag as read only: \(String(describing: error))")
        }
    }
    
    func delete(byUuid uuid: String) async -> Bool {
        let context = context
        
        return await context.perform {
            let request = SANfcTagItem.fetchRequest().filtered(by: NSPredicate(format: "uuid == %@", uuid))
            if let item = try? context.fetch(request).first {
                context.delete(item)
                return true
            }
            
            return false
        }
    }
    
    func addCallItem(toTagWithUuid uuid: String, result: NfcCallResult) async {
        let context = context
        do {
            try await context.perform {
                let request = SANfcTagItem.fetchRequest().filtered(by: NSPredicate(format: "uuid = %@", uuid))
                if let tag = try? context.fetch(request).first {
                    // create item
                    let item: SANfcCallItem = context.create()
                    item.date = Date().timeIntervalSince1970
                    item.resultRaw = result.rawValue
                    
                    // Add to relation
                    let newItems = tag.callItems?.mutableCopy() as? NSMutableOrderedSet ?? NSMutableOrderedSet()
                    newItems.add(item)
                    tag.callItems = newItems
                    
                    // Save context
                    try context.save()
                }
            }
        } catch {
            SALog.error("Failed to mark tag as read only: \(String(describing: error))")
        }
    }
}
