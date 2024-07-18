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

protocol GetChannelConfigUseCase {
    func invoke(remoteId: Int32, type: ChannelConfigType) -> Observable<RequestResult>
}

final class GetChannelConfigUseCaseImpl: GetChannelConfigUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    
    func invoke(remoteId: Int32, type: ChannelConfigType) -> Observable<RequestResult> {
        Observable.create { observer in
            let suplaClient = self.suplaClientProvider.provide()
            
            var request: TCS_GetChannelConfigRequest = TCS_GetChannelConfigRequest()
            request.ChannelId = remoteId
            request.ConfigType = type.rawValue
            
            if (suplaClient.getChannelConfig(&request)) {
                observer.onNext(.success)
            } else {
                observer.onNext(.failure)
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

enum ChannelConfigType: UInt8, CaseIterable {
    case defaultConfig = 0
    case weeklyScheduleConfig = 2
    case generalPurposeMeasurement = 3
    case generalPurposeMeter = 4
    case facadeBlind = 5
    
    static func from(value: UInt8) -> ChannelConfigType {
        for configType in ChannelConfigType.allCases {
            if (configType.rawValue == value) {
                return configType
            }
        }
        
        SALog.error("Invalid ChannelConfigType value `\(value)'")
        return .defaultConfig
    }
}
