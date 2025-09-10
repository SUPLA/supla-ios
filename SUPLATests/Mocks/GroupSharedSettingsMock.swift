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
    
extension GroupShared {
    @available(iOS 17.0, *)
    class SettingsMock: Settings {
        
        var actionsMock: FunctionMock<[GroupShared.WidgetAction], [GroupShared.WidgetAction]> = .init()
        var actions: [GroupShared.WidgetAction] {
            get { actionsMock.returns.next() }
            set { actionsMock.set(newValue) }
        }
        
        var channelsMock: FunctionMock<[GroupShared.WidgetChannel], [GroupShared.WidgetChannel]> = .init()
        var channels: [GroupShared.WidgetChannel] {
            get { channelsMock.returns.next() }
            set { channelsMock.set(newValue) }
        }
        
        var temperatureUnitMock: FunctionMock<TemperatureUnit, TemperatureUnit> = .init()
        var temperatureUnit: TemperatureUnit {
            get { temperatureUnitMock.returns.next() }
            set { temperatureUnitMock.set(newValue) }
        }
        
        var temperaturePrecisionMock: FunctionMock<Int, Int> = .init()
        var temperaturePrecision: Int {
            get { temperaturePrecisionMock.returns.next() }
            set { temperaturePrecisionMock.set(newValue) }
        }
    }
}
