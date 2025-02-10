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
        return ImpulseCounterPhotoDto(
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
            measurementValid: json.getBool("measurementValid") ?? false,
            image: json.getString("image"),
            imageCropped: json.getString("imageCropped")
        )
    }
}

