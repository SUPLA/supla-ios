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
struct SuplaValueWidget: Widget {
    let kind: String = "com.acsoftware.ios.supla.SuplaValueWidget"

    var body: some WidgetConfiguration {
        let configuration = AppIntentConfiguration(kind: kind, intent: Intent.self, provider: Provider()) { entry in
            View(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Strings.Widget.valueTitle)
        .description(Strings.Widget.valueDescription)
        .supportedFamilies([.systemSmall])

        if #available(iOS 18.0, *) {
            return configuration.promptsForUserConfiguration()
        } else {
            return configuration
        }
    }
}

// MARK: - Intent

@available(iOS 17.0, *)
extension SuplaValueWidget {
    struct Intent: WidgetConfigurationIntent {
        static var title: LocalizedStringResource = .init("widgets_value_title", defaultValue: "Quick View")

        @Parameter(title: LocalizedStringResource("general_profile", defaultValue: "Profile"))
        var profile: ProfileParameter?

        @Parameter(title: LocalizedStringResource("app_settings.location_label", defaultValue: "Location"))
        var location: LocationParameter?

        @Parameter(title: LocalizedStringResource("general_channel", defaultValue: "Channel"))
        var channel: ChannelParameter?

        init() {
            self.profile = nil
            self.location = nil
            self.channel = nil
        }

        init(profile: ProfileParameter?, location: LocationParameter?, channel: ChannelParameter?) {
            self.profile = profile
            self.location = location
            self.channel = channel
        }

        func content(value: FormattedValue) -> ContentType {
            if let profile, let location, let channel,
               profile.id != -1 && location.id != -1 && channel.id != -1
            {
                .correct(name: channel.name, icon: channel.icon, value: value)
            } else {
                .incorrect
            }
        }
    }
}

// MARK: - Provider

@available(iOS 17.0, *)
extension SuplaValueWidget {
    struct Provider: AppIntentTimelineProvider {
        private let singleCall = SingleCallImpl()

        func placeholder(in context: Context) -> Entry {
            Entry(
                date: .now,
                content: .correct(
                    name: Strings.General.Channel.captionHumidity,
                    icon: .single(.suplaIcon(name: .Icons.fncHumidity)),
                    value: .single("75,4")
                )
            )
        }

        func snapshot(for configuration: Intent, in context: Context) async -> Entry {
            Entry(
                date: .now,
                content: configuration.content(value: getValue(configuration.channel))
            )
        }

        func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
            let entries: [Entry] = [
                Entry(
                    date: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                    content: configuration.content(value: getValue(configuration.channel))
                )
            ]
            return Timeline(entries: entries, policy: .atEnd)
        }

        private func getValue(_ channel: ChannelParameter?) -> FormattedValue {
            if let id = channel?.id,
               let authorizationEntity = channel?.authorizationEntity
            {
                FormattedValue.from(
                    singleCall.getValue(
                        channelId: Int32(id),
                        authorizationEntity: authorizationEntity
                    )
                )
            } else {
                .single("---")
            }
        }
    }
}

// MARK: - Entry

@available(iOS 17.0, *)
extension SuplaValueWidget {
    struct Entry: TimelineEntry {
        let date: Date
        let content: ContentType
    }

    enum ContentType {
        case correct(name: String, icon: GroupShared.WidgetIcon, value: FormattedValue)
        case incorrect
    }

    enum FormattedValue {
        case single(String)
        case double(first: String, second: String)

        var first: String {
            switch self {
            case .single(let icon): icon
            case .double(let first, _): first
            }
        }

        var second: String? {
            switch self {
            case .single: nil
            case .double(_, let second): second
            }
        }

        static let formatter = ValuesFormatterImpl()

        static func from(_ result: SingleCallResult) -> FormattedValue {
            switch (result) {
            case .temperature(let value): .single(formatter.temperatureToString(value: Float(value)))
            case .humidity(let value): .single(formatter.humidityToString(value))
            case .temperatureAndHumidity(let temperature, let humidity):
                .double(
                    first: formatter.temperatureToString(value: Float(temperature)),
                    second: formatter.humidityToString(humidity)
                )
            default: .single("---")
            }
        }
    }
}

// MARK: - View

@available(iOS 17.0, *)
extension SuplaValueWidget {
    struct View: SwiftUI.View {
        let entry: Entry

        init(entry: Entry) {
            self.entry = entry
        }

        var body: some SwiftUI.View {
            switch (entry.content) {
            case .correct(let name, let icon, let value):
                CorrectValue(name: name, icon: icon, value: value)
            case .incorrect: IncorrectValue()
            }
        }

        private func IncorrectValue() -> some SwiftUI.View {
            Text(Strings.Widget.configurationError)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
        }

        private func CorrectValue(name: String, icon: GroupShared.WidgetIcon, value: FormattedValue) -> some SwiftUI.View {
            VStack(spacing: Distance.small) {
                if (icon.second != nil) {
                    VStack(alignment: .leading, spacing: 4) {
                        IconValueRow(icon: icon.first, value: value.first)
                        IconValueRow(icon: icon.second, value: value.second)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    HStack(spacing: Distance.tiny) {
                        icon.first.Image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimens.iconSizeVeryBig, height: Dimens.iconSizeVeryBig)
                        Text(value.first)
                            .fontHeadlineSmall()
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                }
                Text(name)
                    .fontBodyMedium()
                    .lineLimit(2)
            }
        }

        private func IconValueRow(icon: IconResult?, value: String?) -> some SwiftUI.View {
            HStack {
                icon?.Image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimens.iconSizeBig, height: Dimens.iconSizeBig)
                if let value {
                    Text(value)
                        .fontBodyLarge()
                        .lineLimit(1)
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    SuplaValueWidget()
} timeline: {
    SuplaValueWidget.Entry(
        date: .now,
        content: .correct(
            name: Strings.General.Channel.captionHumidity,
            icon: .single(.suplaIcon(name: .Icons.fncHumidity)),
            value: .single("50")
        )
    )

    SuplaValueWidget.Entry(
        date: .now,
        content: .correct(
            name: Strings.General.Channel.captionHumidityAndTemperature,
            icon: .double(first: .suplaIcon(name: .Icons.fncThermometerHome), second: .suplaIcon(name: .Icons.fncHumidity)),
            value: .double(first: "24°C", second: "50")
        )
    )

    SuplaValueWidget.Entry(
        date: .now,
        content: .correct(
            name: Strings.General.Channel.captionHumidity,
            icon: .single(.suplaIcon(name: .Icons.fncHumidity)),
            value: .single("1500%")
        )
    )
}
