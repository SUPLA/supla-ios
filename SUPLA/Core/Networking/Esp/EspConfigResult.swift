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

class EspConfigResult: NSObject {
    
    @objc var resultCode: EspConfigResultCode = .failed
    @objc var extendedResultError: String? = nil
    @objc var extendedResultCode: Int64 = 0
    
    @objc var name: String? = nil
    @objc var state: String? = nil
    @objc var version: String? = nil
    @objc var guid: String? = nil
    @objc var mac: String? = nil
    
    @objc var needsCloudConfig: Bool = false
    
    @objc func merge(result: EspConfigResult) {
        name = result.name
        state = result.state
        version = result.version
        guid = result.guid
        mac = result.mac
        
        needsCloudConfig = result.needsCloudConfig
    }
}

@objc
enum EspConfigResultCode: Int32 {
    case paramError = -3
    case compatError = -2
    case connectionError = -1
    case failed = 0
    case success = 1
}
