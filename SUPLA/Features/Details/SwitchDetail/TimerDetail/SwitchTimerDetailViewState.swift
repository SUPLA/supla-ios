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

import SwiftUI

extension SwitchTimerDetailFeature {
    final class ViewState: ObservableObject {
        @Published var isOn: Bool = false
        @Published var isOnline: Bool = false
        @Published var channelCurrentStateData: ChannelCurrentState.Data? = nil
        @Published var channelProgramState: [ChannelProgramState.Data] = []
        @Published var timerStartDisabled = false
        @Published var editMode = false
        @Published var targetAction: TimerTargetAction = .turnOn
        @Published var hours = 0
        @Published var minutes = 0
        @Published var seconds = 0
        @Published var invalidTimeAlertPresented = false
        
        @Published var timerStartDate: Date? = nil
        @Published var timerEndDate: Date? = nil
        
        let referenceDate = Date()

        var timeInSeconds: Int { hours * 3600 + minutes * 60 + seconds }

        func setTimeInSeconds(_ value: Int) {
            let value = max(0, value)
            hours = min(value / 3600, 23)
            minutes = value / 60 % 60
            seconds = value % 60
        }
    }
}
