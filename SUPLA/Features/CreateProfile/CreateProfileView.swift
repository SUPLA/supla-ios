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

extension CreateProfileFeature {
    struct View: SwiftUI.View {
        @ObservedObject var viewState: ViewState
        @State private var showDeleteOptions: Bool = false
        
        var onAdvancedAuthorizationChange: (Bool) -> Void = { _ in }
        var onServerAutoDetectChange: (Bool) -> Void = { _ in }
        var onLogout: () -> Void = { }
        var onDelete: () -> Void = { }
        var onSave: () -> Void = { }
        var onCreateAccount: () -> Void = { }
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Spacer()
                        Toggle(isOn: $viewState.advancedAuthorization) {
                            Text(Strings.CreateProfile.advancedSettings)
                                .fontBodyMedium()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .onChange(of: viewState.advancedAuthorization) {
                            onAdvancedAuthorizationChange($0)
                        }
                    }
                    
                    if (!viewState.advancedAuthorization) {
                        Text(Strings.CreateProfile.yourAccountLabel)
                            .fontHeadlineLarge()
                            .multilineTextAlignment(.center)
                            .padding([.top], 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if (viewState.profileNameVisible) {
                        SwiftUI.Text(Strings.CreateProfile.profileNameLabel)
                            .fontCaptionSmall()
                            .textColor(.Supla.onBackground)
                            .padding([.top], Distance.default)
                        
                        TextField("", text: $viewState.profileName)
                            .textFieldStyle(StandardTextFieldStyle())
                            .autocapitalization(.none)
                    } else {
                        Spacer().frame(height: 40)
                    }
                    
                    if (viewState.advancedAuthorization) {
                        Picker("", selection: $viewState.authorisationType) {
                            Text(Strings.CreateProfile.emailSegment)
                                .fontBodySmall()
                                .tag(AuthorizationType.email)
                            Text(Strings.CreateProfile.accessIdSegment)
                                .fontBodySmall()
                                .tag(AuthorizationType.accessId)
                        }
                        .padding([.top], Distance.default)
                        .pickerStyle(.segmented)
                    }
                    
                    switch (viewState.authorisationType) {
                    case .email:
                        Text(Strings.CreateProfile.emailLabel)
                            .fontCaptionSmall()
                            .textColor(.Supla.onBackground)
                            .padding([.top], Distance.default)
                        TextField("", text: $viewState.email)
                            .textFieldStyle(StandardTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        if (viewState.advancedAuthorization) {
                            SwiftUI.Text(Strings.CreateProfile.serverLabel)
                                .fontCaptionSmall()
                                .textColor(.Supla.onBackground)
                                .padding([.top], Distance.default)
                            HStack {
                                TextField("", text: $viewState.serwerAddress)
                                    .textFieldStyle(StandardTextFieldStyle(disabled: viewState.serverAutoDetect))
                                    .autocapitalization(.none)
                                
                                Toggle(isOn: $viewState.serverAutoDetect) {
                                    Text("Auto").fontBodyMedium()
                                }
                                .toggleStyle(iOSCheckboxToggleStyle(color: .primary, textFirst: true))
                                .onChange(of: viewState.serverAutoDetect) { onServerAutoDetectChange($0) }
                            }
                        }
                    case .accessId:
                        SwiftUI.Text(Strings.CreateProfile.accessIdLabel)
                            .fontCaptionSmall()
                            .textColor(.Supla.onBackground)
                            .padding([.top], Distance.default)
                        TextField("", text: $viewState.accessId)
                            .textFieldStyle(StandardTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        SwiftUI.Text(Strings.CreateProfile.passwordLabel)
                            .fontCaptionSmall()
                            .textColor(.Supla.onBackground)
                            .padding([.top], Distance.default)
                        SecureField("", text: $viewState.accessIdPassword)
                            .textFieldStyle(StandardTextFieldStyle())
                        
                        SwiftUI.Text(Strings.CreateProfile.serverLabel)
                            .fontCaptionSmall()
                            .textColor(.Supla.onBackground)
                            .padding([.top], Distance.default)
                        TextField("", text: $viewState.serwerAddress)
                            .textFieldStyle(StandardTextFieldStyle())
                            .autocapitalization(.none)
                        
                        SwiftUI.Text(Strings.CreateProfile.wizardWarningText)
                            .fontBodyMedium()
                            .textColor(.Supla.error)
                            .multilineTextAlignment(.center)
                            .padding([.top, .bottom], 4)
                            .padding([.leading, .trailing], Distance.small)
                            .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.error))
                            .padding([.top, .bottom], Distance.small)
                    }
                    
                    Spacer()
                    
                    FilledButton(title: Strings.General.ok, fullWidth: true) { onSave() }
                    
                    if (viewState.deleteButtonVisible) {
                        BorderedButton(
                            title: Strings.Profiles.delete,
                            fullWidth: true,
                            action: { showDeleteOptions = true }
                        )
                            .padding([.top], Distance.small)
                            .actionSheet(isPresented: $showDeleteOptions) {
                                ActionSheet(
                                    title: SwiftUI.Text(Strings.Cfg.removalConfirmationTitle),
                                    buttons: [
                                        .destructive(SwiftUI.Text(Strings.Cfg.removalActionLogout)) { onLogout() },
                                        .destructive(SwiftUI.Text(Strings.Cfg.removalActionRemove)) { onDelete() },
                                        .cancel(SwiftUI.Text(Strings.General.cancel)) {
                                            showDeleteOptions = false
                                        }
                                    ]
                                )
                            }
                    }
                    
                    if (!viewState.profileNameVisible) {
                        SwiftUI.Text(Strings.CreateProfile.createAccountPrompt)
                            .fontBodyMedium()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding([.top], Distance.default)
                        
                        TextButton(title: Strings.CreateProfile.createAccountButton) { onCreateAccount() }
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(Distance.default)
                
                if (viewState.presentBasicModeNotAvaiable) {
                    BasicModeUnavailableDialog { viewState.presentBasicModeNotAvaiable = false }
                } else if (viewState.presentRemovalFailure) {
                    RemovalFailureDialog { viewState.presentRemovalFailure = false }
                } else if (viewState.presentEmptyName) {
                    EmptyNameDialog { viewState.presentEmptyName = false }
                } else if (viewState.presentDuplicatedName) {
                    DuplicatedNameDialog { viewState.presentDuplicatedName = false }
                } else if (viewState.presentRequiredDataMissing) {
                    RequiredDataMissingDialog { viewState.presentRequiredDataMissing = false }
                }
                
                if (viewState.loading) {
                    SuplaCore.LoadingScrim()
                }
            }
        }
    }
}

private struct BasicModeUnavailableDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.CreateProfile.basicWarningTitle,
            message: Strings.CreateProfile.basicWarningMessage,
            button: Strings.General.ok,
            onDismiss: onDismiss
        )
    }
}

private struct RemovalFailureDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.Cfg.Dialogs.Failed.title,
            message: Strings.Cfg.Dialogs.Failed.message,
            button: Strings.General.ok,
            onDismiss: onDismiss
        )
    }
}

private struct EmptyNameDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.missing_name,
            button: Strings.General.ok,
            onDismiss: onDismiss
        )
    }
}

private struct DuplicatedNameDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.duplicated_name,
            button: Strings.General.ok,
            onDismiss: onDismiss
        )
    }
}

private struct RequiredDataMissingDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.incomplete,
            button: Strings.General.ok,
            onDismiss: onDismiss
        )
    }
}

#Preview("First account") {
    let viewState = CreateProfileFeature.ViewState()
    viewState.profileNameVisible = false
    return CreateProfileFeature.View(viewState: viewState)
}

#Preview("Edit account") {
    let viewState = CreateProfileFeature.ViewState()
    viewState.profileNameVisible = true
    viewState.deleteButtonVisible = true
    return CreateProfileFeature.View(viewState: viewState)
}
