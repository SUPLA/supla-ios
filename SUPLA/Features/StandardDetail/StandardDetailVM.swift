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

class StandardDetailVM: BaseViewModel<StandardDetailViewState, StandardDetailViewEvent> {
    
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    
    override func defaultViewState() -> StandardDetailViewState { StandardDetailViewState() }
    
    func loadChannel(remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { channel in
                self.updateView() { state in
                    state
                        .changing(path: \.title, to: channel.getNonEmptyCaption())
                }
            })
            .disposed(by: self)
    }
    
}

enum StandardDetailViewEvent: ViewEvent {
}

struct StandardDetailViewState: ViewState {
    var title: String? = nil
}

