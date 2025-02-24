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
        
        var onAdvancedAuthorizationChange: (Bool) -> Void = { _ in }
        var onServerAutoDetectChange: (Bool) -> Void = { _ in }
        var onLogout: () -> Void = {}
        var onDelete: () -> Void = {}
        var onSave: () -> Void = {}
        var onCreateAccount: () -> Void = {}
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .topLeading) {
                
                TopInputsView(
                    advancedAuthorization: $viewState.advancedAuthorization,
                    authorisationType: $viewState.authorisationType,
                    profileName: $viewState.profileName,
                    email: $viewState.email,
                    serverAutoDetect: $viewState.serverAutoDetect,
                    serverAddress: $viewState.serverAddress,
                    accessId: $viewState.accessId,
                    accessIdPassword: $viewState.accessIdPassword,
                    profileNameVisible: viewState.profileNameVisible,
                    deleteButtonVisible: viewState.deleteButtonVisible,
                    onAdvancedAuthorizationChange: onAdvancedAuthorizationChange,
                    onServerAutoDetectChange: onServerAutoDetectChange
                )
                BottomButtonsView(
                    deleteButtonVisible: viewState.deleteButtonVisible,
                    profileNameVisible: viewState.profileNameVisible,
                    onLogout: onLogout,
                    onDelete: onDelete,
                    onSave: onSave,
                    onCreateAccount: onCreateAccount
                )
                
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

private struct TopInputsView: View {
    @Binding var advancedAuthorization: Bool
    @Binding var authorisationType: AuthorizationType
    @Binding var profileName: String
    @Binding var email: String
    @Binding var serverAutoDetect: Bool
    @Binding var serverAddress: String
    @Binding var accessId: String
    @Binding var accessIdPassword: String
    
    var profileNameVisible: Bool
    var deleteButtonVisible: Bool
    var onAdvancedAuthorizationChange: (Bool) -> Void = { _ in }
    var onServerAutoDetectChange: (Bool) -> Void = { _ in }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Spacer()
                    Toggle(isOn: $advancedAuthorization) {
                        Text(Strings.CreateProfile.advancedSettings)
                            .fontBodyMedium()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .onChange(of: advancedAuthorization) {
                        onAdvancedAuthorizationChange($0)
                    }
                }
                
                if (!advancedAuthorization) {
                    Text(Strings.CreateProfile.yourAccountLabel)
                        .fontHeadlineLarge()
                        .multilineTextAlignment(.center)
                        .padding([.top], 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if (profileNameVisible) {
                    TextFieldWithLabel(Strings.CreateProfile.profileNameLabel, $profileName)
                } else {
                    Spacer().frame(height: 40)
                }
                
                if (advancedAuthorization) {
                    Picker("", selection: $authorisationType) {
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
                
                switch (authorisationType) {
                case .email:
                    EmailAuthorizationView(
                        email: $email,
                        serverAutoDetect: $serverAutoDetect,
                        serverAddress: $serverAddress,
                        advancedAuthorization: advancedAuthorization,
                        onServerAutoDetectChange: onServerAutoDetectChange
                    )
                case .accessId:
                    AccessIdAuthorizationView(
                        accessId: $accessId,
                        accessIdPassword: $accessIdPassword,
                        serverAddress: $serverAddress
                    )
                }
            }
            .padding([.top, .trailing, .leading], Distance.default)
        }
        .padding([.bottom], deleteButtonVisible || !profileNameVisible ? 150 : 96)
    }
}

private struct BottomButtonsView: View {
    var deleteButtonVisible: Bool
    var profileNameVisible: Bool
    
    var onLogout: () -> Void = {}
    var onDelete: () -> Void = {}
    var onSave: () -> Void = {}
    var onCreateAccount: () -> Void = {}
    
    @State private var showDeleteOptions: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            FilledButton(title: Strings.General.ok, fullWidth: true) { onSave() }
                .padding([.bottom], Distance.small)
            
            if (deleteButtonVisible) {
                BorderedButton(
                    title: Strings.Profiles.delete,
                    fullWidth: true,
                    action: { showDeleteOptions = true }
                )
                .padding([.top], Distance.tiny)
                .padding([.bottom], Distance.small)
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
            
            if (!profileNameVisible) {
                SwiftUI.Text(Strings.CreateProfile.createAccountPrompt)
                    .fontBodyMedium()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top], Distance.tiny)
                
                TextButton(title: Strings.CreateProfile.createAccountButton) { onCreateAccount() }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding([.leading, .top, .trailing], Distance.default)
        .padding([.bottom], Distance.tiny)
    }
}

private struct BasicModeUnavailableDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.CreateProfile.basicWarningTitle,
            message: Strings.CreateProfile.basicWarningMessage,
            onDismiss: onDismiss,
            negativeButtonText: Strings.General.ok,
            onNegativeButtonClick: onDismiss
        )
    }
}

