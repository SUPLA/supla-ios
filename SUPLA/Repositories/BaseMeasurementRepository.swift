/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

import RxSwift

protocol BaseMeasurementRepository<M, E>: RepositoryProtocol {
    associatedtype M: SuplaCloudMeasurement
    associatedtype E: SAMeasurementItem
    
    func deleteAll(remoteId: Int32, profile: AuthProfileItem) -> Observable<Void>
    func findMinTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findMaxTimestamp(remoteId: Int32, profile: AuthProfileItem) -> Observable<TimeInterval?>
    func findCount(remoteId: Int32, profile: AuthProfileItem) -> Observable<Int>
    func getMeasurements(remoteId: Int32, afterTimestamp: TimeInterval) -> Observable<[M]>
    func storeMeasurements(measurements: [M], timestamp: TimeInterval, profile: AuthProfileItem, remoteId: Int32) throws -> TimeInterval
    func fromJson(data: Data) throws -> [M]
}
