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

enum WindowGroupedValueFormat: Equatable {
    case openingPercentage
    case percentage
    case degree
}

enum WindowGroupedValueDestination: Equatable {
    case window
    case slider
}

enum WindowGroupedValue: Equatable {
    case invalid
    case similar(_ value: CGFloat)
    case different(min: CGFloat, max: CGFloat)
    
    var value: CGFloat {
        value(for: .window) ?? 0
    }

    func value(for destination: WindowGroupedValueDestination) -> CGFloat? {
        switch (self) {
        case .invalid: nil
        case .similar(let value): value
        case .different(_, let max): destination == .window ? max : nil
        }
    }
    
    func asString(_ format: WindowGroupedValueFormat, value0: CGFloat? = nil, value100: CGFloat? = nil) -> String {
        switch (self) {
        case .invalid: invalidAsString(format)
        case .similar(let position): similarAsString(format, position, value0, value100)
        case .different(let min, let max): differentAsString(format, min, max, value0, value100)
        }
    }
    
    func asAngle(_ value0: CGFloat, _ value100: CGFloat) -> CGFloat {
        valueToAngle(value(for: .window) ?? 0, value0, value100)
    }
    
    func isDifferent() -> Bool {
        switch (self) {
        case .different: true
        default: false
        }
    }
    
    private func invalidAsString(_ format: WindowGroupedValueFormat) -> String {
        switch (format) {
        case .openingPercentage, .percentage: "0%"
        case .degree: "0°"
        }
    }
    
    private func similarAsString(_ format: WindowGroupedValueFormat, _ value: CGFloat, _ value0: CGFloat?, _ value100: CGFloat?) -> String {
        switch (format) {
        case .openingPercentage: String(format: "%.0f%%", 100 - value)
        case .percentage: String(format: "%.0f%%", value)
        case .degree:
            if let value0 = value0, let value100 = value100 {
                String(format: "%.0f°", valueToAngle(value, value0, value100))
            } else {
                String(format: "%.0f%%", value)
            }
        }
    }
    
    private func differentAsString(_ format: WindowGroupedValueFormat, _ min: CGFloat, _ max: CGFloat, _ value0: CGFloat?, _ value100: CGFloat?) -> String {
        switch (format) {
        case .openingPercentage: String(format: "%.0f%% - %.0f%%", 100 - max, 100 - min)
        case .percentage: String(format: "%.0f%% - %.0f%%", min, max)
        case .degree:
            if let value0 = value0, let value100 = value100 {
                String(format: "%.0f° - %.0f°", valueToAngle(min, value0, value100), valueToAngle(max, value0, value100))
            } else {
                String(format: "%.0f%% - %.0f%%", min, max)
            }
        }
    }
    
    private func valueToAngle(_ value: CGFloat, _ value0: CGFloat, _ value100: CGFloat) -> CGFloat {
        value0 + (value100 - value0) * value / 100
    }
}
