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
    
extension DimmerDetailBase {
    class ViewState: ObservableObject {
        @Published var deviceStateData: DeviceStateData? = nil
        @Published var issues: [ChannelIssueItem] = []
        @Published var offButtonState: SwitchButtonState? = nil
        @Published var onButtonState: SwitchButtonState? = nil
        @Published var savedColors: [SavedColor] = []
        @Published var value: DimmerValue = .empty
        @Published var selectorType: DimmerSelectorType = .linear
        @Published var offline: Bool = false
        @Published var loadingState: LoadingState = .init()
        @Published var showLimitReachedToast: Bool = false
    }
    
    enum DimmerValue {
        case empty
        case single(brightness: Int, cct: Int)
        case multiple([Int], [Int])
        
        var brightness: Int? {
            switch self {
            case .empty: nil
            case .single(let brightness, _): brightness
            case .multiple(let brightnesses, _): brightnesses.count == 1 ? brightnesses.first : nil
            }
        }
        
        var brightnessMarkers: [Int] {
            switch self {
            case .empty, .single(_, _): []
            case .multiple(let brightnesses, _): brightnesses.count == 1 ? [] : brightnesses
            }
        }
        
        var brightnessString: String {
            switch self {
            case .empty: return "?"
            case .single(let brightness, _): return brightness.asPercentageString
            case .multiple(let brightness, _):
                if (brightness.isEmpty) {
                    return "?"
                } else if (brightness.count == 1) {
                    return brightness[0].asPercentageString
                } else {
                    let min = brightness.min()?.asPercentageString ?? "?"
                    let max = brightness.max()?.asPercentageString ?? "?"
                    return "\(min) - \(max)"
                }
            }
        }
        
        var cct: Int? {
            switch self {
            case .empty: nil
            case .single(_, let cct): cct
            case .multiple(_, let ccts): ccts.count == 1 ? ccts.first : nil
            }
        }
        
        var cctMarkers: [Int] {
            switch self {
            case .empty, .single(_, _): []
            case .multiple(_, let ccts): ccts.count == 1 ? [] : ccts
            }
        }
    }
    
    enum DimmerSelectorType: Int, CaseIterable {
        case linear = 0
        case circular = 1
        
        var swapIcon: String {
            switch self {
            case .linear: .Icons.dimmerCircularSelector
            case .circular: .Icons.dimmerLinearSelector
            }
        }
        
        static func from(_ value: Int?) -> DimmerSelectorType {
            for type in allCases {
                if (type.rawValue == value) {
                    return type
                }
            }
            
            return .linear
        }
    }
}
