//
//  TempHumidityMeasurementItem.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol TempHumidityMeasurementItemRepository: RepositoryProtocol where T == SATempHumidityMeasurementItem {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class TempHumidityMeasurementItemRepositoryImpl: Repository<SATempHumidityMeasurementItem>, TempHumidityMeasurementItemRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SATempHumidityMeasurementItem.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
