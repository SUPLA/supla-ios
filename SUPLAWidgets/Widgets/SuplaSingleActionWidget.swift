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
struct SuplaSingleActionWidget: Widget {
    let kind: String = "com.acsoftware.ios.supla.SuplaSingleActionWidget"

    var body: some WidgetConfiguration {
        let configuration = AppIntentConfiguration(kind: kind, intent: SingleIntent.self, provider: Provider()) {
            View(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Strings.Widget.singleActionTitle)
        .description(Strings.Widget.singleActionDescription)
        .supportedFamilies([.systemSmall])

        if #available(iOS 18.0, *) {
            return configuration.promptsForUserConfiguration()
        } else {
            return configuration
        }
    }
}

@available(iOS 17.0, *)
extension SuplaSingleActionWidget {
    struct SingleIntent: WidgetConfigurationIntent {
        static var title: LocalizedStringResource = .init("widgets_single_action_title", defaultValue: "Single action")

        @Parameter(title: LocalizedStringResource("widgets_selected_action", defaultValue: "Selected Action"))
        var action: GroupShared.WidgetAction?

        var content: WidgetContent {
            if let action {
                .correct(profile: action.profileName, name: action.caption, action: action)
            } else {
                .incorrect
            }
        }

        init(action: GroupShared.WidgetAction?) {
            self.action = action
        }

        init() {
            self.action = nil
        }

        func perform() async throws -> some IntentResult {
            executeAction(action: action)
            return .result()
        }
    }
}

@available(iOS 17.0, *)
extension SuplaSingleActionWidget {
    struct Provider: AppIntentTimelineProvider {
        func placeholder(in context: Context) -> Entry {
            Entry(
                date: .now,
                content: .correct(
                    profile: Strings.Profiles.defaultProfileName,
                    name: Strings.General.Channel.captionTerraceAwning,
                    action: .mock(1, icon: "\(String.Icons.fncTerraceAwning)-open")
                )
            )
        }

        func snapshot(for configuration: SingleIntent, in context: Context) async -> Entry {
            Entry(
                date: .now,
                content: configuration.content
            )
        }

        func timeline(for configuration: SingleIntent, in context: Context) async -> Timeline<Entry> {
            let entries: [Entry] = [
                Entry(
                    date: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                    content: configuration.content
                )
            ]
            return Timeline(entries: entries, policy: .never)
        }
    }
}

@available(iOS 17.0, *)
extension SuplaSingleActionWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let content: WidgetContent
    }

    enum WidgetContent {
        case correct(profile: String, name: String, action: GroupShared.WidgetAction)
        case incorrect
    }
}

@available(iOS 17.0, *)
extension SuplaSingleActionWidget {
    struct View: SwiftUI.View {
        let entry: Entry

        init(entry: Entry) {
            self.entry = entry
        }

        var body: some SwiftUI.View {
            switch (entry.content) {
            case .correct(let profile, let name, let action):
                CorrectValue(profile: profile, name: name, action: action)
            case .incorrect: IncorrectValue()
            }
        }

        private func IncorrectValue() -> some SwiftUI.View {
            Text(Strings.Widget.configurationError)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
        }

        private func CorrectValue(profile: String, name: String, action: GroupShared.WidgetAction) -> some SwiftUI.View {
            VStack(spacing: Distance.tiny) {
                Text(profile)
                    .fontBodySmall()
                    .lineLimit(1)
                Button(intent: TriggerActionIntent(action: action)) {
                    action.icon.Image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimens.iconSizeVeryBig, height: Dimens.iconSizeVeryBig)
                        .padding(Distance.tiny)
                        .background {
                            RoundedRectangle(cornerRadius: Dimens.buttonRadius).fill(Color.Supla.surface)
                        }
                }
                .buttonStyle(.plain)
                .frame(maxHeight: .infinity, alignment: .center)
                Text(name)
                    .fontBodyMedium()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    SuplaSingleActionWidget()
} timeline: {
    SuplaSingleActionWidget.Entry(
        date: .now,
        content: .correct(
            profile: Strings.Profiles.defaultProfileName,
            name: Strings.General.Channel.captionTerraceAwning,
            action: .mock(1, icon: "\(String.Icons.fncTerraceAwning)-open")
        )
    )

    SuplaSingleActionWidget.Entry(
        date: .now,
        content: .incorrect
    )
}
