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

import SharedCore

extension Dictionary where Key == String, Value == Any {
    func getString(_ key: String) -> String? {
        self[key] as? String
    }
    
    func getInt32(_ key: String) -> Int32? {
        self[key] as? Int32
    }
    
    func getBool(_ key: String) -> Bool? {
        self[key] as? Bool
    }
    
    func getFloat(_ key: String) -> Float? {
        self[key] as? Float
    }
    
    func getDouble(_ key: String) -> Double? {
        self[key] as? Double
    }
    
    func getKotlinInt(_ key: String) -> KotlinInt? {
        KotlinInt.from(self[key] as? Int32)
    }
    
    func getObject(_ key: String) -> [String: Any]? {
        self[key] as? [String: Any]
    }
}

