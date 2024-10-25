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

protocol ChannelValueFormatter {
    func handle(function: Int) -> Bool
    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String
}

extension ChannelValueFormatter {
    func format(_ value: Any) -> String {
        format(value, withUnit: true, precision: .defaultPrecision(value: 1), custom: nil)
    }
    func format(_ value: Any, withUnit: Bool) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: 1), custom: nil)
    }
    func format(_ value: Any, withUnit: Bool = true, precision: Int = 1) -> String {
        format(value, withUnit: withUnit, precision: .defaultPrecision(value: precision), custom: nil)
    }
    func format(_ value: Any, withUnit: Bool = true, precision: ChannelValuePrecision = .defaultPrecision(value: 1)) -> String {
        format(value, withUnit: withUnit, precision: precision, custom: nil)
    }
}

enum ChannelValuePrecision {
    case defaultPrecision(value: Int)
    case customPrecision(value: Int)
    
    var value: Int {
        switch (self) {
        case .customPrecision(let value): value
        case .defaultPrecision(let value): value
        }
    }
}
