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
    
extension SuplaCloudClient {
    struct ElectricityMeasurement: Measurement {
        let date_timestamp: Date
        let phase1_fae: Double?
        let phase1_rae: Double?
        let phase1_fre: Double?
        let phase1_rre: Double?
        let phase2_fae: Double?
        let phase2_rae: Double?
        let phase2_fre: Double?
        let phase2_rre: Double?
        let phase3_fae: Double?
        let phase3_rae: Double?
        let phase3_fre: Double?
        let phase3_rre: Double?
        let fae_balanced: Double?
        let rae_balanced: Double?
        
        static func fromJson(data: Data) throws -> [ElectricityMeasurement] {
            return try decoder.decode([ElectricityMeasurement].self, from: data)
        }
    }
}
