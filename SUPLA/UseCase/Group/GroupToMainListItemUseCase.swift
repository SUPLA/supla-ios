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

import CoreGraphics

struct GroupToMainListItem {
    protocol UseCase {
        func invoke(_ group: SAChannelGroup) -> MainListItem?
        func invoke(_ group: SAChannelGroup, location: _SALocation) -> MainListItem
    }

    final class Implementation: UseCase {
        func invoke(_ group: SAChannelGroup) -> MainListItem? {
            guard let location = group.location else { return nil }
            return invoke(group, location: location)
        }

        func invoke(_ group: SAChannelGroup, location: _SALocation) -> MainListItem {
            @Singleton<GetCaptionUseCase> var getCaptionUseCase
            @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
            @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
            @Singleton<GetGroupActivePercentageUseCase> var getGroupActivePercentageUseCase
            @Singleton<GetChannelActionStringUseCase> var getChannelActionStringUseCase

            let function = SuplaFunction.companion.from(value: group.func)
            let activePercentage = getGroupActivePercentageUseCase.invoke(group).clamped(to: 0...100)
            let state = getChannelBaseStateUseCase.invoke(channelBase: group)
            let base = DefaultListItem(
                remoteId: group.remote_id,
                profileId: group.profile.id,
                userCaption: group.caption ?? "",
                function: function,
                locationCaption: location.caption ?? "",
                locationId: location.location_id?.int32Value ?? 0,
                status: .group(
                    onlinePercentage: CGFloat(group.online) / 100,
                    activePercentage: CGFloat(activePercentage) / 100
                ),
                title: getCaptionUseCase.invoke(data: group.shareableBase).string,
                icon: getChannelBaseIconUseCase.stateIcon(group, state: state),
                value: nil,
                leftButtonTitle: getChannelActionStringUseCase.leftButton(function: group.func.suplaFuntion)?.value,
                rightButtonTitle: getChannelActionStringUseCase.rightButton(function: group.func.suplaFuntion)?.value
            )

            return .group(base)
        }
    }
}
