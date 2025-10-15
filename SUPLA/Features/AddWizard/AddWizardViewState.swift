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

extension AddWizardFeature {
    class ViewState: ObservableObject {
        @Published var screens: ScreenStack = .initial()
        @Published var networkSsid: String = ""
        @Published var networkPassword: String = ""
        @Published var rememberPassword: Bool = false
        @Published var networkConfigurationError: Bool = false
        @Published var autoMode: Bool = true
        @Published var processing: Bool = false
        @Published var progress: Float = 0
        @Published var progressLabel: String? = nil
        @Published var deviceParameters: [DeviceParameter] = []
        @Published var canceling: Bool = false
        @Published var showCloudFollowupPopup: Bool = false
        @Published var showManualModePopup: Bool = false
        @Published var providePasswordDialogState: ProvidePasswordDialogState? = nil
        @Published var setPasswordDialogState: SetPasswordDialogState? = nil

        var registrationActivationTime: TimeInterval? = nil
    }
    
    struct ScreenStack {
        let screens: [Screen]
        
        var current: Screen {
            return self.screens.last ?? .welcome
        }
        
        func push(_ screen: Screen) -> ScreenStack {
            var screens = self.screens
            screens.append(screen)
            return .init(screens: screens)
        }
        
        func pop() -> ScreenStack {
            var screens = self.screens
            if (screens.count > 1) {
                screens.removeLast()
            }
            if (screens.last == .manualReconnect) {
                // Manual reconnect screen is a part of configuration process.
                // It should not be shown like manual configuration when going back.
                screens.removeLast()
            }
            if (screens.last == .manualConfiguration) {
                // Manual configuration screen is a part of configuration process.
                // It should not be shown when going back.
                screens.removeLast()
            }
            return .init(screens: screens)
        }
        
        func just(_ screen: Screen) -> ScreenStack {
            return .init(screens: [screen])
        }
        
        static func initial() -> ScreenStack {
            return .init(screens: [.welcome])
        }
    }
    
    enum Screen: Equatable {
        case welcome, networkSelection, configuration, success, manualConfiguration, manualReconnect
        case message(text: [String], action: AddWizardFeature.MessageAction?)
    }
}
