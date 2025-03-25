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

extension ThermostatSlavesFeature {
    class ViewState: ObservableObject {
        @Published var master: ThermostatData? = nil
        @Published var slaves: [ThermostatData] = []
        @Published var scale: CGFloat = 1
        
        @Published var captionChangeDialogState: CaptionChangeDialogFeature.ViewState? = nil
        
        var relatedIds: [Int32] = []
    }

    struct ThermostatData: Equatable, Identifiable {
        let id: Int32
        let onlineState: ListOnlineState
        let caption: String
        let userCaption: String
        let icon: IconResult?
        let currentPower: String?
        let value: String
        let indicatorIcon: ThermostatIndicatorIcon
        let issues: ListItemIssues
        let showChannelStateIcon: Bool
        let subValue: String?
        let pumpSwitchIcon: IconResult?
        let sourceSwitchIcon: IconResult?
    }
}
