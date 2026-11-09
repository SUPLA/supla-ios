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

import SharedCore

extension ActionTriggerGeneralFeature {
    class ViewState: ObservableObject {
        @Published var channelCurrentStateData: ChannelCurrentState.Data?
        @Published var channelProgramState: [ChannelProgramState.Data] = []
        @Published var manualAllowed = true
        @Published var manualActive = true
        @Published var weeklyAllowed = false
        @Published var weeklyActive = false
        @Published var online = false
        @Published var showLockButtons = false
        @Published var lockActive = false
        @Published var unlockActive = true
        @Published var lockButtonDisabled = false
        @Published var unlockButtonDisabled = false
        @Published var temporaryUnlockActive = false
        @Published var showAllowTemporaryUnlock = false
        @Published var allowTemporaryUnlock = false
        @Published var allowTemporaryUnlockDisabled = false
        @Published var unlockDialogPresented = false
        @Published var unlockDialogDurationS = 0
        @Published var unlockTemporaryAllowed = false
    }
}
