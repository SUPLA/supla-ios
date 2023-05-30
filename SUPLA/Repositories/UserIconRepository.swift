//
//  UserIconRepository.swift
//  SUPLA
//
//  Created by Michał Polański on 30/05/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation
import RxSwift

protocol UserIconRepository: RepositoryProtocol where T == SAUserIcon {
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void>
}

final class UserIconRepositoryImpl: Repository<SAUserIcon>, UserIconRepository {
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAll(SAUserIcon.fetchRequest().filtered(by: NSPredicate(format: "profile = %@", profile)))
    }
}
