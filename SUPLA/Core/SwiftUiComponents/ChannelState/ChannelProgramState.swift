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

struct ChannelProgramState {
    struct Data {
        let label: String
        let description: String?
        let time: String?
        let icon: Image?
        let iconColor: Color?
        let indicatorIcon: Image?
        let indicatorColor: Color?

        init(
            label: String,
            description: String? = nil,
            time: String? = nil,
            icon: Image? = nil,
            iconColor: Color? = nil,
            indicatorIcon: Image? = nil,
            indicatorColor: Color? = nil
        ) {
            self.label = label
            self.description = description
            self.time = time
            self.icon = icon
            self.iconColor = iconColor
            self.indicatorIcon = indicatorIcon
            self.indicatorColor = indicatorColor
        }
    }

    struct View: SwiftUI.View {
        let data: [Data]

        var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: Distance.tiny) {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    HStack(spacing: Distance.tiny) {
                        Text(item.label.uppercased())
                            .fontBodyMedium()
                            .foregroundStyle(Color.Supla.gray)
                            .frame(width: 80, alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        if let icon = item.icon, let color = item.iconColor {
                            icon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19)
                                .foregroundStyle(color)
                        }

                        if let description = item.description {
                            Text(description)
                                .fontLabelMedium()
                                .foregroundStyle(Color.Supla.onBackground)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        if let time = item.time {
                            Text(time)
                                .fontBodyMedium()
                                .foregroundStyle(Color.Supla.onBackground)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        if let icon = item.indicatorIcon, let color = item.indicatorColor {
                            icon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19)
                                .foregroundStyle(color)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .padding(.horizontal, Distance.default)
            .padding(.top, Distance.small)
        }
    }
}

#Preview("Current and next program") {
    ChannelProgramState.View(data: [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.Schedule.programForceOn,
            time: Strings.General.time_just_minutes.arguments(12),
            icon: Image(systemName: "power"),
            iconColor: .green
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.Schedule.programForceOff,
            icon: Image(systemName: "power"),
            iconColor: .red
        )
    ])
    .background(Color.Supla.background)
}
