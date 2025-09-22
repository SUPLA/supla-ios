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
@testable import SUPLA

final class GetChannelBaseStateUseCaseMock: GetChannelBaseStateUseCase {
    var parameters: [SAChannelBase] = []
    var returns: SUPLA.ChannelState = .notUsed
    func invoke(channelBase: SAChannelBase) -> SUPLA.ChannelState {
        parameters.append(channelBase)
        return returns
    }
    
    func getOfflineState(_ function: Int32) -> SUPLA.ChannelState {
        .notUsed
    }
}

final class GetChannelBaseIconUseCaseMock: GetChannelBaseIconUseCase {
    var returns: IconResult = .suplaIcon(name: "")
    var parameters: [FetchIconData] = []
    func invoke(iconData: FetchIconData) -> IconResult {
        parameters.append(iconData)
        return returns
    }
}

final class ChannelBaseActionUseCaseMock: ChannelBaseActionUseCase {
    var returns: Observable<ChannelBaseActionResult> = .empty()
    var parameters: [(SAChannelBase, CellButtonType)] = []
    func invoke(_ channelBase: SAChannelBase, _ buttonType: CellButtonType) -> Observable<ChannelBaseActionResult> {
        parameters.append((channelBase, buttonType))
        return returns
    }
    
    func invoke(_ remoteId: Int32, _ buttonType: CellButtonType) -> Observable<ChannelBaseActionResult> {
        return .empty()
    }
}
