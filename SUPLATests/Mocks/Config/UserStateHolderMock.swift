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

@testable import SUPLA

final class UserStateHolderMock: UserStateHolder {
    
    var getTemperatureCharStateParameters: [(String, Int32)] = []
    var getTemperatureChartStateReturns: TemperatureChartState = .defaultState()
    func getTemperatureChartState(profileId: String, remoteId: Int32) -> TemperatureChartState {
        getTemperatureCharStateParameters.append((profileId, remoteId))
        return getTemperatureChartStateReturns
    }
    
    var setTemperatureChartStateParameters: [(TemperatureChartState, String, Int32)] = []
    func setTemperatureChartState(_ state: TemperatureChartState, profileId: String, remoteId: Int32) {
        setTemperatureChartStateParameters.append((state, profileId, remoteId))
    }
    
    var getElectricityMeterSettingsParameters: [(String, Int32)] = []
    var getElectricityMeterSettingsReturns: ElectricityMeterSettings = .defaultSettings()
    func getElectricityMeterSettings(profileId: String, remoteId: Int32) -> ElectricityMeterSettings {
        getTemperatureCharStateParameters.append((profileId, remoteId))
        return getElectricityMeterSettingsReturns
    }
    
    var setElectricityMeterSettingsParameters: [(ElectricityMeterSettings, String, Int32)] = []
    func setElectricityMeterSettings(_ settings: ElectricityMeterSettings, profileId: String, remoteId: Int32) {
        setElectricityMeterSettingsParameters.append((settings, profileId, remoteId))
    }
    
}
