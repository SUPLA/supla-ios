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

class StandardDetailVM<S: ViewState, E: ViewEvent>: BaseViewModel<S, E> {
    @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
    @Singleton<ReadGroupByRemoteIdUseCase> private var readGroupByRemoteIdUseCase
    @Singleton<GetChannelBaseCaptionUseCase> private var getChannelBaseCaptionUseCase

    func loadData(remoteId: Int32, type: SubjectType) {
        switch (type) {
        case .channel: loadChannel(remoteId)
        case .group: loadGroup(remoteId)
        default: break
        }
    }

    private func loadChannel(_ remoteId: Int32) {
        readChannelByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in self?.handleChannel($0) })
            .disposed(by: self)
    }

    private func handleChannel(_ channel: SAChannel) {
        setTitle(getChannelBaseCaptionUseCase.invoke(channelBase: channel))
    }
    
    private func loadGroup(_ remoteId: Int32) {
        readGroupByRemoteIdUseCase.invoke(remoteId: remoteId)
            .asDriverWithoutError()
            .drive(onNext: { [weak self] in self?.handleGroup($0) })
            .disposed(by: self)
    }
    
    private func handleGroup(_ group: SAChannelGroup) {
        setTitle(getChannelBaseCaptionUseCase.invoke(channelBase: group))
    }

    func setTitle(_ title: String) { fatalError("setTitle(_:) has not been implemented") }
}
