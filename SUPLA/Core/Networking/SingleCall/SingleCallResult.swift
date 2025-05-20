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

enum SingleCallResult {
    case temperature(Double)
    case humidity(Double)
    case temperatureAndHumidity(temperature: Double, humidity: Double)
    case offline
    case error(errorCode: Int)
}

private let thermometerParser = ThermometerValueParser()
private let humidityParser = HumidityValueParser()
private let humidityAndTemperatureParser = HumidityAndTemperatureValueParser()

extension SingleCallResult {
    static func from(valueResult: TSC_GetChannelValueResult) -> SingleCallResult {
        if (valueResult.ResultCode == SUPLA_RESULTCODE_CHANNEL_IS_OFFLINE) {
            return .offline
        }
        if (valueResult.ResultCode != SUPLA_RESULTCODE_TRUE) {
            return .error(errorCode: Int(valueResult.ResultCode))
        }
        var value = valueResult

        let data = Data(bytes: &value.Value, count: Int(SUPLA_CHANNELVALUE_SIZE))

        return switch valueResult.Function.suplaFunction() {
        case .thermometer: thermometerParser.parse(data)
        case .humidityAndTemperature: humidityAndTemperatureParser.parse(data)
        case .humidity: humidityParser.parse(data)
        default: .error(errorCode: -100000 - Int(valueResult.Function))
        }
    }
}

class ThermometerValueParser: DoubleValueParser {
    func parse(_ data: Data?) -> SingleCallResult {
        return .temperature(asDoubleValue(data) ?? ThermometerValueParser.unknownValue)
    }

    static let unknownValue: Double = -273.0
}

class HumidityValueParser: IntValueParser {
    func parse(_ data: Data?) -> SingleCallResult {
        if let value = asIntValue(data) {
            return .humidity(Double(value) / 1000.0)
        } else {
            return .humidity(HumidityValueParser.unknownValue)
        }
    }

    static let unknownValue: Double = -1
}

class HumidityAndTemperatureValueParser: IntValueParser {
    func parse(_ data: Data?) -> SingleCallResult {
        let temperature = asIntValue(data)?.div(1000.0)
        let humidity = asIntValue(data, startingFromByte: 4)?.div(1000.0)

        return .temperatureAndHumidity(
            temperature: temperature ?? ThermometerValueParser.unknownValue,
            humidity: humidity ?? HumidityValueParser.unknownValue
        )
    }
}

private extension Int {
    func div(_ divider: Double) -> Double {
        Double(self) / divider
    }
}
