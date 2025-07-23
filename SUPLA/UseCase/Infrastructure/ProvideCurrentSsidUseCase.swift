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

import SystemConfiguration.CaptiveNetwork

enum ProvideCurrentSsid {
    protocol UseCase {
        func invoke() -> String?
    }

    class Implementation: UseCase {
        func invoke() -> String? {
            if let interfaces: NSArray = CNCopySupportedInterfaces() {
                for interface in interfaces {
                    let interfaceName = interface as! String
                    if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                        return dict[kCNNetworkInfoKeySSID as String] as? String
                    }
                }
            }
            
            return nil
        }
    }
}
