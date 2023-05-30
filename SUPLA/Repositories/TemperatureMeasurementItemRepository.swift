//
//  TemperatureMeasurementItemRepository.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol TemperatureMeasurementItemRepository: RepositoryProtocol where T == SATemperatureMeasurementItem {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class TemperatureMeasurementItemRepositoryImpl: Repository<SATemperatureMeasurementItem>, TemperatureMeasurementItemRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SATemperatureMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
