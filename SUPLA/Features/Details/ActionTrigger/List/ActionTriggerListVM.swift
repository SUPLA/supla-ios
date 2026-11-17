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
import SwiftUI

extension ActionTriggerListFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton<ObserveChannelWithChildren.UseCase> private var observeChannelWithChildrenUseCase
        @Singleton<ProvideChannelDetailTypeUseCase> private var provideDetailTypeUseCase
        @Singleton<GlobalSettings> private var globalSettings

        private let itemBundle: ItemBundle
        private var actionTriggerDestinations: [Int32: (channel: ChannelChild, pages: [DetailPage])] = [:]

        init(itemBundle: ItemBundle) {
            self.itemBundle = itemBundle
            super.init(state: ViewState())
        }

        override func onViewCreated() {
            state.scale = CGFloat(globalSettings.channelHeight.factor())
            observeChannelWithChildrenUseCase.invoke(remoteId: itemBundle.remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handle(channel: $0) })
                .disposed(by: disposeBag)
        }

        func destination(for remoteId: Int32) -> (item: ItemBundle, pages: [DetailPage])? {
            guard let destination = actionTriggerDestinations[remoteId] else { return nil }
            return (destination.channel.channel.item(), destination.pages)
        }

        private func handle(channel channelWithChildren: ChannelWithChildren) {
            var destinations: [Int32: (channel: ChannelChild, pages: [DetailPage])] = [:]
            let relatedChannels: [RelatedChannelData] = channelWithChildren.children.compactMap { child in
                guard child.relationType == .default,
                      child.channel.func == SUPLA_CHANNELFNC_ACTIONTRIGGER,
                      case let .standardDetail(pages)? = provideDetailTypeUseCase.invoke(channelWithChildren: child.withChildren)
                else {
                    return nil
                }

                destinations[child.channel.remote_id] = (child, pages)
                let value = child.channel.value?.asActionTriggerValue()
                return child.toSensorItem(iconsBlock: {
                    ActionTriggerIconsBlock.create(
                        indicatorType: value?.indicatorType,
                        weeklyActive: value?.flags.contains(.weeklyScheduleEnabled),
                        showChannelStateIcon: child.channel.showInfoIcon
                    )
                })
            }
            
            actionTriggerDestinations = destinations
            state.relatedChannels = relatedChannels
        }
    }
}
