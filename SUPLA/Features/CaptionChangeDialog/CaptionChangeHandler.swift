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

extension CaptionChangeDialogFeature {
    protocol Handler: AnyObject {
        var captionChangeDialogState: ViewState? { get }
        
        func updateCaptionChangeDialogState(_ updater: (ViewState?) -> ViewState?)
        
        func handle(_ disposable: Disposable)
        
        func onCaptionChange(_ caption: String)
    }
}

extension CaptionChangeDialogFeature.Handler {
    func changeChannelCaption(caption: String, remoteId: Int32) {
        updateCaptionChangeDialogState { _ in
            CaptionChangeDialogFeature.ViewState(remoteId: remoteId, subjectType: .channel, caption: caption)
        }
    }
    
    func closeCaptionChangeDialog() {
        updateCaptionChangeDialogState { _ in nil }
    }
    
    func onCaptionChange(_ caption: String) {
        @Singleton<CaptionChangeUseCase> var captionChangeUseCase
        
        if let state = captionChangeDialogState {
            updateCaptionChangeDialogState { $0?.changing(path: \.loading, to: true) }
            
            handle(
                captionChangeUseCase.invoke(caption: caption, type: .channel, remoteId: state.remoteId)
                    .asDriverWithoutError()
                    .drive(onCompleted: { [weak self] in self?.closeCaptionChangeDialog() })
            )
        }
    }
}
