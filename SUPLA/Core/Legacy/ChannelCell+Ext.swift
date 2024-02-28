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
import RxSwift

extension SAChannelCell {
    
    @objc
    func observeChannelBaseChanges(_ remoteId: Int) {
        guard
            let updateEventsManager = DiContainer.shared.resolve(type: UpdateEventsManager.self)
        else {
            return
        }
        
        if (channelBase is SAChannel) {
            updateEventsManager.observeChannel(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { channel in
                        self.updateChannelBase(channel)
                    }
                )
                .disposed(by: self.getDisposeBagContainer())
        } else if (channelBase is SAChannelGroup) {
            updateEventsManager.observeGroup(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { channel in
                        self.updateChannelBase(channel)
                    }
                )
                .disposed(by: self.getDisposeBagContainer())
        }
    }
    
    @objc
    func turnOn(_ channelBase: SAChannelBase) {
        executeSimpleAction(channelBase: channelBase, action: .turn_on)
    }
    
    @objc
    func turnOff(_ channelBase: SAChannelBase) {
        executeSimpleAction(channelBase: channelBase, action: .turn_off)
    }
    
    @objc
    func shut(_ channelBase: SAChannelBase) {
        if (channelBase.flags & Int64(SUPLA_CHANNEL_FLAG_RS_SBS_AND_STOP_ACTIONS) > 0) {
            executeSimpleAction(channelBase: channelBase, action: .down_or_stop)
        } else {
            executeSimpleAction(channelBase: channelBase, action: .shut)
        }
    }
    
    @objc
    func reveal(_ channelBase: SAChannelBase) {
        if (channelBase.flags & Int64(SUPLA_CHANNEL_FLAG_RS_SBS_AND_STOP_ACTIONS) > 0) {
            executeSimpleAction(channelBase: channelBase, action: .up_or_stop)
        } else {
            executeSimpleAction(channelBase: channelBase, action: .reveal)
        }
    }
    
    private func executeSimpleAction(channelBase: SAChannelBase, action: Action) {
        DiContainer.shared.resolve(type: VibrationService.self)?.vibrate()
        
        if (channelBase is SAChannel) {
            _ = SAApp.suplaClient().executeAction(
                parameters: .simple(action: action, subjectType: .channel, subjectId: channelBase.remote_id)
            )
        } else {
            _ = SAApp.suplaClient().executeAction(
                parameters: .simple(action: action, subjectType: .group, subjectId: channelBase.remote_id)
            )
        }
        
    }
}
