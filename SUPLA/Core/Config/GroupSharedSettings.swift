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

import AppIntents

struct GroupShared {
    enum Groups {
        static let iOS = "group.org.supla.ios"
    }
    
    protocol Settings: AnyObject {
        
        @available(iOS 17.0, *)
        var actions: [WidgetAction] { get set }
        @available(iOS 17.0, *)
        var channels: [WidgetChannel] { get set }
        
        var temperatureUnit: TemperatureUnit { get set }
        var temperaturePrecision: Int { get set }
    }
    
    final class Implementation: Settings {
        let userDefaults = UserDefaults(suiteName: Groups.iOS)
        
        private let actionsKey = "GroupShared.actions"
        @available(iOS 17.0, *)
        var actions: [WidgetAction] {
            get {
                WidgetAction.fromJson(userDefaults?.string(forKey: actionsKey)) ?? []
            }
            set {
                userDefaults?.setValue(newValue.toJson(), forKey: actionsKey)
            }
        }
        
        private let channelsKey = "GroupShared.channels"
        @available(iOS 17.0, *)
        var channels: [WidgetChannel] {
            get {
                WidgetChannel.fromJson(userDefaults?.string(forKey: channelsKey)) ?? []
            }
            set {
                userDefaults?.setValue(newValue.toJson(), forKey: channelsKey)
            }
        }
        
        private let temperatureUnitKey = "GroupShared.temperatureUnit"
        var temperatureUnit: TemperatureUnit {
            get { TemperatureUnit(rawValue: userDefaults?.string(forKey: temperatureUnitKey) ?? "") ?? .celsius }
            set { userDefaults?.set(newValue.rawValue, forKey: temperatureUnitKey) }
        }
        
        private let temperaturePrecisionKey = "GroupShared.temperaturePrecision"
        var temperaturePrecision: Int {
            get {
                guard let precision = userDefaults?.integer(forKey: temperaturePrecisionKey) else { return 1 }
                return precision < 1 ? 1 : precision
            }
            set { userDefaults?.set(newValue, forKey: temperaturePrecisionKey) }
        }
    }
}

private extension Encodable {
    func toJson() -> String? {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(self) {
            return String(data: jsonData, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
}
