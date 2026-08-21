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
import SwiftUI

struct ListItemScaffold<Content: View>: View {
    @Environment(\.scaleFactor) private var scaleFactor

    let itemTitle: String
    let itemEstimatedEndDate: Date?
    let issues: ListItemIssues
    let statusIndicator: ListItemStatusIndicator
    let showInfoIcon: Bool
    let onInfoClick: () -> Void
    let onIssueClick: (ListItemIssues) -> Void
    let onTitleLongClick: () -> Void
    let onItemClick: () -> Void
    let content: () -> Content

    init(
        itemTitle: String,
        itemEstimatedEndDate: Date? = nil,
        issues: ListItemIssues = ListItemIssues(icons: [], issuesStrings: []),
        statusIndicator: ListItemStatusIndicator,
        showInfoIcon: Bool = false,
        onInfoClick: @escaping () -> Void = {},
        onIssueClick: @escaping (ListItemIssues) -> Void = { _ in },
        onTitleLongClick: @escaping () -> Void = {},
        onItemClick: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.itemTitle = itemTitle
        self.itemEstimatedEndDate = itemEstimatedEndDate
        self.issues = issues
        self.statusIndicator = statusIndicator
        self.showInfoIcon = showInfoIcon
        self.onInfoClick = onInfoClick
        self.onIssueClick = onIssueClick
        self.onTitleLongClick = onTitleLongClick
        self.onItemClick = onItemClick
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
        }
        .frame(maxWidth: .infinity, minHeight: scaleFactor.scale(Dimens.ListItem.itemHeight), alignment: .top)
        .contentShape(Rectangle())
        .overlay(alignment: .topTrailing) {
            ListItemTimerText(endDate: itemEstimatedEndDate)
                .padding(.top, scaleFactor.scale(Distance.tiny, limit: .lower(1)))
                .padding(.trailing, Distance.tiny)
        }
        .overlay(alignment: .bottom) {
            ListItemTitle(
                text: itemTitle,
                onLongClick: onTitleLongClick,
                onItemClick: onItemClick
            )
            .padding(.horizontal, Distance.default)
            .padding(.bottom, scaleFactor.scale(Dimens.ListItem.verticalPadding))
        }
        .overlay(alignment: .leading) {
            HStack(spacing: 0) {
                statusIndicator.view(side: .start)

                if (!statusIndicator.status.isGroup && showInfoIcon) {
                    ListItemInfoIcon()
                        .padding(.leading, Distance.small)
                        .onTapGesture(perform: onInfoClick)
                }
            }
        }
        .overlay(alignment: .trailing) {
            HStack(spacing: 0) {
                if (!statusIndicator.status.isGroup && !issues.isEmpty()) {
                    ListItemIssuesView(issues: issues, onClick: onIssueClick)
                }

                statusIndicator.view(side: .end)
            }
        }
        .overlay(alignment: .bottom) {
            SeparatorView(style: .list)
        }
        .onTapGesture(perform: onItemClick)
        .background(Color.Supla.surface)
    }
}

private struct ListItemTimerText: View {
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.scaleFactor) private var scaleFactor

    let endDate: Date?
    @State private var currentDate = Date()

    var body: some View {
        if let text = timerText {
            Text(text)
                .font(Font.Supla.bodyMedium(scaleFactor, limit: .upper(0.8)))
                .foregroundColor(Color.Supla.gray)
                .onReceive(timer) { currentDate = $0 }
        }
    }

    private var timerText: String? {
        guard let endDate,
              endDate.timeIntervalSince1970 > currentDate.timeIntervalSince1970
        else { return nil }

        let timeDiff = endDate.differenceInSeconds(currentDate)
        let days = timeDiff.days
        if (days == 0) {
            return String(
                format: "%02d:%02d:%02d",
                timeDiff.hoursInDay,
                timeDiff.minutesInHour,
                timeDiff.secondsInMinute
            )
        } else if (days == 1) {
            return "\(Strings.TimerDetail.dayPattern.arguments(days)) ⏱"
        } else {
            return "\(Strings.TimerDetail.daysPattern.arguments(days)) ⏱"
        }
    }
}

#Preview("Channel") {
    VStack(spacing: 0) {
        ListItemScaffold(
            itemTitle: "Power Switch",
            itemEstimatedEndDate: Date(timeIntervalSinceNow: 154),
            issues: ListItemIssues(icons: [IssueIcon.Warning()], issuesStrings: []),
            statusIndicator: ListItemStatusIndicator(
                status: .channel(.online),
                hasLeftButton: false,
                hasRightButton: false
            ),
            showInfoIcon: true
        ) {
            ListItemMainRow() {
                ListItemIcon(iconResult: .originalSuplaIcon(name: .Icons.fncUnknown))
                ListItemValue(value: "21.4 C")
            }
        }
        .environment(\.scaleFactor, 1)

        ListItemScaffold(
            itemTitle: "Partially online",
            itemEstimatedEndDate: Date(timeIntervalSinceNow: 86400),
            statusIndicator: ListItemStatusIndicator(
                status: .channel(.partiallyOnline),
                hasLeftButton: true,
                hasRightButton: true
            )
        ) {
            ListItemMainRow() {
                ListItemIcon(iconResult: .originalSuplaIcon(name: .Icons.fncUnknown))
                ListItemValue(value: "21.4 C")
            }
        }
        .environment(\.scaleFactor, 1.5)

        ListItemScaffold(
            itemTitle: "Group",
            statusIndicator: ListItemStatusIndicator(
                status: .group(onlinePercentage: 0.75, activePercentage: 0.25),
                hasLeftButton: true,
                hasRightButton: true
            )
        ) {
            ListItemMainRow() {
                ListItemIcon(iconResult: .originalSuplaIcon(name: .Icons.fncUnknown))
                ListItemValue(value: "21.4 C")
            }
        }
        .environment(\.scaleFactor, 0.75)
        
        ListItemScaffold(
            itemTitle: "Item with very long title which gous out of the screen and checks how it is trimmed",
            statusIndicator: ListItemStatusIndicator(
                status: .group(onlinePercentage: 0.75, activePercentage: 0.25),
                hasLeftButton: true,
                hasRightButton: true
            )
        ) {
            ListItemMainRow() {
                ListItemIcon(iconResult: .originalSuplaIcon(name: .Icons.fncUnknown))
                ListItemValue(value: "21.4 C")
            }
        }
        .environment(\.scaleFactor, 0.75)
    }
    .background(Color.Supla.background)
    .environment(\.scaleFactor, 1)
}
