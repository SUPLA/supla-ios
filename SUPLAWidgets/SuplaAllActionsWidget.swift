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

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 17.0, *)
struct SuplaAllActionsWidget: Widget {
    let kind: String = "com.acsoftware.ios.supla.SuplaAllActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            View(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Strings.Widget.actionsName)
        .description(Strings.Widget.actionsDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@available(iOS 17.0, *)
extension SuplaAllActionsWidget {
    struct View: SwiftUI.View {
        @Environment(\.widgetFamily) var family
        
        var entry: Provider.Entry
        
        var body: some SwiftUI.View {
            VStack(spacing: Distance.small) {
                Text(Strings.Widget.actionsName).fontBodyLarge()
                if (entry.actions.isEmpty) {
                    Text(Strings.Widget.emptyHint)
                        .multilineTextAlignment(.center)
                        .fontBodyMedium()
                } else {
                    DisplayActions(from: 0)
                    .frame(width: 282, alignment: .leading)
                    if (family == .systemLarge) {
                        if (entry.actions.count > 5) {
                            DisplayActions(from: 5)
                        }
                        if (entry.actions.count > 10) {
                            DisplayActions(from: 10)
                        }
                    }
                }
            }
        }
        
        private func DisplayActions(from: Int) -> some SwiftUI.View {
            HStack(alignment: .top, spacing: Distance.tiny) {
                ForEach(entry.actions[from...].prefix(5)) { item in
                    ActionButton(item: item)
                }
            }
            .frame(width: 282, alignment: .leading)
        }
    }
    
    private struct ActionButton: SwiftUI.View {
        
        let item: GroupShared.WidgetAction
        
        var body: some SwiftUI.View {
            Button(intent: TriggerActionIntent(action: item)) {
                VStack {
                    item.icon.Image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                        .padding(Distance.tiny)
                        .background {
                            RoundedRectangle(cornerRadius: Dimens.buttonRadius).fill(Color.Supla.surface)
                        }
                        .foregroundColor(Color.Supla.onBackground)
                    Text(item.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fontBodySmall()
                        .textColor(.Supla.onBackground)
                }
                .frame(maxWidth: 70)
            }
            .buttonStyle(.plain)
        }
    }

    struct TriggerActionIntent: AppIntent {
        
        static var title: LocalizedStringResource = "Actions"
        static var description = IntentDescription("Simplifies access to the most common actions.")
        
        @Parameter(title: "Action")
        var action: GroupShared.WidgetAction?
        
        init() {
            action = nil
        }
        
        init (action: GroupShared.WidgetAction) {
            self.action = action
        }

        func perform() async throws -> some IntentResult {
            executeAction(action: action)
            return .result()
        }
    }
}

@available(iOS 17.0, *)
extension SuplaAllActionsWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let actions: [GroupShared.WidgetAction]
    }
}

@available(iOS 17.0, *)
extension SuplaAllActionsWidget {
    struct Provider: TimelineProvider {
        
        private let actionsProvider = GroupShared.Implementation()
        
        func placeholder(in context: Context) -> Entry {
            Entry(date: Date(), actions: [])
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
            completion(
                Entry(
                    date: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                    actions: actionsProvider.actions
                )
            )
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            let entry = Entry(
                date: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                actions: actionsProvider.actions
            )
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

@available(iOS 17.0, *)
private func buildMocks(count: Int32) -> [GroupShared.WidgetAction] {
    var result: [GroupShared.WidgetAction] = []
    
    for i in 0 ... count {
        result.append(GroupShared.WidgetAction.mock(i, caption: "Garage door \(i)"))
    }
    
    return result
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    SuplaAllActionsWidget()
} timeline: {
    SuplaAllActionsWidget.Entry(date: .now, actions: buildMocks(count: 7))
    SuplaAllActionsWidget.Entry(date: .now, actions: [])
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    SuplaAllActionsWidget()
} timeline: {
    SuplaAllActionsWidget.Entry(date: .now, actions: buildMocks(count: 25))
    SuplaAllActionsWidget.Entry(date: .now, actions: [])
}

@available(iOSApplicationExtension 17.0, *)
private extension GroupShared.WidgetAction {
    static func mock(_ id: Int32, caption: String = "Garage door", icon: String = "fnc_garage_door-open") -> Self {
        .init(
            profileId: id,
            subjectType: .channel,
            subjectId: 1,
            caption: caption,
            action: .close,
            icon: .suplaIcon(name: icon),
            sfIcon: nil,
            authorizationEntity: nil
        )
    }
}
