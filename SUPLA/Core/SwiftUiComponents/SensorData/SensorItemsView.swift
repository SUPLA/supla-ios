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

import SwiftUI
    
struct SensorItemsView: SwiftUI.View {
    let sensors: [RelatedChannelData]
    let onInfoClick: (RelatedChannelData) -> Void
    let onCaptionLongPress: (RelatedChannelData) -> Void
    
    var body: some SwiftUI.View {
        if (!sensors.isEmpty) {
            VStack(alignment: .leading, spacing: 1) {
                Text(Strings.Valve.detailSensors.uppercased())
                    .fontBodyMedium()
                    .padding([.leading, .trailing], Distance.default)
                    .padding(.bottom, Distance.tiny)
                ForEach(sensors) { sensor in
                    RelatedChannelItemView(
                        data: sensor,
                        onInfoClick: onInfoClick,
                        onCaptionLongPress: onCaptionLongPress
                    )
                }
            }
        }
    }
}
