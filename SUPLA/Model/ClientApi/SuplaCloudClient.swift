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

struct SuplaCloudClient {
    static var emailCharacterSet: CharacterSet = {
        var set = NSCharacterSet.urlQueryAllowed
        set.remove("+")
        return set
    }()
 
    static var decoder: JSONDecoder {
        get {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                if let timeinterval = TimeInterval(dateStr) {
                    return Date(timeIntervalSince1970: timeinterval)
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decoade date string \(dateStr)"
                    )
                }
            })
            return decoder
        }
    }
}

enum SuplaCloudClientError: Error {
    case parseError(message: String)
}
