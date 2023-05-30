//
//  ElectricityMeasurementItemRepository.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol ElectricityMeasurementItemRepository: RepositoryProtocol where T == SAElectricityMeasurementItem {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class ElectricityMeasurementItemRepositoryImpl: Repository<SAElectricityMeasurementItem>, ElectricityMeasurementItemRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAElectricityMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
