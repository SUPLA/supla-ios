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
    
extension SharedCore.ImpulseCounterPhotoDto {
    static func fromJson(data: Data) throws -> ImpulseCounterPhotoDto {
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return fromArray(json)
    }
    
    static func fromJsonToArray(data: Data) throws -> [ImpulseCounterPhotoDto] {
        let jsonArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
        return jsonArray.map { fromArray($0) }
    }
    
    private static func fromArray(_ array: [String: Any]) -> ImpulseCounterPhotoDto {
        ImpulseCounterPhotoDto(
            id: array.getString("id")!,
            deviceGuid: array.getString("deviceGuid")!,
            channelNo: array.getInt32("channelNo")!,
            createdAt: array.getString("createdAt")!,
            replacedAt: array.getString("replacedAt"),
            processedAt: array.getString("processedAt"),
            resultMeasurement: array.getKotlinInt("resultMeasurement"),
            processingTimeMs: array.getKotlinInt("processingTimeMs"),
            resultMeasurement2: array.getKotlinInt("resultMeasurement2"),
            processingTimeMs2: array.getKotlinInt("processingTimeMs2"),
            resultCode: array.getInt32("resultCode") ?? 0,
            resultMessage: array.getString("resultMessage"),
            measurementValid: array.getBool("measurementValid") ?? false,
            image: array.getString("image"),
            imageCropped: array.getString("imageCropped")
        )
    }
}
