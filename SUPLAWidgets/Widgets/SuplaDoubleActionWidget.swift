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
struct SuplaDoubleActionWidget: Widget {
    let kind: String = "com.acsoftware.ios.supla.SuplaDoubleActionWidget"

    var body: some WidgetConfiguration {
        let configuration = AppIntentConfiguration(kind: kind, intent: DoubleIntent.self, provider: Provider()) {
            View(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Strings.Widget.doubleActionTitle)
        .description(Strings.Widget.doubleActionDescription)
        .supportedFamilies([.systemSmall])

        if #available(iOS 18.0, *) {
            return configuration.promptsForUserConfiguration()
        } else {
            return configuration
        }
    }
}

@available(iOS 17.0, *)
extension SuplaDoubleActionWidget {
    struct DoubleIntent: WidgetConfigurationIntent {
        static var title: LocalizedStringResource = .init("widgets_double_action_title", defaultValue: "Double action")

        @Parameter(title: LocalizedStringResource("widgets_first_action", defaultValue: "First Action"))
        var firstAction: GroupShared.WidgetAction?
        
        @Parameter(title: LocalizedStringResource("widgets_second_action", defaultValue: "Second Action"))
        var secondAction: GroupShared.WidgetAction?
        
        @Parameter(title: LocalizedStringResource("car_play_display_name", defaultValue: "Display name"))
        var caption: String?

        var content: WidgetContent {
            if let firstAction, let secondAction, let caption {
                .correct(profile: firstAction.profileName, name: caption, firstAction: firstAction, secondAction: secondAction)
            } else {
                .incorrect
            }
        }

        init(firstAction: GroupShared.WidgetAction?, secondAction: GroupShared.WidgetAction?, caption: String?) {
            self.firstAction = firstAction
            self.secondAction = secondAction
            self.caption = caption
        }

        init() {
            self.firstAction = nil
            self.secondAction = nil
            self.caption = nil
        }

        func perform() async throws -> some IntentResult {
            return .result()
        }
    }
}

@available(iOS 17.0, *)
extension SuplaDoubleActionWidget {
    struct Provider: AppIntentTimelineProvider {
        func placeholder(in context: Context) -> Entry {
            Entry(
                date: .now,
                content: .correct(
                    profile: Strings.Profiles.defaultProfileName,
                    name: Strings.General.Channel.captionTerraceAwning,
                    firstAction: .mock(1, icon: "\(String.Icons.fncTerraceAwning)-open"),
                    secondAction: .mock(2, icon: "\(String.Icons.fncTerraceAwning)-closed")
                )
            )
        }

        func snapshot(for configuration: DoubleIntent, in context: Context) async -> Entry {
            Entry(
                date: .now,
                content: configuration.content
            )
        }

        func timeline(for configuration: DoubleIntent, in context: Context) async -> Timeline<Entry> {
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
extension SuplaDoubleActionWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let content: WidgetContent
    }

    enum WidgetContent {
        case correct(profile: String, name: String, firstAction: GroupShared.WidgetAction, secondAction: GroupShared.WidgetAction)
        case incorrect
    }
}

@available(iOS 17.0, *)
extension SuplaDoubleActionWidget {
    struct View: SwiftUI.View {
        let entry: Entry

        init(entry: Entry) {
            self.entry = entry
        }

        var body: some SwiftUI.View {
            switch (entry.content) {
            case .correct(let profile, let name, let firstAction, let secondAction):
                CorrectValue(profile: profile, name: name, firstAction: firstAction, secondAction: secondAction)
            case .incorrect: IncorrectValue()
            }
        }

        private func IncorrectValue() -> some SwiftUI.View {
            Text(Strings.Widget.configurationError)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
        }

        private func CorrectValue(profile: String, name: String, firstAction: GroupShared.WidgetAction, secondAction: GroupShared.WidgetAction) -> some SwiftUI.View {
            VStack(spacing: Distance.tiny) {
                Text(profile)
                    .fontBodySmall()
                    .lineLimit(1)
                HStack(spacing: Distance.small) {
                    Button(intent: TriggerActionIntent(action: firstAction)) {
                        firstAction.icon.Image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                            .padding(Distance.tiny)
                            .background {
                                RoundedRectangle(cornerRadius: Dimens.buttonRadius).fill(Color.Supla.surface)
                            }
                    }
                    .buttonStyle(.plain)
                    Button(intent: TriggerActionIntent(action: secondAction)) {
                        secondAction.icon.Image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                            .padding(Distance.tiny)
                            .background {
                                RoundedRectangle(cornerRadius: Dimens.buttonRadius).fill(Color.Supla.surface)
                            }
                    }
                    .buttonStyle(.plain)
                }
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
    SuplaDoubleActionWidget()
} timeline: {
    SuplaDoubleActionWidget.Entry(
        date: .now,
        content: .correct(
            profile: Strings.Profiles.defaultProfileName,
            name: Strings.General.Channel.captionTerraceAwning,
            firstAction: .mock(1, icon: "\(String.Icons.fncTerraceAwning)-open"),
            secondAction: .mock(2, icon: "\(String.Icons.fncTerraceAwning)-closed")
        )
    )

    SuplaDoubleActionWidget.Entry(
        date: .now,
        content: .incorrect
    )
}
