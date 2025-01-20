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

protocol LoadImpulseCounterMeasurementsUseCase {
    func invoke(remoteId: Int32, startDate: Date?, endDate: Date?) -> Observable<ImpulseCounterMeasurements>
}

extension LoadImpulseCounterMeasurementsUseCase {
    func invoke(remoteId: Int32, startDate: Date) -> Observable<ImpulseCounterMeasurements> {
        invoke(remoteId: remoteId, startDate: startDate, endDate: nil)
    }

    func invoke(remoteId: Int32, endDate: Date) -> Observable<ImpulseCounterMeasurements> {
        invoke(remoteId: remoteId, startDate: nil, endDate: endDate)
    }
}

final class LoadImpulseCounterMeasurementsUseCaseImpl: LoadImpulseCounterMeasurementsUseCase {
    
    @Singleton<ImpulseCounterMeasurementItemRepository> private var impulseCounterMeasurementItemRepository
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<UserStateHolder> private var userStateHolder
    @Singleton<DateProvider> private var dateProvider
    
    func invoke(remoteId: Int32, startDate: Date?, endDate: Date?) -> Observable<ImpulseCounterMeasurements> {
        profileRepository.getActiveProfile()
            .flatMapFirst { profile in
                self.findMeasurements(profile: profile, remoteId: remoteId, startDate: startDate, endDate: endDate)
            }
            .flatMapFirst { measurements in
                self.readChannelByRemoteIdUseCase.invoke(remoteId: remoteId).map { ($0, measurements) }
            }.map { channel, measurements in
                ImpulseCounterMeasurements(counter: measurements.map { $0.calculated_value }.sum())
            }
    }
    
    private func findMeasurements(profile: AuthProfileItem, remoteId: Int32, startDate: Date?, endDate: Date?) -> Observable<[SAImpulseCounterMeasurementItem]> {
        if let serverId = profile.server?.id {
            return self.impulseCounterMeasurementItemRepository.findMeasurements(
                remoteId: remoteId,
                serverId: serverId,
                startDate: startDate ?? Date(timeIntervalSince1970: 0),
                endDate: endDate ?? dateProvider.currentDate()
            )
        } else {
            return Observable.just([])
        }
    }
}
