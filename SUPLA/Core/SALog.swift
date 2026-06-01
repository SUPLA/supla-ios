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

import SwiftyBeaver
import OSLog

let SALog = SwiftyBeaver.self

@objc
class SALogWrapper: NSObject {
    @objc
    static func setup() {
        let console = ConsoleDestination()

        console.levelColor.verbose = "🟣"
        console.levelColor.debug = "🟢"
        console.levelColor.info = "🔵"
        console.levelColor.warning = "🟡"
        console.levelColor.error = "🔴"

        console.format = "[$L] $C $DHH:mm:ss.SSS$d $c $N.$F - $M"
        SALog.addDestination(console)
        #if DEBUG
        SALog.addDestination(OSLogDestination())
        #endif
    }
}

final class OSLogDestination: BaseDestination {
    private let subsystem: String
    private let category: String
    private let oslog: OSLog

    init(
        subsystem: String = "SUPLA",
        category: String = "CarPlay"
    ) {
        self.subsystem = subsystem
        self.category = category
        self.oslog = OSLog(subsystem: subsystem, category: category)
        super.init()
    }

    override func send(
        _ level: SwiftyBeaver.Level,
        msg: String,
        thread: String,
        file: String,
        function: String,
        line: Int,
        context: Any?
    ) -> String? {
        let text = "\(level) \(msg) [\(function):\(line)]"

        switch level {
        case .verbose, .debug:
            os_log("%{public}@", log: oslog, type: .debug, text)
        case .info:
            os_log("%{public}@", log: oslog, type: .info, text)
        case .warning:
            os_log("%{public}@", log: oslog, type: .default, text)
        case .error:
            os_log("%{public}@", log: oslog, type: .error, text)
        }

        return text
    }
}
