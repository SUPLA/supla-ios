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

enum TiltingDetails: Equatable {
    case unknown
    case different
    case similar(tilt0Angle: UInt16, tilt100Angle: UInt16, tiltControlType: SuplaTiltControlType)
}

protocol ReadGroupTiltingDetailsUseCase {
    func invoke(remoteId: Int32) -> Observable<TiltingDetails>
}

final class ReadGroupTiltingDetailsUseCaseImpl: ReadGroupTiltingDetailsUseCase {
    @Singleton<ChannelGroupRelationRepository> private var groupRelationRepository
    @Singleton<ChannelConfigRepository> private var channelConfigRepository

    func invoke(remoteId: Int32) -> Observable<TiltingDetails> {
        Observable.create { observer in
            let relations = self.groupRelationRepository
                .getRelations(forGroup: remoteId)
                .subscribeSynchronous(defaultValue: [])
            
            if (relations.isEmpty) {
                observer.onNext(.unknown)
                observer.onCompleted()
                return Disposables.create()
            }

            let detail: TiltingDetails? = relations
                .map { relation in
                    self.channelConfigRepository
                        .getConfig(channelRemoteId: relation.channel_id)
                        .subscribeSynchronous(defaultValue: nil)
                }
                .reduce(nil) { acc, config in
                    let details = config.toTiltingDetails()

                    if (acc == .unknown || details == nil) {
                        return .unknown
                    } else if (acc == .different) {
                        return .different
                    } else if (acc == nil) {
                        return details
                    } else if (acc != details) {
                        return .different
                    } else {
                        return details
                    }
                }

            observer.onNext(detail!)
            observer.onCompleted()

            return Disposables.create {}
        }
    }
}

private extension SAChannelConfig? {
    func toTiltingDetails() -> TiltingDetails? {
        guard let self = self,
              let suplaConfig = self.configAsSuplaConfig() as? SuplaChannelFacadeBlindConfig
        else { return nil }

        return .similar(tilt0Angle: suplaConfig.tilt0Angle, tilt100Angle: suplaConfig.tilt100Angle, tiltControlType: suplaConfig.type)
    }
}
