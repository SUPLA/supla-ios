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
    
    override func swapItems(firstItem: Int32, secondItem: Int32, locationId: Int32) {
        swapChannelPositionsUseCase
            .invoke(firstRemoteId: firstItem, secondRemoteId: secondItem, locationId: Int(locationId))
            .subscribe(onNext: { self.reloadTable() })
            .disposed(by: self)
    }
    
    override func onClicked(onItem item: Any) {
        guard
            let item = item as? SAChannelBase,
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
}

enum ChannelListViewEvent: ViewEvent {
    case navigateToDetail(legacy: LegacyDetailType, channelBase: SAChannelBase)
}

struct ChannelListViewState: ViewState {}
