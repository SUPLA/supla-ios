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

extension DimmerCctDetailFeature {
    class ViewModel: DimmerDetailBase.ViewModel, ViewDelegate {
        @Singleton private var insertColorListItemUseCase: InsertColorListItem.UseCase
        
        init() {
            super.init(state: DimmerDetailBase.ViewState())
        }
        
        override func onSavedColorSelected(color: SavedColor) {
            guard !state.offline else { return }
            
            lastInteractionTime = nil
            state.value = .single(brightness: Int(color.brightness), cct: color.color)
            
            if let actionData {
                delayedRgbwActionSubject.sendImmediately(data: actionData)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        }
        
        override func onSaveCurrentColor() {
            guard let remoteId,
                  let type,
                  let brightness = state.value.brightness,
                  let cct = state.value.cct
            else { return }
            
            guard state.savedColors.count < 10 else {
                showToast { [weak self] in self?.state.showLimitReachedToast = $0 }
                return
            }

            // It's needed to enable immediate update
            lastInteractionTime = nil
            insertColorListItemUseCase.invoke(
                subject: type,
                remoteId: remoteId,
                type: .dimmer,
                color: UIColor(argb: cct),
                brightness: Int32(brightness)
            )
                .asDriverWithoutError()
                .drive(onNext: { [weak self] _ in self?.reloadData() })
                .disposed(by: disposeBag)
        }
        
        override func getOriginalButtonIcon(_ value: ChannelState.Value) -> IconResult {
            .originalSuplaIcon(name: value == .on ? .Icons.fncDimmerCctOn : .Icons.fncDimmerCctOff)
        }
        
        func onCctSelectionStarted() {
            if (state.offline) {
                return
            }
            
            lastInteractionTime = dateProvider.currentTimestamp()
            changing = true
        }
        
        func onCctSelecting(_ cct: Int) {
            if (state.offline) {
                return
            }
            
            lastInteractionTime = dateProvider.currentTimestamp()
            // Setting brightness to 0 is not allowed. If the user wants turn off the dimmer
            // should click on turn off button
            state.value = .single(brightness: state.value.brightness ?? 100, cct: cct)
            
            if let actionData {
                delayedRgbwActionSubject.emit(data: actionData)
            }
        }
        
        func onCctSelected() {
            if (state.offline) {
                return
            }
            
            state.loadingState = state.loadingState.copy(loading: true)
            changing = false
            lastInteractionTime = nil
            
            if let actionData {
                delayedRgbwActionSubject.sendImmediately(data: actionData)
                    .subscribe()
                    .disposed(by: disposeBag)
            }
        }
    }
}
