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

@objc(CounterLog15to16MigrationPolicy)
final class CounterLog15to16MigrationPolicy: NSEntityMigrationPolicy {
    
    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let context = manager.destinationContext
        let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
            .filtered(by: NSPredicate(format: "calculated_value < 0 or counter < 0"))
        let counterLogs = try context.fetch(request)
        var channelIds: [Int32] = []
        
        counterLogs.forEach { log in
            if let channelId = log.value(forKey: "channel_id") as? Int32 {
                if (!channelIds.contains(channelId)) {
                    channelIds.append(channelId)
                }
            }
        }
    
        try channelIds.forEach {
            let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
                .filtered(by: NSPredicate(format: "channel_id == \($0)"))
            try context.fetch(request).forEach(context.delete)
        }
    }
}
