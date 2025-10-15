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

enum ChartEntryDetails: Equatable {
    case `default`(aggregation: ChartDataAggregation, type: ChartEntryType, date: Date, min: Double?, max: Double?, open: Double?, close: Double?, valueFormatter: SharedCore.ValueFormatter, customData: (any Equatable)?)
    case withPhase(aggregation: ChartDataAggregation, type: ChartEntryType, date: Date, min: Double?, max: Double?, valueFormatter: SharedCore.ValueFormatter, phase: Phase)

    var aggregation: ChartDataAggregation {
        switch self {
        case let .default(aggregation, _, _, _, _, _, _, _, _): aggregation
        case let .withPhase(aggregation, _, _, _, _, _, _): aggregation
        }
    }
    
    var type: ChartEntryType {
        switch self {
        case let .default(_, type, _, _, _, _, _, _, _): type
        case let .withPhase(_, type, _, _, _, _, _): type
        }
    }
    
    var date: Date {
        switch self {
        case let .default(_, _, date, _, _, _, _, _, _): date
        case let .withPhase(_, _, date, _, _, _, _): date
        }
    }

    var min: Double? {
        switch self {
        case let .default(_, _, _, min, _, _, _, _, _): min
        case let .withPhase(_, _, _, min, _, _, _): min
        }
    }

    var max: Double? {
        switch self {
        case let .default(_, _, _, _, max, _, _, _, _): max
        case let .withPhase(_, _, _, _, max, _, _): max
        }
    }

    var open: Double? {
        switch self {
        case let .default(_, _, _, _, _, open, _, _, _): open
        case .withPhase: nil
        }
    }

    var close: Double? {
        switch self {
        case let .default(_, _, _, _, _, _, close, _, _): close
        case .withPhase: nil
        }
    }
    
    var customData: (any Equatable)? {
        switch self {
        case let .default(_, _, _, _, _, _, _, _, customData): customData
        case .withPhase: nil
        }
    }

    var valueFormatter: SharedCore.ValueFormatter {
        switch self {
        case let .default(_, _, _, _, _, _, _, valueFormatter, _): valueFormatter
        case let .withPhase(_, _, _, _, _, valueFormatter, _): valueFormatter
        }
    }

    static func == (lhs: ChartEntryDetails, rhs: ChartEntryDetails) -> Bool {
        switch (lhs, rhs) {
        case let (.default(lAggregation, lType, lDate, lMin, lMax, lOpen, lClose, _, lCustomData), .default(rAggregation, rType, rDate, rMin, rMax, rOpen, rClose, _, rCustomData)):
            lAggregation == rAggregation
                && lType == rType
                && lDate == rDate
                && lMin == rMin
                && lMax == rMax
                && lOpen == rOpen
                && lClose == rClose
                && lCustomData?.isEqualTo(rCustomData) == true
        case let (.withPhase(lAggregation, lType, lDate, lMin, lMax, _, lPhase), .withPhase(rAggregation, rType, rDate, rMin, rMax, _, rPhase)):
            lAggregation == rAggregation
                && lType == rType
                && lDate == rDate
                && lMin == rMin
                && lMax == rMax
                && lPhase == rPhase
        default: false
        }
    }
}
