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

import Foundation
import RxSwift

struct ObserveChannelWithChildren {
    protocol UseCase {
        func invoke(remoteId: Int32) -> Observable<ChannelWithChildren>
    }

    final class Implementation: UseCase {
        @Singleton<ObserveChannelsTreeSnapshot.UseCase> private var observeChannelsTreeSnapshotUseCase

        func invoke(remoteId: Int32) -> Observable<ChannelWithChildren> {
            observeChannelsTreeSnapshotUseCase.invoke()
                .compactMap { $0.channelsWithChildren[remoteId] }
                .map { channelWithChildren in
                    Emission(
                        value: channelWithChildren,
                        signature: ChannelWithChildrenSignature(channelWithChildren)
                    )
                }
                .distinctUntilChanged { $0.signature == $1.signature }
                .map(\.value)
        }

        private struct Emission {
            let value: ChannelWithChildren
            let signature: ChannelWithChildrenSignature
        }
    }
}
