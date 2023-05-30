//
//  ImpulseCounterMeasurementItemRepository.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol ImpulseCounterMeasurementItemRepository: RepositoryProtocol where T == SAImpulseCounterMeasurementItem {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class ImpulseCounterMeasurementItemRepositoryImpl: Repository<SAImpulseCounterMeasurementItem>, ImpulseCounterMeasurementItemRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAImpulseCounterMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
