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

func fatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

func unreachable() -> Never {
    repeat {
        RunLoop.current.run()
    } while (true)
}

struct FatalErrorUtil {

    // Called by the custom implementation of `fatalError`.
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    // backup of the original Swift `fatalError`
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    /// Replace the `fatalError` global function with something else.
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