private struct RemovalFailureDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.Cfg.Dialogs.Failed.title,
            message: Strings.Cfg.Dialogs.Failed.message,
            onDismiss: onDismiss,
            negativeButtonText: Strings.General.ok,
            onNegativeButtonClick: onDismiss
        )
    }
}

private struct EmptyNameDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.missing_name,
            onDismiss: onDismiss,
            negativeButtonText: Strings.General.ok,
            onNegativeButtonClick: onDismiss
        )
    }
}

private struct DuplicatedNameDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.duplicated_name,
            onDismiss: onDismiss,
            negativeButtonText: Strings.General.ok,
            onNegativeButtonClick: onDismiss
        )
    }
}

private struct RequiredDataMissingDialog: SwiftUI.View {
    var onDismiss: () -> Void
    
    var body: some SwiftUI.View {
        SuplaCore.Dialog.Alert(
            header: Strings.General.error,
            message: Strings.Cfg.Dialogs.incomplete,
            onDismiss: onDismiss,
            negativeButtonText: Strings.General.ok,
            onNegativeButtonClick: onDismiss
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

private struct EmailAuthorizationView: View {
    @Binding var email: String
    @Binding var serverAutoDetect: Bool
    @Binding var serverAddress: String
    
    var advancedAuthorization: Bool
    var onServerAutoDetectChange: (Bool) -> Void
    
    var body: some View {
        TextFieldWithLabel(Strings.CreateProfile.emailLabel, $email)
            
        if (advancedAuthorization) {
            SwiftUI.Text(Strings.CreateProfile.serverLabel)
                .fontCaptionSmall()
                .textColor(.Supla.onBackground)
                .padding([.top], Distance.default)
            HStack {
                TextField("", text: $serverAddress)
                    .textFieldStyle(StandardTextFieldStyle(disabled: serverAutoDetect))
                    .autocapitalization(.none)
                    
                Toggle(isOn: $serverAutoDetect) {
                    Text("Auto").fontBodyMedium()
                }
                .toggleStyle(iOSCheckboxToggleStyle(color: .primary, textFirst: true))
                .onChange(of: serverAutoDetect) { onServerAutoDetectChange($0) }
            }
        }
    }
}

private struct AccessIdAuthorizationView: View {
    @Binding var accessId: String
    @Binding var accessIdPassword: String
    @Binding var serverAddress: String
    
    var body: some View {
        SwiftUI.Text(Strings.CreateProfile.accessIdLabel)
            .fontCaptionSmall()
            .textColor(.Supla.onBackground)
            .padding([.top], Distance.default)
        TextField("", text: $accessId)
            .textFieldStyle(StandardTextFieldStyle())
            .keyboardType(.numberPad)
            
        SwiftUI.Text(Strings.CreateProfile.passwordLabel)
            .fontCaptionSmall()
            .textColor(.Supla.onBackground)
            .padding([.top], Distance.default)
        PasswordTextField(text: $accessIdPassword)
            
        TextFieldWithLabel(Strings.CreateProfile.serverLabel, $serverAddress)
            
        SwiftUI.Text(Strings.CreateProfile.wizardWarningText)
            .fontBodyMedium()
            .textColor(.Supla.error)
            .multilineTextAlignment(.center)
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], Distance.small)
            .overlay(RoundedRectangle(cornerRadius: Dimens.buttonRadius).stroke(Color.Supla.error))
            .padding([.top, .bottom], Distance.small)
    }
}

private struct TextFieldWithLabel: View {
    var label: String
    @Binding var value: String
    
    init(_ label: String, _ value: Binding<String>) {
        self.label = label
        self._value = value
    }
    
    var body: some View {
        Text(label)
            .fontCaptionSmall()
            .textColor(.Supla.onBackground)
            .padding([.top], Distance.default)
        TextField("", text: $value)
            .textFieldStyle(StandardTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}
