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
    
extension RgbDetailFeature {
    class ViewState: ObservableObject {
        @Published var deviceStateData: DeviceStateData? = nil
        @Published var issues: [ChannelIssueItem] = []
        @Published var offButtonState: SwitchButtonState? = nil
        @Published var onButtonState: SwitchButtonState? = nil
        @Published var value: RgbValue = .empty
        @Published var savedColors: [SavedColor] = []
        @Published var offline: Bool = false
        @Published var loadingState: LoadingState = .init()
        @Published var hexColorEditorValue: String? = nil
        @Published var showLimitReachedToast: Bool = false
    }
    
    struct SavedColor: Identifiable, Equatable {
        var id: Int32 { idx }
        
        let idx: Int32
        let color: UIColor
        let brightness: Int32
    }
    
    enum RgbValue {
        case empty
        case single(color: HsvColor)
        case multiple([HsvColor])
        
        var hsv: HsvColor? {
            switch self {
            case .empty: nil
            case .single(let color): color
            case .multiple(let colors): colors.count == 1 ? colors.first : nil
            }
        }
        
        var markers: [HsvColor] {
            switch self {
            case .empty, .single(_): []
            case .multiple(let colors): colors.count == 1 ? [] : colors
            }
        }
        
        var brightnessString: String {
            switch self {
            case .empty: return "?"
            case .single(let color): return color.value.asPercentageString
            case .multiple(let colors):
                if (colors.isEmpty) {
                    return "?"
                } else if (colors.count == 1) {
                    return colors[0].value.asPercentageString
                } else {
                    let min = colors.min(by: { $0.value < $1.value })?.value.asPercentageString ?? "?"
                    let max = colors.max(by: { $0.value < $1.value })?.value.asPercentageString ?? "?"
                    return "\(min) - \(max)"
                }
            }
        }
    }
}
