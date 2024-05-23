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
    var parameters: [(Int32, Bool, Int32)] = []
    var returns: ChannelState = .notUsed
    func invoke(function: Int32, online: Bool, activeValue: Int32) -> ChannelState {
        parameters.append((function, online, activeValue))
        return returns
    }
}

final class GetChannelBaseIconUseCaseMock: GetChannelBaseIconUseCase {
    var returns: IconResult = .suplaIcon(icon: nil)
    var parameters: [IconData] = []
    func invoke(iconData: IconData) -> IconResult {
        parameters.append(iconData)
        return returns
    }
}

final class ChannelBaseActionUseCaseMock: ChannelBaseActionUseCase {
    var returns: Observable<Void> = .empty()
    var parameters: [(SAChannelBase, CellButtonType)] = []
    func invoke(_ channelBase: SAChannelBase, _ buttonType: CellButtonType) -> Observable<Void> {
        parameters.append((channelBase, buttonType))
        return returns
    }
}
