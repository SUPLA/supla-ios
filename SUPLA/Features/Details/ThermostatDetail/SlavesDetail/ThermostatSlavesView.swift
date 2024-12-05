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
import SharedCore

extension ThermostatSlavesFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState

        let onInfoAction: (String) -> Void
        let onStatusAction: (SAChannel?) -> Void

        var body: some SwiftUI.View {
            BackgroundStack {
                VStack(spacing: 0) {
                    if let master = viewState.master {
                        HeaderText(title: Strings.ThermostatDetail.mainThermostat)
                            .padding([.bottom], Distance.tiny)
                        ThermostatRow(data: master, onInfoAction: onInfoAction, onStatusAction: onStatusAction)
                    }
                    HeaderText(title: Strings.ThermostatDetail.otherThermostats)
                        .padding([.top], Distance.standard)
                        .padding([.bottom], Distance.tiny)
                    LazyList(items: viewState.slaves) {
                        ThermostatRow(data: $0, onInfoAction: onInfoAction, onStatusAction: onStatusAction)
                    }
                }.padding([.top], Dimens.distanceDefault)
            }.environment(\.scaleFactor, viewState.scale)
        }
    }

    struct HeaderText: SwiftUI.View {
        let title: String
        var body: some SwiftUI.View {
            HStack {
                Text.BodyMedium(text: title.uppercased(), alignment: .leading)
                Spacer()
            }.padding([.leading, .trailing], Dimens.distanceSmall)
        }
    }

    struct ThermostatRow: SwiftUI.View {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat
        
        let data: ThermostatData

        let onInfoAction: (String) -> Void
        let onStatusAction: (SAChannel?) -> Void

        var body: some SwiftUI.View {
            ZStack {
                HStack {
                    VStack(alignment: .center) {
                        ListItemIcon(iconResult: data.icon)
                        Text.BodySmall(text: data.currentPower ?? "")
                    }.padding([.leading], Dimens.distanceSmall)
                    VStack(alignment: .leading, spacing: scaleFactor.scale(Dimens.distanceSmall)) {
                        HStack {
                            Text.CellValue(text: data.value)
                            if (data.indicatorIcon == .off) {
                                Text.BodyMedium(text: "Off")
                            } else {
                                SetpointIndicator(icon: data.indicatorIcon)
                                if let subValue = data.subValue {
                                    Text.BodyMedium(text: subValue)
                                }
                            }
                            ChildChannelIcon(icon: data.pumpSwitchIcon)
                            ChildChannelIcon(icon: data.sourceSwitchIcon)
                        }
                        Text.CellCaption(text: data.caption)
                            .padding([.trailing], Dimens.distanceSmall)
                    }
                    Spacer()
                }
                HStack(spacing: Dimens.distanceSmall) {
                    Spacer()
                    if let issueIcon = data.issues.icons.first {
                        ListItemIssueIcon(icon: issueIcon)
                            .onTapGesture {
                                if (data.issues.hasMessage()) {
                                    onInfoAction(data.issues.message)
                                }
                            }
                    }
                        
                    if (data.showChannelStateIcon) {
                        ListItemInfoIcon()
                            .onTapGesture { onStatusAction(data.channel) }
                    }
                    ListItemDot(onlineState: data.onlineState)
                }.padding([.trailing], Dimens.distanceSmall)
            }.padding([.top, .bottom], Dimens.distanceTiny)
                .background(Color.Supla.surface)
        }
    }

    struct ListItemIcon: SwiftUI.View {
        @Environment(\.scaleFactor) var scaleFactor: CGFloat
        
        let iconResult: IconResult?

        var body: some SwiftUI.View {
            Image()
                .resizable()
                .scaledToFit()
                .frame(width: scale(scaleFactor, 60), height: scale(scaleFactor, 50))
        }
        
        private func Image() -> SwiftUI.Image {
            if let iconResult = iconResult {
                iconResult.image
            } else {
                SwiftUI.Image(.Icons.fncUnknown)
            }
        }
    }

    struct ListItemInfoIcon: SwiftUI.View {
        var body: some SwiftUI.View {
            Image(.Icons.info)
                .resizable()
                .scaledToFit()
                .frame(width: Dimens.iconInfoSize, height: Dimens.iconInfoSize)
                .foregroundColor(.Supla.onBackground)
        }
    }

    struct ListItemIssueIcon: SwiftUI.View {
        let icon: IssueIcon?

        var body: some SwiftUI.View {
            if let icon = icon?.resource {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.iconSizeList, height: Dimens.iconSizeList)
                    .foregroundColor(.Supla.onBackground)
            }
        }
    }

    struct ListItemDot: SwiftUI.View {
        let onlineState: ListOnlineState

        var body: some SwiftUI.View {
            let color = onlineState.online ? Color.Supla.primary : Color.Supla.error
            ZStack {
                Circle()
                    .stroke()
                    .fill(color)
                    .frame(
                        width: Dimens.ListItem.statusIndicatorSize,
                        height: Dimens.ListItem.statusIndicatorSize
                    )
            }
        }
    }

    struct SetpointIndicator: SwiftUI.View {
        let icon: ThermostatIndicatorIcon?

        var body: some SwiftUI.View {
            if let iconResource = icon?.resourceName {
                Image(iconResource)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
        }
    }

    struct ChildChannelIcon: SwiftUI.View {
        let icon: IconResult?

        var body: some SwiftUI.View {
            if let icon = icon {
                icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            }
        }
    }
}

#Preview {
    let viewState = ThermostatSlavesFeature.ViewState()
    viewState.master = ThermostatSlavesFeature.ThermostatData(
        id: 1,
        onlineState: .online,
        caption: "FHC #0",
        icon: .suplaIcon(name: "fnc_thermostat_heat"),
        currentPower: nil,
        value: "22,7°C",
        indicatorIcon: .heating,
        issues: ListItemIssues(icons: [IssueIcon.Warning()], issuesStrings: []),
        showChannelStateIcon: true,
        subValue: "23,0°",
        pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-on"),
        sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-on"),
        channel: nil
    )
    viewState.slaves = [
        ThermostatSlavesFeature.ThermostatData(
            id: 1,
            onlineState: .online,
            caption: "FHC #1",
            icon: .suplaIcon(name: "fnc_thermostat_heat"),
            currentPower: "25%",
            value: "22,7°C",
            indicatorIcon: .standby,
            issues: ListItemIssues(icons: [], issuesStrings: []),
            showChannelStateIcon: true,
            subValue: "23,0°",
            pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-off"),
            sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-on"),
            channel: nil
        ),
        ThermostatSlavesFeature.ThermostatData(
            id: 2,
            onlineState: .online,
            caption: "FHC #2",
            icon: .suplaIcon(name: "fnc_thermostat_heat"),
            currentPower: "100%",
            value: "22,4°C",
            indicatorIcon: .standby,
            issues: ListItemIssues(icons: [], issuesStrings: []),
            showChannelStateIcon: true,
            subValue: "23,0°",
            pumpSwitchIcon: .suplaIcon(name: "fnc_pump_switch-on"),
            sourceSwitchIcon: .suplaIcon(name: "fnc_heat_or_cold_source_switch-off"),
            channel: nil
        )
    ]
    return ThermostatSlavesFeature.View(
        viewState: viewState,
        onInfoAction: { _ in },
        onStatusAction: { _ in }
    )
}
