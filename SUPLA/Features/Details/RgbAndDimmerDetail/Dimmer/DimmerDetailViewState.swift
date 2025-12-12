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

extension DimmerDetailFeature {
    class ViewState: ObservableObject {
        @Published var deviceStateData: DeviceStateData? = nil
        @Published var issues: [ChannelIssueItem] = []
        @Published var offButtonState: SwitchButtonState? = nil
        @Published var onButtonState: SwitchButtonState? = nil
        @Published var value: DimmerValue = .empty
        @Published var savedColors: [SavedColor] = []
        @Published var offline: Bool = false
        @Published var loadingState: LoadingState = .init()
        @Published var showLimitReachedToast: Bool = false
    }
    
    enum DimmerValue {
        case empty
        case single(brightness: Int)
        case multiple([Int])
        
        var brightness: Int? {
            switch self {
            case .empty: nil
            case .single(let brightness): brightness
            case .multiple(let brightnesses): brightnesses.count == 1 ? brightnesses.first : nil
            }
        }
        
        var markers: [Int] {
            switch self {
            case .empty, .single(_): []
            case .multiple(let brightnesses): brightnesses.count == 1 ? [] : brightnesses
            }
        }
        
        var brightnessString: String {
            switch self {
            case .empty: return "?"
            case .single(let brightness): return brightness.asPercentageString
            case .multiple(let brightness):
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
    }
}
