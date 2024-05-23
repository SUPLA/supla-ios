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

protocol ChannelBaseActionUseCase {
    func invoke(_ channelBase: SAChannelBase, _ buttonType: CellButtonType) -> Observable<Void>
}

final class ChannelBaseActionUseCaseImpl: ChannelBaseActionUseCase {
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
    
    func invoke(_ channelBase: SAChannelBase, _ buttonType: CellButtonType) -> Observable<Void> {
        if let action = getAction(channelBase, buttonType) {
            return executeSimpleActionUseCase.invoke(action: action, type: getSubjectType(channelBase), remoteId: channelBase.remote_id)
        }
        
        return Observable.just(())
    }
    
    private func getAction(_ channelBase: SAChannelBase, _ buttonType: CellButtonType) -> Action? {
        if (channelBase.isShadingSystem()) {
            return switch (buttonType) {
            case .leftButton: Action.downOrStop
            case .rightButton: Action.upOrStop
            }
        }
        if (channelBase.func == SUPLA_CHANNELFNC_PROJECTOR_SCREEN) {
            return switch (buttonType) {
            case .leftButton: Action.upOrStop
            case .rightButton: Action.downOrStop
            }
        }
        if (channelBase.isHvacThermostat()) {
            return switch (buttonType) {
            case .leftButton: Action.turnOff
            case .rightButton: Action.turnOn
            }
        }
        return nil
    }
    
    private func getSubjectType(_ channelBase: SAChannelBase) -> SubjectType {
        if (channelBase is SAChannel) {
            return .channel
        }
        if (channelBase is SAChannelGroup) {
            return .group
        }
        
        fatalError("Unknown instance of SAChannelBase!")
    }
}
