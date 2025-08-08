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
    protocol ViewDelegate: AnyObject, ProvidePasswordDialogDelegate, SetPasswordDialogDelegate {
        func onCancel(_ screen: Screen)
        func onBack(_ screen: Screen)
        func onNext(_ screen: Screen)
        func onMessageAction(_ action: AddWizardFeature.MessageAction)
        func onWifiSettings()
        func onFollowupPopupClose()
        func onFollowupPopupOpen()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        weak var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(color: .Supla.primaryContainer) {
                let screen = state.screens.current
                switch (screen) {
                case .welcome:
                    AddWizardFeature.AddWizardWelcomeView(
                        processing: state.processing,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) }
                    )
                case .networkSelection:
                    AddWizardFeature.AddWizardNetworkSelectionView(
                        networkName: $state.networkSsid,
                        networkPassword: $state.networkPassword,
                        rememberPassword: $state.rememberPassword,
                        error: state.networkConfigurationError,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) },
                        onNetworkSearch: {}
                    )
                case .configuration:
                    AddWizardFeature.AddWizardConfigurationView(
                        autoMode: $state.autoMode,
                        processing: state.processing,
                        progress: state.progress,
                        progressLabel: state.progressLabel,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) }
                    )
                case .success:
                    AddWizardFeature.AddWizardSuccessView(
                        parameters: state.deviceParameters,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) },
                        onAgain: { delegate?.onMessageAction(.repeat) }
                    )
                    if let dialogState = state.followupPopupState {
                        SuplaCore.AlertDialog(
                            state: dialogState,
                            onDismiss: {},
                            onPositiveButtonClick: delegate?.onFollowupPopupOpen,
                            onNegativeButtonClick: delegate?.onFollowupPopupClose
                        )
                    }
                case .message(let text, let action):
                    AddWizardFeature.AddWizardMessageView(
                        messages: text,
                        action: action,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) },
                        onAction: { delegate?.onMessageAction($0) }
                    )
                case .manualConfiguration:
                    AddWizardFeature.AddWizardManualInstruction(
                        processing: state.processing,
                        progress: state.progress,
                        progressLabel: state.progressLabel,
                        onCancel: { delegate?.onCancel(screen) },
                        onBack: { delegate?.onBack(screen) },
                        onNext: { delegate?.onNext(screen) },
                        onSettings: { delegate?.onWifiSettings() }
                    )
                }
                
                if (state.canceling) {
                    SuplaCore.LoadingScrim()
                }
                
                if let dialogState = state.providePasswordDialogState {
                    ProvidePasswordDialog(
                        state: dialogState,
                        delegate: delegate
                    )
                }
                
                if let dialogState = state.setPasswordDialogState {
                    SetPasswordDialog(
                        state: dialogState,
                        delegate: delegate
                    )
                }
            }
        }
    }
}

#Preview {
    AddWizardFeature.View(
        state: AddWizardFeature.ViewState()
    )
}
