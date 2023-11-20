//
//  SuplaDeviceConfig+Mock.swift
//  SUPLATests
//
//  Created by Michał Polański on 20/11/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

@testable import SUPLA

extension SuplaDeviceConfig {
    
    static func mock(deviceId: Int32 = 123, availableFields: [SuplaFieldType] = [], fields: [any SuplaField] = []) -> SuplaDeviceConfig {
        SuplaDeviceConfig(deviceId: deviceId, availableFields: availableFields, fields: fields)
    }
}
