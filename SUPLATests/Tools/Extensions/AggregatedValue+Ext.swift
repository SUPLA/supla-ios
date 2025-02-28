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
    
@testable import SUPLA

extension AggregatedValue {
    var value: Double {
        switch (self) {
        case .single(let value, _, _, _, _): value
        case .multiple(let values): values.reduce(0, +)
        case .withPhase(let value, _, _, _): value
        }
    }
    
    var min: Double? {
        switch (self) {
        case .single(_, let min, _, _, _): min
        case .multiple(_): nil
        case .withPhase(_, let min, _, _): min
        }
    }
    
    var max: Double? {
        switch (self) {
        case .single(_, _, let max, _, _): max
        case .multiple(_): nil
        case .withPhase(_, _, let max, _): max
        }
    }
    
    var open: Double? {
        switch (self) {
        case .single(_, _, _, let open, _): open
        case .multiple(_): nil
        case .withPhase: nil
        }
    }
    
    var close: Double? {
        switch (self) {
        case .single(_, _, _, _, let close): close
        case .multiple(_): nil
        case .withPhase: nil
        }
    }
}
