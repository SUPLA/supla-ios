//
//  LoadingTimoutManagerMock.swift
//  SUPLATests
//
//  Created by Michał Polański on 21/09/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import RxSwift

@testable import SUPLA

final class LoadingTimeoutManagerMock: LoadingTimeoutManager {
    
    var returns: Disposable = DummyDisposable()
    func watch(stateProvider: @escaping () -> LoadingState?, onTimeout: @escaping () -> Void) -> Disposable {
        returns
    }
    
    
}

final class DummyDisposable: Disposable {
    func dispose() {
    }
}
