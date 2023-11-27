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

protocol GetDeviceConfigUseCase {
    func invoke(deviceId: Int32) -> Observable<RequestResult>
}

final class GetDeviceConfigUseCaseImpl: GetDeviceConfigUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    
    func invoke(deviceId: Int32) -> Observable<RequestResult> {
        Observable.create { observer in
            let suplaClient = self.suplaClientProvider.provide()
            
            var request = TCS_GetDeviceConfigRequest()
            request.DeviceId = deviceId
            request.Fields = SuplaFieldType.allFields
            
            if (suplaClient.getDeviceConfig(&request)) {
                observer.onNext(.success)
            } else {
                observer.onNext(.failure)
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
