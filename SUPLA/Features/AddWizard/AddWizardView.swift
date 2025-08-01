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
    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        
        let onCancel: (Screen) -> Void
        let onBack: (Screen) -> Void
        let onNext: (Screen) -> Void
        let onMessageAction: (AddWizardFeature.MessageAction) -> Void
        let onWifiSettings: () -> Void
        let onFollowupPopupClose: () -> Void
        let onFollowupPopupOpen: () -> Void
        
        var body: some SwiftUI.View {
            BackgroundStack(color: .Supla.primaryContainer) {
                let screen = state.screens.current
                switch (screen) {
                case .welcome:
                    AddWizardFeature.AddWizardWelcomeView(
                        processing: state.processing,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) }
                    )
                case .networkSelection:
                    AddWizardFeature.AddWizardNetworkSelectionView(
                        networkName: $state.networkSsid,
                        networkPassword: $state.networkPassword,
                        rememberPasswrord: $state.rememberPassword,
                        error: state.networkConfigurationError,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) },
                        onNetworkSearch: {}
                    )
                case .configuration:
                    AddWizardFeature.AddWizardConfigurationView(
                        autoMode: $state.autoMode,
                        processing: state.processing,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) }
                    )
                case .success:
                    AddWizardFeature.AddWizardSuccessView(
                        parameters: state.deviceParameters,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) },
                        onAgain: { onMessageAction(.repeat) }
                    )
                    if let dialogState = state.followupPopupState {
                        SuplaCore.AlertDialog(
                            state: dialogState,
                            onDismiss: {},
                            onPositiveButtonClick: onFollowupPopupOpen,
                            onNegativeButtonClick: onFollowupPopupClose
                        )
                    }
                case .message(let text, let action):
                    AddWizardFeature.AddWizardMessageView(
                        messages: text,
                        action: action,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) },
                        onAction: onMessageAction
                    )
                case .manualConfiguration:
                    AddWizardFeature.AddWizardManualInstruction(
                        processing: state.processing,
                        onCancel: { onCancel(screen) },
                        onBack: { onBack(screen) },
                        onNext: { onNext(screen) },
                        onSettings: onWifiSettings
                    )
                }
                
                if (state.canceling) {
                    SuplaCore.LoadingScrim()
                }
            }
        }
    }
}

#Preview {
    AddWizardFeature.View(
        state: AddWizardFeature.ViewState(),
        onCancel: { _ in },
        onBack: { _ in },
        onNext: { _ in },
        onMessageAction: { _ in },
        onWifiSettings: {},
        onFollowupPopupClose: {},
        onFollowupPopupOpen: {}
    )
}
