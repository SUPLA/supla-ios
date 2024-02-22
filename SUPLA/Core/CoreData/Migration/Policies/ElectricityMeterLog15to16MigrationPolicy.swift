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

@objc(ElectricityMeterLog15to16MigrationPolicy)
final class ElectricityMeterLog15to16MigrationPolicy: NSEntityMigrationPolicy {
    private let fieldsArray = [
        "phase1_fae",
        "phase1_fre",
        "phase1_rae",
        "phase1_rre",
        "phase2_fae",
        "phase2_fre",
        "phase2_rae",
        "phase2_rre",
        "phase3_fae",
        "phase3_fre",
        "phase3_rae",
        "phase3_rre",
        "fae_balanced",
        "rae_balanced < 0"
    ]
    
    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let context = manager.destinationContext

        let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
            .filtered(by: NSPredicate(format: fieldsArray.joined(separator: " < 0 OR ")))
        let counterLogs = try context.fetch(request)
        var channelIds: [Int32] = []

        for log in counterLogs {
            if let channelId = log.value(forKey: "channel_id") as? Int32 {
                if (!channelIds.contains(channelId)) {
                    channelIds.append(channelId)
                }
            }
        }

        for channelId in channelIds {
            let request = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
                .filtered(by: NSPredicate(format: "channel_id == \(channelId)"))
            try context.fetch(request).forEach(context.delete)
        }
    }
}
