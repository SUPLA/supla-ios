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

@available(iOS 17.0, *)
struct TriggerActionIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Action trigger"
    static var description = IntentDescription("Triggers single action.")
    
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
