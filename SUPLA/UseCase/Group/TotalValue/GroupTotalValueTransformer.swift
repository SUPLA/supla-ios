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

class GroupTotalValueTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let groupTotalValue = value as? GroupTotalValue else { return nil }
        
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: groupTotalValue, requiringSecureCoding: true)
        } catch {
            let message = String(describing: error)
            SALog.error("Archiver failed: \(message)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [GroupTotalValue.self, NSArray.self],
                from: data
            )
        } catch {
            let message = String(describing: error)
            SALog.error("Unarchiver failed: \(message)")
            return nil
        }
    }
}
