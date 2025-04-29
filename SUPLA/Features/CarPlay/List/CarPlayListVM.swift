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
    
extension CarPlayListFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton<UpdateCarPlayOrder.UseCase> private var updateCarPlayOrderUseCase
        @Singleton<ReadCarPlayItems.UseCase> private var readCarPlayItemsUseCase
        @Singleton<CarPlayRefresh.UseCase> private var carPlayRefreshUseCase
        @Singleton<GlobalSettings> private var settings
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewWillAppear() {
            state.playMessages = settings.carPlayVoiceMessages
            readCarPlayItemsUseCase.invoke()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] items in
                        self?.state.items = items
                    }
                )
                .disposed(by: disposeBag)
        }
        
        func onVoiceMessagesChanged(value: Bool) {
            settings.carPlayVoiceMessages = value
        }
        
        func onMoved(from: IndexSet, to: Int) {
            var items = state.items
            items.move(fromOffsets: from, toOffset: to)
            
            var order: Int32 = 0
            updateCarPlayOrderUseCase.invoke(
                items: items.map {
                    order += 1
                    return UpdateCarPlayOrder.Item(id: $0.id, order: order)
                }
            )
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] _ in
                    self?.onViewWillAppear()
                    self?.carPlayRefreshUseCase.post(.refresh)
                }
            )
            .disposed(by: disposeBag)
        }
    }
}
