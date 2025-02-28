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

struct AggregatedEntity: Equatable {
    let date: TimeInterval
    let value: AggregatedValue
}

enum AggregatedValue: Equatable {
    case single(value: Double, min: Double?, max: Double?, open: Double?, close: Double?)
    case multiple(values: [Double])
    case withPhase(value: Double, min: Double?, max: Double?, phase: Phase)

    var min: Double {
        switch (self) {
        case .single(let value, _, _, _, _):
            return value
        case .multiple(let values):
            return values.filter { $0 < 0 }.sum()
        case .withPhase(let value, _, _, _):
            return value
        }
    }
    
    var max: Double {
        switch (self) {
        case .single(let value, _, _, _, _):
            return value
        case .multiple(let values):
            return values.filter { $0 > 0 }.sum()
        case .withPhase(let value, _, _, _):
            return value
        }
    }
}

