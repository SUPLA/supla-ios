//
//  DelayedThermostatActionSubjectMock.swift
//  SUPLATests
//
//  Created by Michał Polański on 21/09/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import RxSwift

@testable import SUPLA

final class DelayedThermostatActionSubjectMock: DelayedThermostatActionSubject {
    var emitParameters: [ThermostatActionData] = []
    func emit(data: ThermostatActionData) {
        emitParameters.append(data)
    }
    
    var sendImmediatelyParameters: [ThermostatActionData] = []
    var sendImmediatelyReturns: Observable<RequestResult> = Observable.empty()
    func sendImmediately(data: ThermostatActionData) -> Observable<RequestResult> {
        sendImmediatelyParameters.append(data)
        return sendImmediatelyReturns
    }
    
    
}
