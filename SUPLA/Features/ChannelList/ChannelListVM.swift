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
    @Singleton<ProvideDetailTypeUseCase> private var provideDetailTypeUseCase
    @Singleton<ListsEventsManager> private var listsEventsManager
    
    override init() {
        super.init()
        
        listsEventsManager.observeChannelUpdates()
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
        
        if (!isAvailableInOffline(item) && !item.isOnline()) {
            return // do not open details for offline channels
        }
        
        guard
            let detailType = provideDetailTypeUseCase.invoke(channelBase: item)
        else {
            return
        }
        
        switch (detailType) {
        case let .legacy(type: legacyDetailType):
            send(event: .navigateToDetail(legacy: legacyDetailType, channelBase: item))
            break
        default:
            break
        }
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .channel }
    
    private func isAvailableInOffline(_ channel: SAChannel) -> Bool {
        switch(channel.func) {
        case SUPLA_CHANNELFNC_THERMOMETER,
            SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            SUPLA_CHANNELFNC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_GAS_METER,
            SUPLA_CHANNELFNC_IC_WATER_METER,
            SUPLA_CHANNELFNC_IC_HEAT_METER:
            return true
        case SUPLA_CHANNELFNC_LIGHTSWITCH,
            SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_STAIRCASETIMER:
            switch (channel.value?.sub_value_type) {
            case Int16(SUBV_TYPE_IC_MEASUREMENTS),
                Int16(SUBV_TYPE_ELECTRICITY_MEASUREMENTS):
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

enum ChannelListViewEvent: ViewEvent {
    case navigateToDetail(legacy: LegacyDetailType, channelBase: SAChannelBase)
}

struct ChannelListViewState: ViewState {}
