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

import RxRelay
import RxSwift

private let REFRESH_DELAY_S: Double = 3

extension DimmerDetailFeature {
    class ViewModel: DimmerDetailBase.ViewModel, ViewDelegate {
        @Singleton private var insertColorListItemUseCase: InsertColorListItem.UseCase
        
        init() {
            super.init(state: DimmerDetailBase.ViewState())
        }
        
        override func onSavedColorSelected(color: SavedColor) {
            guard !state.offline else { return }
            
            lastInteractionTime = nil
            state.value = .single(brightness: Int(color.brightness), cct: state.value.cct ?? 0)
            
            if let actionData {
                delayedRgbwActionSubject.sendImmediately(data: actionData)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        }
        
        override func onSaveCurrentColor() {
            guard let remoteId,
                  let type,
                  let brightness = state.value.brightness
            else { return }
            
            guard state.savedColors.count < maxNumberOfItems else {
                showToast { [weak self] in self?.state.showLimitReachedToast = $0 }
                return
            }

            // It's needed to enable immediate update
            lastInteractionTime = nil
            insertColorListItemUseCase.invoke(subject: type, remoteId: remoteId, type: .dimmer, color: brightness.asGrayColor, brightness: Int32(brightness))
                .asDriverWithoutError()
                .drive(onNext: { [weak self] _ in self?.reloadData() })
                .disposed(by: disposeBag)
        }
        
        override func getOriginalButtonIcon(_ value: ChannelState.Value) -> IconResult {
            .originalSuplaIcon(name: value == .on ? .Icons.fncDimmerOn : .Icons.fncDimmerOff)
        }
    }
}
