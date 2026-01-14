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
import SharedCore

struct ExecuteRgbAction {
    protocol UseCase {
        func invoke(
            type: SubjectType,
            remoteId: Int32,
            brightness: Int,
            color: HsvColor,
            onOff: Bool,
            vibrate: Bool,
            dimmerCct: Int
        ) -> Observable<RequestResult>
    }

    static func instance() -> UseCase { Implementation() }

    private class Implementation: UseCase {
        @Singleton<SuplaClientProvider> private var suplaClientProvider
        @Singleton<VibrationService> private var vibrationService

        func invoke(
            type: SubjectType,
            remoteId: Int32,
            brightness: Int,
            color: HsvColor,
            onOff: Bool,
            vibrate: Bool,
            dimmerCct: Int
        ) -> Observable<RequestResult> {
            Observable.create { observable in
                let result = self.suplaClientProvider.provide()?.executeAction(
                    parameters: .rgbw(
                        subjectType: type,
                        subjectId: remoteId,
                        brightness: Int8(brightness),
                        colorBrightness: Int8(color.valueAsPercentage),
                        color: UInt32(color.fullBrightnessColor.argbInt & 0xFFFFFF),
                        colorRandom: false,
                        onOff: onOff,
                        dimmerCct: Int8(dimmerCct)
                    )
                )

                if (result == true) {
                    if (vibrate) {
                        self.vibrationService.vibrate()
                    }
                    observable.on(.next(.success))
                } else {
                    observable.on(.next(.failure))
                }
                observable.on(.completed)

                return Disposables.create {}
            }
        }
    }
}

extension ExecuteRgbAction.UseCase {
    func invoke(
        type: SubjectType,
        remoteId: Int32,
        brightness: Int,
        color: HsvColor,
        onOff: Bool,
        dimmerCct: Int
    ) -> Observable<RequestResult> {
        invoke(
            type: type,
            remoteId: remoteId,
            brightness: brightness,
            color: color,
            onOff: onOff,
            vibrate: true,
            dimmerCct: dimmerCct
        )
    }
}
