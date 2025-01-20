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

import Foundation
import CoreData

enum CoreDataMigrationVersion: String, CaseIterable {
    case version1 = "SUPLA"
    case version2 = "SUPLA 2"
    case version3 = "SUPLA 3"
    case version4 = "SUPLA 4"
    case version5 = "SUPLA 5"
    case version6 = "SUPLA 6"
    case version7 = "SUPLA 7"
    case version8 = "SUPLA 8"
    case version9 = "SUPLA 9"
    case version10 = "SUPLA 10"
    case version11 = "SUPLA 11"
    case version12 = "SUPLA 12"
    case version13 = "SUPLA 13"
    case version14 = "SUPLA 14"
    case version15 = "SUPLA 15"
    case version16 = "SUPLA 16"
    case version17 = "SUPLA 17"
    case version18 = "SUPLA 18"
    case version19 = "SUPLA 19"
    case version20 = "SUPLA 20"
    
    static var current: CoreDataMigrationVersion {
        guard let latest = allCases.last else {
            fatalError("no model versions found")
        }
        
        return latest
    }
    
    // MARK: Migration
    
    func nextVersion() -> CoreDataMigrationVersion? {
        switch self {
        case .version1,
                .version2,
                .version3,
                .version4,
                .version5,
                .version6,
                .version7,
                .version8,
                .version9,
                .version10:
            return .version11
        case .version11:
            return .version12
        case .version12:
            return .version13
        case .version13:
            return .version14
        case .version14:
            return .version15
        case .version15:
            return .version16
        case .version16:
            return .version17
        case .version17:
            return .version19
        case .version18:
            return .version19
        case .version19:
            return .version20
        case .version20:
            return nil
        }
    }
}
