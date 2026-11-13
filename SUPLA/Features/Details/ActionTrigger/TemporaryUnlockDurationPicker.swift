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

enum ActionTriggerTemporaryUnlockDuration {
    static let maximum = 64_800
    static func clamp(_ value: Int) -> Int { value.clamped(to: 0...maximum)  }
    
    static func hours(_ value: Int) -> Int { clamp(value) / 3_600 }
    static func minutes(_ value: Int) -> Int { (clamp(value) % 3_600) / 60 }
    static func seconds(_ value: Int) -> Int { clamp(value) % 60 }
    
    static func replacingHours(_ hours: Int, in value: Int) -> Int {
        clamp(hours * 3_600 + minutes(value) * 60 + seconds(value))
    }
    static func replacingMinutes(_ minutes: Int, in value: Int) -> Int {
        clamp(hours(value) * 3_600 + minutes * 60 + seconds(value))
    }
    static func replacingSeconds(_ seconds: Int, in value: Int) -> Int {
        clamp(hours(value) * 3_600 + minutes(value) * 60 + seconds)
    }
    
    static func minuteValues(for value: Int) -> ClosedRange<Int> { 0...(hours(value) == 18 ? 0 : 59) }
    static func secondValues(for value: Int) -> ClosedRange<Int> { minuteValues(for: value) }
}

struct TemporaryUnlockDurationPicker: SwiftUI.View {
    let durationS: Int
    let onChange: (Int) -> Void
    
    var body: some SwiftUI.View {
        HStack(spacing: 0) {
            SuplaCore.WheelPicker(selected: hoursBinding, items: (0...18).map { $0.asHourPickerItem })
            SuplaCore.WheelPicker(selected: minutesBinding, items: minuteItems)
            SuplaCore.WheelPicker(selected: secondsBinding, items: secondItems)
        }.frame(height: 160)
    }
    
    private var hour: Int { ActionTriggerTemporaryUnlockDuration.hours(durationS) }
    private var minute: Int { ActionTriggerTemporaryUnlockDuration.minutes(durationS) }
    private var second: Int { ActionTriggerTemporaryUnlockDuration.seconds(durationS) }
    
    private var hoursBinding: Binding<HourPickerItem> {
        Binding(
            get: { hour.asHourPickerItem },
            set: { onChange(ActionTriggerTemporaryUnlockDuration.replacingHours($0.id, in: durationS)) }
        )
    }
    private var minutesBinding: Binding<NumberPickerItem> {
        Binding(
            get: { minute.asMinutePickerItem },
            set: { onChange(ActionTriggerTemporaryUnlockDuration.replacingMinutes($0.id, in: durationS)) }
        )
    }
    private var secondsBinding: Binding<NumberPickerItem> {
        Binding(
            get: { NumberPickerItem(id: second, pattern: Strings.TimerDetail.secondPattern) },
            set: { onChange(ActionTriggerTemporaryUnlockDuration.replacingSeconds($0.id, in: durationS)) }
        )
    }
    
    private var minuteItems: [NumberPickerItem] {
        ActionTriggerTemporaryUnlockDuration.minuteValues(for: durationS)
            .map { $0.asMinutePickerItem }
    }
    private var secondItems: [NumberPickerItem] {
        ActionTriggerTemporaryUnlockDuration.secondValues(for: durationS)
            .map { NumberPickerItem(id: $0, pattern: Strings.TimerDetail.secondPattern) }
    }
}
