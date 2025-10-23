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
    protocol ViewDelegate: AnyObject, ProvidePasswordDialogDelegate, SetPasswordDialogDelegate, SpacesAlertDialogDelegate {
        func onCancel(_ screen: Screen)
        func onBack(_ screen: Screen)
        func onNext(_ screen: Screen)
        func onMessageAction(_ action: AddWizardFeature.MessageAction)
        func onWifiSettings()
        func onFollowupPopupClose()
        func onFollowupPopupOpen()
        func onManualPopupContinueManual()
        func onManualPopupContinueAuto()
        func onManualPopupClose()
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
                        onAgain: { delegate?.onMessageAction(.repeatSuccess) }
                    )
                        
                    if (state.showCloudFollowupPopup) {
                        CloudFollowupPopup(
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
                    
                    if (state.showManualModePopup) {
                        ManualModePopup(
                            onContinueManual: delegate?.onManualPopupContinueManual,
                            onContinueAuto: delegate?.onManualPopupContinueAuto,
                            onClose: delegate?.onManualPopupClose
                        )
                    }
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
                case .manualReconnect:
                    AddWizardFeature.AddWizardManualReconnect(
                        onCancel: { delegate?.onCancel(screen) },
                        onNext: { delegate?.onNext(screen) },
                        onSettings: { delegate?.onWifiSettings() }
                    )
                }
                
                if (state.canceling) {
                    SuplaCore.LoadingScrim()
                }
                
                if let dialogState = state.providePasswordDialogState {
                    AddWizardFeature.ProvidePasswordDialog(
                        state: dialogState,
                        delegate: delegate
                    )
                }
                
                if let dialogState = state.setPasswordDialogState {
                    AddWizardFeature.SetPasswordDialog(
                        state: dialogState,
                        delegate: delegate
                    )
                }
                
                if (state.showSpacesPopup) {
                    AddWizardFeature.SpacesAlertDialog(
                        networkName: state.networkSsid,
                        delegate: delegate
                    )
                }
            }
        }
    }
}

struct CloudFollowupPopup: View {
    var onPositiveButtonClick: (() -> Void)?
    var onNegativeButtonClick: (() -> Void)?
    
    init(
        onPositiveButtonClick: (() -> Void)? = nil,
        onNegativeButtonClick: (() -> Void)? = nil
    ) {
        self.onPositiveButtonClick = onPositiveButtonClick
        self.onNegativeButtonClick = onNegativeButtonClick
    }
    
    var body: some View {
        SuplaCore.Dialog.Base(onDismiss: {}) {
            SuplaCore.Dialog.Header(title: Strings.AddWizard.cloudFollowupTitle)
                
            SwiftUI.Text(Strings.AddWizard.cloudFollowupMessage)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], Distance.default)
                
            SuplaCore.Dialog.VerticalButtons(
                onNegativeClick: onNegativeButtonClick ?? {},
                onPositiveClick: onPositiveButtonClick ?? {},
                negativeText: Strings.AddWizard.cloudFollowupClose,
                positiveText: Strings.AddWizard.cloudFollowupGoToCloud
            )
        }
    }
}

struct ManualModePopup: View {
    var onContinueManual: (() -> Void)?
    var onContinueAuto: (() -> Void)?
    var onClose: (() -> Void)?
    
    init(
        onContinueManual: (() -> Void)? = nil,
        onContinueAuto: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.onContinueManual = onContinueManual
        self.onContinueAuto = onContinueAuto
        self.onClose = onClose
    }
    
    var body: some View {
        SuplaCore.Dialog.Base(onDismiss: onClose ?? {}) {
            SuplaCore.Dialog.Header(title: Strings.AddWizard.manualModePopupTitle)
                
            SwiftUI.Text(Strings.AddWizard.manualModePopupMessage)
                .fontBodyMedium()
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], Distance.default)
                
            SuplaCore.Dialog.VerticalButtons(
                onNegativeClick: onContinueAuto ?? {},
                onPositiveClick: onContinueManual ?? {},
                negativeText: Strings.AddWizard.manualModePopupResign,
                positiveText: Strings.AddWizard.manualModePopupContinue
            )
        }
    }
}

#Preview {
    AddWizardFeature.View(
        state: AddWizardFeature.ViewState()
    )
}

#Preview("Cloud followup popup") {
    let state = AddWizardFeature.ViewState()
    state.showCloudFollowupPopup = true
    state.screens = state.screens.just(.success)
    
    return AddWizardFeature.View(
        state: state
    )
}

#Preview("Cloud manual mode popup") {
    let state = AddWizardFeature.ViewState()
    state.showManualModePopup = true
    state.screens = state.screens.just(.message(text: [""], action: .repeatError))
    
    return AddWizardFeature.View(
        state: state
    )
}
