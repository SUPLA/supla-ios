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
    
extension SharedCore.ImpulseCounterPhoto {
    static func fromJson(data: Data) throws -> ImpulseCounterPhoto {
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return ImpulseCounterPhoto(
            id: json.getString("id")!,
            deviceGuid: json.getString("deviceGuid")!,
            channelNo: json.getInt32("channelNo")!,
            createdAt: json.getString("createdAt")!,
            replacedAt: json.getString("replacedAt"),
            processedAt: json.getString("processedAt"),
            resultMeasurement: json.getKotlinInt("resultMeasurement"),
            processingTimeMs: json.getKotlinInt("processingTimeMs"),
            resultMeasurement2: json.getKotlinInt("resultMeasurement2"),
            processingTimeMs2: json.getKotlinInt("processingTimeMs2"),
            resultCode: json.getInt32("resultCode") ?? 0,
            resultMessage: json.getString("resultMessage"),
            image: json.getString("image"),
            imageCropped: json.getString("imageCropped")
        )
    }
}

extension Dictionary where Key == String, Value == Any {
    func getString(_ key: String) -> String? {
        self[key] as? String
    }
    
    func getInt32(_ key: String) -> Int32? {
        self[key] as? Int32
    }
    
    func getKotlinInt(_ key: String) -> KotlinInt? {
        KotlinInt.from(self[key] as? Int32)
    }
}
