//
//  DeviceConfigEventsManagerMock.swift
//  SUPLATests
//
//  Created by Michał Polański on 20/11/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

@testable import SUPLA
import RxSwift

final class DeviceConfigEventsManagerMock: DeviceConfigEventsManager {
    
    var observeConfigParameters: [Int32] = []
    var observeConfigReturns: Observable<DeviceConfigEvent> = .empty()
    func observeConfig(id: Int32) -> Observable<DeviceConfigEvent> {
        observeConfigParameters.append(id)
        return observeConfigReturns
    }
    
    var emitConfigParameters: [(UInt8, TSCS_DeviceConfig)] = []
    func emitConfig(result: UInt8, config: TSCS_DeviceConfig) {
        emitConfigParameters.append((result, config))
    }
}
