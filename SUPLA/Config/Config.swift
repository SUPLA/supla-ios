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

class Config: NSObject {

    let ChannelHeightDidChangeNotification = Notification.Name("ChannelHeightDidChange")
    
    private let kChannelHeight = "supla_config_channel_height"
    private let kTemperatureUnit = "supla_config_temp_unit"
    private let kButtonKeepVisible = "supla_config_buttons_keep_visible"
    private let kShowChannelInfo = "supla_config_show_channel_info"
    private let kShowOpeningPercent = "supla_config_show_opening_percent"

    // read-only accessors for "legacy" Objective-C code
    
    /**
     returns channel height scale factor (i.e. 0.6, 1.0, 1.5)
     */
    @objc
    var channelHeightFactor: Float {
        return Float(channelHeight.rawValue) / 100.0
    }
    
    /**
        returns temperature presenter object matching current user settings
     */
    @objc
    var currentTemperaturePresenter: TemperaturePresenter {
        return TemperaturePresenter(temperatureUnit: temperatureUnit,
                                    locale: .autoupdatingCurrent,
                                    shouldDisplayUnit: true)
    }
    
    /**
        boolean flag indicating if channel buttons should be automatically hidden after usage
     */
    @objc
    var autohideButtons: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: kButtonKeepVisible)
        }
        
        set {
            UserDefaults.standard.set(!newValue, forKey: kButtonKeepVisible)
        }
    }
    
    @objc
    var showChannelInfo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kShowChannelInfo)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: kShowChannelInfo)
        }
    }

    @objc
    var showOpeningPercent: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kShowOpeningPercent)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: kShowOpeningPercent)
        }
    }
    
    // "full" accessors for swift code
    var channelHeight: ChannelHeight {
        get {
            ChannelHeight(rawValue: UserDefaults.standard.integer(forKey: kChannelHeight)) ?? .height100
        }
        
        set {
            let change = channelHeight != newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: kChannelHeight)
            if change {
                NotificationCenter.default.post(name: ChannelHeightDidChangeNotification,
                                                object: self, userInfo: nil)
            }
        }
    }
    var temperatureUnit: TemperatureUnit {
        get {
            return TemperatureUnit(rawValue: UserDefaults.standard.string(forKey: kTemperatureUnit) ?? "") ?? .celsius
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kTemperatureUnit)
        }
    }
    
    override init() {
        super.init()
        UserDefaults.standard.register(defaults: [kShowChannelInfo: true])
    }
}

enum ChannelHeight: Int, CaseIterable {
    case height60 = 60
    case height100 = 100
    case height150 = 150
}
enum TemperatureUnit: String, CaseIterable {
    case celsius
    case fahrenheit
}
extension TemperatureUnit {
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}
