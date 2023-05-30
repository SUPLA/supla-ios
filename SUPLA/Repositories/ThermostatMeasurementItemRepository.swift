//
//  ThermostatMeasurementItemRepository.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol ThermostatMeasurementItemRepository: RepositoryProtocol where T == SAThermostatMeasurementItem {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class ThermostatMeasurementItemRepositoryImpl: Repository<SAThermostatMeasurementItem>, ThermostatMeasurementItemRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAThermostatMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
