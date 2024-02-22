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

final class DepthValueProviderMock: DepthValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class DistanceValueProviderMock: DistanceValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class GpmValueProviderMock: GpmValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class HumidityValueProviderMock: HumidityValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class PressureValueProviderMock: PressureValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class RainValueProviderMock: RainValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class ThermometerAndHumidityValueProviderMock: ThermometerAndHumidityValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class ThermometerValueProviderMock: ThermometerValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class WeightValueProviderMock: WeightValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}

final class WindValueProviderMock: WindValueProvider {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }

    var valueParameters: [(SAChannel, ValueType)] = []
    var valueReturns: Any = false
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        valueParameters.append((channel, valueType))
        return valueReturns
    }
}
