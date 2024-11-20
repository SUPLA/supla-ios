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

protocol UserStateHolder {
    func getDefaultChartState(profileId: String, remoteId: Int32) -> DefaultChartState
    func getElectricityChartState(profileId: String, remoteId: Int32) -> ElectricityChartState
    func setChartState(_ state: ChartState, profileId: String, remoteId: Int32)
    
    func getElectricityMeterSettings(profileId: String, remoteId: Int32) -> ElectricityMeterSettings
    func setElectricityMeterSettings(_ settings: ElectricityMeterSettings, profileId: String, remoteId: Int32)
    
    func getPhotoCreationTime(profileId: Int64, remoteId: Int32) -> Date?
    func setPhotoCreationTime(_ time: String, profileId: Int64, remoteId: Int32)
}

final class UserStateHolderImpl: UserStateHolder {
    
    let userDefaults = UserDefaults.standard
    
    private let temperatureChartStateKey = "UserStateHolder.temperature_chart_state"
    func getDefaultChartState(profileId: String, remoteId: Int32) -> DefaultChartState {
        let key = parametrizedKey(key: temperatureChartStateKey, profileId, String(remoteId))
        if let data = userDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(DefaultChartState.self, from: data)
            } catch {
                let errorString = String(describing: error)
                SALog.error("Could not decode state: \(errorString)")
            }
        }
        
        return DefaultChartState.empty()
    }
    
    func getElectricityChartState(profileId: String, remoteId: Int32) -> ElectricityChartState {
        let key = parametrizedKey(key: temperatureChartStateKey, profileId, String(remoteId))
        if let data = userDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(ElectricityChartState.self, from: data)
            } catch {
                let errorString = String(describing: error)
                SALog.error("Could not decode state: \(errorString)")
            }
        }
        
        return ElectricityChartState.empty()
    }
    
    func setChartState(_ state: ChartState, profileId: String, remoteId: Int32) {
        let key = parametrizedKey(key: temperatureChartStateKey, profileId, String(remoteId))
        do {
            userDefaults.set(try state.toJson(), forKey: key)
        } catch {
            let errorString = String(describing: error)
            SALog.error("Could not encode state: \(errorString)")
        }
    }
    
    private let electricityMeterSettingsKey = "UserStateHolder.electricity_meter_settings"
    func getElectricityMeterSettings(profileId: String, remoteId: Int32) -> ElectricityMeterSettings {
        let key = parametrizedKey(key: electricityMeterSettingsKey, profileId, String(remoteId))
        if let data = userDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(ElectricityMeterSettings.self, from: data)
            } catch {
                let errorString = String(describing: error)
                SALog.error("Could not decode state: \(errorString)")
            }
        }
        
        return ElectricityMeterSettings.defaultSettings()
    }
    
    func setElectricityMeterSettings(_ settings: ElectricityMeterSettings, profileId: String, remoteId: Int32) {
        let key = parametrizedKey(key: electricityMeterSettingsKey, profileId, String(remoteId))
        do {
            let encoder = JSONEncoder()
            userDefaults.set(try encoder.encode(settings), forKey: key)
        } catch {
            let errorString = String(describing: error)
            SALog.error("Could not encode state: \(errorString)")
        }
    }
    
    private let photoCreationTimeKey = "UserStateHolder.photo_creation_time"
    func getPhotoCreationTime(profileId: Int64, remoteId: Int32) -> Date? {
        let key = parametrizedKey(key: photoCreationTimeKey, String(profileId), String(remoteId))
        if let dateString = userDefaults.string(forKey: key) {
            let dateFormatter = ISO8601DateFormatter()
            return dateFormatter.date(from: dateString)
        }
        return nil
    }
    
    func setPhotoCreationTime(_ time: String, profileId: Int64, remoteId: Int32) {
        let key = parametrizedKey(key: photoCreationTimeKey, String(profileId), String(remoteId))
        userDefaults.set(time, forKey: key)
    }
    
    private func parametrizedKey(key: String, _ parameters: String...) -> String {
        var result = key
        for parameter in parameters {
            result = "\(result)_\(parameter)"
        }
        return result
    }
}
