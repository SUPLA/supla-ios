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
    
struct LockScreenSettings: Equatable {
    let scope: LockScreenScope
    let pinSum: String?
    let biometricAllowed: Bool
    let failsCount: Int
    let lockTime: TimeInterval?
    
    init(scope: LockScreenScope, pinSum: String?, biometricAllowed: Bool, failsCount: Int, lockTime: TimeInterval?) {
        self.scope = scope
        self.pinSum = pinSum
        self.biometricAllowed = biometricAllowed
        self.failsCount = failsCount
        self.lockTime = lockTime
    }
    
    init(scope: LockScreenScope, pinSum: String?, biometricAllowed: Bool) {
        self.init(scope: scope, pinSum: pinSum, biometricAllowed: biometricAllowed, failsCount: 0, lockTime: nil)
    }
    
    var pinForAppRequired: Bool {
        scope == .application && pinSum != nil
    }
    
    var pinForAccountsRequired: Bool {
        scope == .accounts && pinSum != nil
    }
    
    func isLocked(_ dateProvider: DateProvider) -> Bool {
        if let lockTime = lockTime {
            lockTime >= dateProvider.currentTimestamp()
        } else {
            false
        }
    }
    
    func asString() -> String {
        let lockTimeString = if let lockTime = lockTime {
            String(format: "%.0f", lockTime)
        } else {
            ""
        }
        return "\(scope.rawValue):\(pinSum ?? ""):\(biometricAllowed ? 1 : 0):\(failsCount):\(lockTimeString)"
    }
    
    func copy(
        scope: OptionalValue<LockScreenScope> = .unset(.none),
        pinSum: OptionalValue<String?> = .unset(nil),
        biometricAllowed: OptionalValue<Bool> = .unset(false),
        failsCount: OptionalValue<Int> = .unset(0),
        lockTime: OptionalValue<TimeInterval?> = .unset(nil)
    ) -> LockScreenSettings {
        LockScreenSettings(
            scope: scope.getValue(self.scope),
            pinSum: pinSum.getValue(self.pinSum),
            biometricAllowed: biometricAllowed.getValue(self.biometricAllowed),
            failsCount: failsCount.getValue(self.failsCount),
            lockTime: lockTime.getValue(self.lockTime)
        )
    }
    
    static let DEFAULT = LockScreenSettings(scope: .none, pinSum: nil, biometricAllowed: false, failsCount: 0, lockTime: nil)
    
    static func from(string: String?) -> LockScreenSettings {
        guard let stringArray = string?.components(separatedBy: ":") else {
            return DEFAULT
        }
        
        if (stringArray.count != 5) {
            return DEFAULT
        }
        
        let scope = LockScreenScope.from(Int(stringArray[0]) ?? 0)
        let pinSum = stringArray[1].isEmpty ? nil : stringArray[1]
        let biometricAllowed = stringArray[2] == "1"
        let failsCount = Int(stringArray[3]) ?? 0
        let lockTime = stringArray[4].isEmpty ? nil : Double(stringArray[4])
        
        return LockScreenSettings(scope: scope, pinSum: pinSum, biometricAllowed: biometricAllowed, failsCount: failsCount, lockTime: lockTime)
    }
}
