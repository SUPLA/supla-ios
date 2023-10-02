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

protocol GlobalSettings {
    
    var anyAccountRegistered: Bool { get set }
    var newGestureInfoShown: Bool { get set }
    var shouldShowNewGestureInfo: Bool { get set }
    var pushToken: Data? { get set }
    var pushTokenLastUpdate: Double { get set }
    
    var temperatureUnit: TemperatureUnit { get set }
    var autohideButtons: Bool { get set }
    var showChannelInfo: Bool { get set }
    var channelHeight: ChannelHeight { get set }
    var showOpeningPercent: Bool { get set }
}

class GlobalSettingsImpl: GlobalSettings {
    
    @Singleton<RuntimeConfig> private var runtimeConfig
    
    let defaults = UserDefaults.standard
    
    init() {
        defaults.register(defaults: [
            showChannelInfoKey: true,
            shouldShowNewGestureInfoKey: false
        ])
    }
    
    private let anyAccountRegisteredKey = "GlobalSettings.anyAccountRegisteredKey"
    var anyAccountRegistered: Bool {
        get { defaults.bool(forKey: anyAccountRegisteredKey) }
        set { defaults.set(newValue, forKey: anyAccountRegisteredKey) }
    }
    
    private let newGestureInfoShownKey = "GlobalSettings.newGestureInfoShownKey"
    var newGestureInfoShown: Bool {
        get { defaults.bool(forKey: newGestureInfoShownKey) }
        set { defaults.set(newValue, forKey: newGestureInfoShownKey) }
    }
    
    private let shouldShowNewGestureInfoKey = "GlobalSettings.shouldShowNewGestureInfo"
    var shouldShowNewGestureInfo: Bool {
        get { defaults.bool(forKey: shouldShowNewGestureInfoKey) }
        set { defaults.set(newValue, forKey: shouldShowNewGestureInfoKey) }
    }
    
    private let pushTokenKey = "GlobalSettings.pushTokenKey"
    var pushToken: Data? {
        get { defaults.data(forKey: pushTokenKey) }
        set { defaults.set(newValue, forKey: pushTokenKey) }
    }
    
    private let pushTokenLastUpdateKey = "GlobalSettings.pushTokenLastUpdateKey"
    var pushTokenLastUpdate: Double {
        get { defaults.double(forKey: pushTokenLastUpdateKey) }
        set { defaults.set(newValue, forKey: pushTokenLastUpdateKey) }
    }
    
    private let temperatureUnitKey = "supla_config_temp_unit"
    var temperatureUnit: TemperatureUnit {
        get { TemperatureUnit(rawValue: defaults.string(forKey: temperatureUnitKey) ?? "") ?? .celsius }
        set { defaults.set(newValue.rawValue, forKey: temperatureUnitKey) }
    }
    
    private let keepButtonsVisibleKey = "supla_config_buttons_keep_visible"
    var autohideButtons: Bool {
        get { !defaults.bool(forKey: keepButtonsVisibleKey) }
        set { defaults.set(!newValue, forKey: keepButtonsVisibleKey) }
    }
    
    private let showChannelInfoKey = "supla_config_show_channel_info"
    var showChannelInfo: Bool {
        get { return defaults.bool(forKey: showChannelInfoKey) }
        set {
            if (showChannelInfo != newValue) {
                runtimeConfig.emitPreferenceChange(
                    scaleFactor: channelHeight.factor(),
                    showChannelInfo: showChannelInfo
                )
            }
            defaults.set(newValue, forKey: showChannelInfoKey)
        }
    }
    
    private let channelHeightKey = "supla_config_channel_height"
    var channelHeight: ChannelHeight {
        get {
            ChannelHeight(rawValue: defaults.integer(forKey: channelHeightKey)) ?? .height100
        }
        set {
            if (channelHeight != newValue) {
                runtimeConfig.emitPreferenceChange(
                    scaleFactor: newValue.factor(),
                    showChannelInfo: showChannelInfo
                )
            }
            defaults.set(newValue.rawValue, forKey: channelHeightKey)
        }
    }
    
    private let showOpeningPercentKey = "supla_config_show_opening_percent"
    var showOpeningPercent: Bool {
        get { return defaults.bool(forKey: showOpeningPercentKey) }
        set { defaults.set(newValue, forKey: showOpeningPercentKey) }
    }
}

@objc class GlobalSettingsLegacy: NSObject {
    
    @Singleton<GlobalSettings> private var settings
    
    @objc
    var autohideButtons: Bool {
        get { settings.autohideButtons }
    }
    
    @objc
    var showOpeningPercent: Bool {
        get { settings.showOpeningPercent }
    }
    
    @objc
    var channelHeightFactor: Float {
        get { settings.channelHeight.factor() }
    }
    
    @objc
    var currentTemperaturePresenter: TemperaturePresenter {
        return TemperaturePresenter(
            temperatureUnit: settings.temperatureUnit,
            locale: .autoupdatingCurrent,
            shouldDisplayUnit: true
        )
    }
}
