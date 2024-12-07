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

class ChannelListViewModel: BaseTableViewModel<ChannelListViewState, ChannelListViewEvent> {
    @Singleton<CreateProfileChannelsListUseCase> private var createProfileChannelsListUseCase
    @Singleton<SwapChannelPositionsUseCase> private var swapChannelPositionsUseCase
    @Singleton<ProvideChannelDetailTypeUseCase> private var provideDetailTypeUseCase
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<ChannelBaseActionUseCase> private var channelBaseActionUseCase
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase

    override init() {
        super.init()
        
        updateEventsManager.observeChannelsUpdate()
            .subscribe(
                onNext: { self.reloadTable() }
            )
            .disposed(by: self)
    }
    
    override func defaultViewState() -> ChannelListViewState { ChannelListViewState() }
    
    override func reloadTable() {
        createProfileChannelsListUseCase.invoke()
            .subscribe(onNext: { self.listItems.accept($0) })
            .disposed(by: self)
    }
    
    override func swapItems(firstItem: Int32, secondItem: Int32, locationCaption: String) {
        swapChannelPositionsUseCase
            .invoke(firstRemoteId: firstItem, secondRemoteId: secondItem, locationCaption: locationCaption)
            .subscribe(onNext: { self.reloadTable() })
            .disposed(by: self)
    }
    
    override func onClicked(onItem item: Any) {
        guard let item = item as? SAChannel else { return }
        
        readChannelWithChildrenUseCase
            .invoke(remoteId: item.remote_id)
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] in self?.handleClickedItem($0) }
            )
            .disposed(by: self)
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .channel }
    
    func onButtonClicked(buttonType: CellButtonType, data: Any?) {
        if let channelWithChildren = data as? ChannelWithChildren {
            channelBaseActionUseCase.invoke(channelWithChildren.channel, buttonType)
                .asDriverWithoutError()
                .drive()
                .disposed(by: self)
        }
    }
    
    func onNoContentButtonClicked() {
        send(event: .showAddWizard)
    }
    
    private func handleClickedItem(_ channelWithChildren: ChannelWithChildren) {
        let channel = channelWithChildren.channel
        if (!isAvailableInOffline(channel, children: channelWithChildren.children) && !channel.isOnline()) {
            return // do not open details for offline channels
        }
        
        guard
            let detailType = provideDetailTypeUseCase.invoke(channelWithChildren: channelWithChildren)
        else {
            return
        }
        
        switch (detailType) {
        case let .legacy(type: legacyDetailType):
            send(event: .navigateToDetail(legacy: legacyDetailType, channelBase: channel))
        case let .switchDetail(pages):
            send(event: .navigateToSwitchDetail(item: channel.item(), pages: pages))
        case let .thermostatDetail(pages):
            send(event: .navigateToThermostatDetail(item: channel.item(), pages: pages))
        case let .thermometerDetail(pages):
            send(event: .navigateToThermometerDetail(item: channel.item(), pages: pages))
        case let .gpmDetail(pages):
            send(event: .navigateToGpmDetail(item: channel.item(), pages: pages))
        case let .windowDetail(pages):
            send(event: .navigateToRollerShutterDetail(item: channel.item(), pages: pages))
        case let .electricityMeterDetail(pages):
            send(event: .navigateToElectricityMeterDetail(item: channel.item(), pages: pages))
        case let .impulseCounterDetail(pages):
            send(event: .navigateToImpulseCounterDetail(item: channel.item(), pages: pages))
        }
    }
}

enum ChannelListViewEvent: ViewEvent {
    case navigateToDetail(legacy: LegacyDetailType, channelBase: SAChannelBase)
    case navigateToSwitchDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToThermostatDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToThermometerDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToGpmDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToRollerShutterDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToElectricityMeterDetail(item: ItemBundle, pages: [DetailPage])
    case navigateToImpulseCounterDetail(item: ItemBundle, pages: [DetailPage])
    case showAddWizard
}

struct ChannelListViewState: ViewState {}
