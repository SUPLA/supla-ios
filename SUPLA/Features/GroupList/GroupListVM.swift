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

class GroupListViewModel: BaseTableViewModel<GroupListViewState, GroupListViewEvent> {
    @Singleton<CreateProfileGroupsListUseCase> private var createProfileGroupsListUseCase
    @Singleton<SwapGroupPositionsUseCase> private var swapGroupPositionsUseCase
    @Singleton<ProvideGroupDetailTypeUseCase> private var provideDetailTypeUseCase
    @Singleton<UpdateEventsManager> private var updateEventsManager
    @Singleton<LoadActiveProfileUrlUseCase> private var loadActiveProfileUrlUseCase
    
    override init() {
        super.init()
        
        updateEventsManager.observeGroupsUpdate()
            .subscribe(
                onNext: { self.reloadTable() }
            )
            .disposed(by: self)
    }
    
    override func defaultViewState() -> GroupListViewState { GroupListViewState() }
    
    override func reloadTable() {
        createProfileGroupsListUseCase.invoke()
            .subscribe(onNext: { self.listItems.accept($0) })
            .disposed(by: self)
    }
    
    override func swapItems(firstItem: Int32, secondItem: Int32, locationCaption: String) {
        swapGroupPositionsUseCase
            .invoke(firstRemoteId: firstItem, secondRemoteId: secondItem, locationCaption: locationCaption)
            .subscribe(onNext: { self.reloadTable() })
            .disposed(by: self)
    }
    
    override func onClicked(onItem item: Any) {
        guard let item = item as? SAChannelGroup else { return }
        
        if (!isAvailableInOffline(item) && !item.isOnline()) {
            return // do not open details for offline channels
        }
        
        guard
            let detailType = provideDetailTypeUseCase.invoke(group: item)
        else {
            return
        }
        
        switch (detailType) {
        case let .legacy(type: legacyDetailType):
            send(event: .navigateToDetail(legacy: legacyDetailType, channelBase: item))
        case let .windowDetail(pages):
            send(event: .naviagetToRollerShutterDetail(item: item.item(), pages: pages))
        default: break
        }
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .group }
    
    func onNoContentButtonClicked() {
        loadActiveProfileUrlUseCase.invoke()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] url in
                    self?.send(event: .open(url: url.url))
                }
            )
            .disposed(by: self)
    }
}

enum GroupListViewEvent: ViewEvent {
    case navigateToDetail(legacy: LegacyDetailType, channelBase: SAChannelBase)
    case naviagetToRollerShutterDetail(item: ItemBundle, pages: [DetailPage])
    case open(url: URL)
}

struct GroupListViewState: ViewState {}
