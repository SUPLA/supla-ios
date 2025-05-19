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

@available(iOS 18.0, *)
struct SuplaControlButtonWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: "com.acsoftware.ios.supla.SUPLAWidgets",
            intent: SuplaControlButtonConfigurationIntent.self,
        ) { value in
            ControlWidgetButton(action: SuplaControlButtonConfigurationIntent(action: value.action), label: {
                Label(value.action?.caption ?? "", image: value.action?.sfIcon ?? "ControlWidgetIcon")
                    .controlWidgetActionHint(Text(value.action?.caption ?? Strings.Widget.controlHint))
            })
            .privacySensitive()
            .tint(Color.Supla.primary)
        }
        .displayName(LocalizedStringResource.Widgets.controlName)
        .description(LocalizedStringResource.Widgets.controlDescription)
        .promptsForUserConfiguration()
    }
}

@available(iOS 17.0, *)
struct SuplaControlButtonConfigurationIntent: ControlConfigurationIntent {
    static var title: LocalizedStringResource = .init("widgets_control_title", defaultValue: "Control Button")

    @Parameter(title: LocalizedStringResource("widgets_selected_action", defaultValue: "Selected Action"))
    var action: GroupShared.WidgetAction?

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
