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
    func getTemperatureChartState(profileId: String, remoteId: Int32) -> TemperatureChartState
    func setTemperatureChartState(_ state: TemperatureChartState, profileId: String, remoteId: Int32)
    
}

final class UserStateHolderImpl: UserStateHolder {
    
    let userDefaults = UserDefaults.standard
    
    private let temperatureChartStateKey = "UserStateHolder.temperature_chart_state"
    func getTemperatureChartState(profileId: String, remoteId: Int32) -> TemperatureChartState {
        let key = parametrizedKey(key: temperatureChartStateKey, profileId, String(remoteId))
        if let data = userDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(TemperatureChartState.self, from: data)
            } catch {
                let errorString = String(describing: error)
                SALog.error("Could not decode state: \(errorString)")
            }
        }
        
        return TemperatureChartState.defaultState()
    }
    
    func setTemperatureChartState(_ state: TemperatureChartState, profileId: String, remoteId: Int32) {
        let key = parametrizedKey(key: temperatureChartStateKey, profileId, String(remoteId))
        do {
            let encoder = JSONEncoder()
            userDefaults.set(try encoder.encode(state), forKey: key)
        } catch {
            let errorString = String(describing: error)
            SALog.error("Could not encode state: \(errorString)")
        }
    }
    
    private func parametrizedKey(key: String, _ parameters: String...) -> String {
        var result = key
        for parameter in parameters {
            result = "\(result)_\(parameter)"
        }
        return result
    }
}
