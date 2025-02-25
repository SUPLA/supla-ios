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
    
import SharedCore

extension ValveGeneralFeature {
    class ViewState: ObservableObject {
        @Published var icon: IconResult? = nil
        @Published var stateString: String? = nil
        @Published var issues: [ChannelIssueItem] = []
        @Published var sensors: [SensorData] = []
        @Published var offline: Bool = false
        @Published var isClosed: Bool = false
        
        @Published var stateDialogState: StateDialogFeature.ViewState? = nil
        @Published var alertDialog: ValveAlertDialog? = nil
        @Published var captionChangeDialogState: CaptionChangeDialogFeature.ViewState? = nil
        
    }
    
    struct SensorData: Identifiable {
        var id: Int32 { channelId }
        
        let channelId: Int32
        let onlineState: ListOnlineState
        let icon: IconResult?
        let caption: String
        let batteryIcon: IssueIcon?
        let showChannelStateIcon: Bool
    }
    
    enum ValveAlertDialog {
        case confirmation(message: String, action: Action)
        case failure
        
        var message: String {
            switch self {
            case .confirmation(let message, _): message
            case .failure: Strings.Valve.actionError
            }
        }
        
        var positiveButtonText: String? {
            switch self {
            case .confirmation(_, _): Strings.General.yes
            case .failure: nil
            }
        }
        
        var negativeButtonText: String? {
            switch self {
            case .confirmation(_, _): Strings.General.no
            case .failure: Strings.General.ok
            }
        }
        
        var action: Action? {
            switch self {
            case .confirmation(_, let action): action
            case .failure: nil
            }
        }
    }
}
