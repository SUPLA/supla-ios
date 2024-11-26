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
    
    var getDefaultCharStateParameters: [(Int32, Int32)] = []
    var getDefaultChartStateReturns: DefaultChartState = .empty()
    func getDefaultChartState(profileId: Int32, remoteId: Int32) -> DefaultChartState {
        getDefaultCharStateParameters.append((profileId, remoteId))
        return getDefaultChartStateReturns
    }
    
    var getElectricityCharStateParameters: [(Int32, Int32)] = []
    var getElectricityChartStateReturns: ElectricityChartState = .empty()
    func getElectricityChartState(profileId: Int32, remoteId: Int32) -> ElectricityChartState {
        getElectricityCharStateParameters.append((profileId, remoteId))
        return getElectricityChartStateReturns
    }
    
    var setChartStateParameters: [(ChartState, Int32, Int32)] = []
    func setChartState(_ state: ChartState, profileId: Int32, remoteId: Int32) {
        setChartStateParameters.append((state, profileId, remoteId))
    }
    
    var getElectricityMeterSettingsParameters: [(Int32, Int32)] = []
    var getElectricityMeterSettingsReturns: ElectricityMeterSettings = .defaultSettings()
    func getElectricityMeterSettings(profileId: Int32, remoteId: Int32) -> ElectricityMeterSettings {
        getElectricityMeterSettingsParameters.append((profileId, remoteId))
        return getElectricityMeterSettingsReturns
    }
    
    var setElectricityMeterSettingsParameters: [(ElectricityMeterSettings, Int32, Int32)] = []
    func setElectricityMeterSettings(_ settings: ElectricityMeterSettings, profileId: Int32, remoteId: Int32) {
        setElectricityMeterSettingsParameters.append((settings, profileId, remoteId))
    }
    
    var getPhotoCreationTimeMock: FunctionMock<(Int32, Int32), Date?> = .init()
    func getPhotoCreationTime(profileId: Int32, remoteId: Int32) -> Date? {
        return getPhotoCreationTimeMock.handle((profileId, remoteId))
    }
    
    var setPhotoCreationTimeMock: FunctionMock<(String, Int32, Int32), Void> = .init()
    func setPhotoCreationTime(_ time: String, profileId: Int32, remoteId: Int32) {
        setPhotoCreationTimeMock.handle((time, profileId, remoteId))
    }
    
    func migrateFrom17To19ModelMappingVersion(_ profileObjectId: NSManagedObjectID, _ profileId: Int32) {
    }
}
