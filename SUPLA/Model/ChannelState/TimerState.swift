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
    
class TimerState: SAExtendedValue {
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    
    @objc
    var countdownEndsAt: Date? {
        countdownEndsAtTimestamp?.convert {
            let timeDiff = Double(suplaClientProvider.provide()?.getServerTimeDiffInSec() ?? 0)
            return Date(timeIntervalSince1970: $0 + timeDiff)
        }
    }
    
    private var countdownEndsAtTimestamp: Double? = nil
    
    override init() {
        super.init()
    }
    
    init?(channelExtendedValue: SAChannelExtendedValue) {
        super.init(extendedValue: channelExtendedValue)
        
        var timerFound = false
        forEach { value in
            if (value.pointee.hasChannelAndTimerState) {
                let state = withUnsafePointer(to: &value.pointee.value) { rawPtr in
                    rawPtr.withMemoryRebound(to: TChannelAndTimerState_ExtendedValue.self, capacity: 1) { $0.pointee }
                }
                self.countdownEndsAtTimestamp = Double(state.Timer.CountdownEndsAt)
                
                timerFound = true
                return true
            }
            
            if (value.pointee.hasTimerState) {
                let state = withUnsafePointer(to: &value.pointee.value) { rawPtr in
                    rawPtr.withMemoryRebound(to: TTimerState_ExtendedValue.self, capacity: 1) { $0.pointee }
                }
                self.countdownEndsAtTimestamp = Double(state.CountdownEndsAt)
                
                timerFound = true
                return true
            }
            
            return false
        }
        
        if (!timerFound) {
            return nil
        }
    }
}

extension SAChannelExtendedValue {
    @objc
    var timerState: TimerState? {
        TimerState(channelExtendedValue: self)
    }
}

extension TSuplaChannelExtendedValue {
    var hasChannelAndTimerState: Bool {
        let size = Int(self.size)
        let senderNameMaxSize = Int(SUPLA_SENDER_NAME_MAXSIZE)
        
        return type == EV_TYPE_CHANNEL_AND_TIMER_STATE_V1 &&
            size >= MemoryLayout<TChannelAndTimerState_ExtendedValue>.size - senderNameMaxSize &&
            size <= MemoryLayout<TChannelAndTimerState_ExtendedValue>.size
    }
    
    var hasTimerState: Bool {
        let size = Int(self.size)
        let senderNameMaxSize = Int(SUPLA_SENDER_NAME_MAXSIZE)
        
        return (type == EV_TYPE_TIMER_STATE_V1 || type == EV_TYPE_TIMER_STATE_V1_SEC) &&
            size >= MemoryLayout<TTimerState_ExtendedValue>.size - senderNameMaxSize &&
            size <= MemoryLayout<TTimerState_ExtendedValue>.size
    }
}
