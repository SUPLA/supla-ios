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

class GlobalSettingsMock: GlobalSettings {
    
    var anyAccountRegisteredReturns: Bool = false
    var anyAccountRegisteredValues: [Bool] = []
    var anyAccountRegistered: Bool {
        get { anyAccountRegisteredReturns }
        set { anyAccountRegisteredValues.append(newValue) }
    }

    var newGestureInfoShownReturns: Bool = false
    var newGestureInfoShownValues: [Bool] = []
    var newGestureInfoShown: Bool {
        get { newGestureInfoShownReturns }
        set { newGestureInfoShownValues.append(newValue) }
    }

    var shouldShowNewGestureInfoReturns: Bool = false
    var shouldShowNewGestureInfoValues: [Bool] = []
    var shouldShowNewGestureInfo: Bool {
        get { shouldShowNewGestureInfoReturns }
        set { shouldShowNewGestureInfoValues.append(newValue) }
    }

    var shouldShowThermostatScheduleInfoReturns: Bool = false
    var shouldShowThermostatScheduleInfoValues: [Bool] = []
    var shouldShowThermostatScheduleInfo: Bool {
        get { shouldShowThermostatScheduleInfoReturns }
        set { shouldShowThermostatScheduleInfoValues.append(newValue) }
    }

    var pushTokenReturns: Data? = nil
    var pushTokenValues: [Data?] = []
    var pushToken: Data? {
        get { pushTokenReturns }
        set { pushTokenValues.append(newValue) }
    }

    var pushTokenLastUpdateReturns: Double = 0
    var pushTokenLastUpdateValues: [Double] = []
    var pushTokenLastUpdate: Double {
        get { pushTokenLastUpdateReturns }
        set { pushTokenLastUpdateValues.append(newValue) }
    }

    var temperatureUnitReturns: TemperatureUnit = .celsius
    var temperatureUnitValues: [TemperatureUnit] = []
    var temperatureUnit: TemperatureUnit {
        get { temperatureUnitReturns }
        set { temperatureUnitValues.append(newValue) }
    }

    var autohideButtonsReturns: Bool = false
    var autohideButtonsValues: [Bool] = []
    var autohideButtons: Bool {
        get { autohideButtonsReturns }
        set { autohideButtonsValues.append(newValue) }
    }

    var showChannelInfoReturns: Bool = false
    var showChannelInfoValues: [Bool] = []
    var showChannelInfo: Bool {
        get { showChannelInfoReturns }
        set { showChannelInfoValues.append(newValue) }
    }

    var showBottomLabelsReturns: Bool = true
    var showBottomLabelsValues: [Bool] = []
    var showBottomLabels: Bool {
        get { showBottomLabelsReturns }
        set { showBottomLabelsValues.append(newValue) }
    }

    var channelHeightReturns: ChannelHeight = .height150
    var channelHeightValues: [ChannelHeight] = []
    var channelHeight: ChannelHeight {
        get { channelHeightReturns }
        set { channelHeightValues.append(newValue) }
    }

    var showOpeningPercentReturns: Bool = false
    var showOpeningPercentValues: [Bool] = []
    var showOpeningPercent: Bool {
        get { showOpeningPercentReturns }
        set { showOpeningPercentValues.append(newValue) }
    }

    var darkModeReturns: DarkModeSetting = .unset
    var darkModeValues: [DarkModeSetting] = []
    var darkMode: DarkModeSetting {
        get { darkModeReturns }
        set { darkModeValues.append(newValue) }
    }
    
    var lockScreenSettingsReturns: LockScreenSettings = LockScreenSettings.DEFAULT
    var lockScreenSettingsValues: [LockScreenSettings] = []
    var lockScreenSettings: LockScreenSettings {
        get { lockScreenSettingsReturns }
        set { lockScreenSettingsValues.append(newValue) }
    }
}
