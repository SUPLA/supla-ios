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
    
import CoreLocation
import NetworkExtension
import SharedCore
import SystemConfiguration.CaptiveNetwork

extension AddWizardFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, EspConfigurationController, ViewDelegate {
        @Singleton<CheckRegistrationEnabled.UseCase> private var checkRegistrationEnabledUseCase
        @Singleton<LoadActiveProfileUrlUseCase> private var loadActiveProfileUrlUseCase
        @Singleton<ProvideCurrentSsid.UseCase> private var provideCurrentSsidUseCase
        @Singleton<EnableRegistration.UseCase> private var enableRegistrationUseCase
        @Singleton<AwaitConnectivity.UseCase> private var awaitConnectivityUseCase
        @Singleton<CreateEspPassword.UseCase> private var createEspPasswordUseCase
        @Singleton<EspConfigurationSession> private var espConfigurationSession
        @Singleton<ConnectToEsp.UseCase> private var connectToEspUseCase
        @Singleton<ConfigureEsp.UseCase> private var configureEspUseCase
        @Singleton<AuthorizeEsp.UseCase> private var authorizeEspUseCase
        @Singleton<SecureSettings.Interface> private var secureSettings
        @Singleton<SuplaAppStateHolder> private var suplaAppStateHolder
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<DisconnectUseCase> private var disconnectUseCase
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<DateProvider> private var dateProvider

        private lazy var stateHandler: IosEspConfigurationStateHolder = .init(espConfigurationController: self)
        private var workingTask: Task<Void, Never>? = nil
        
        private lazy var locationManager: CLLocationManager = {
            let manager = CLLocationManager()
            manager.delegate = self
            return manager
        }()
        
        var authorizationCallback: (() -> Void)? = nil
        
        init() {
            super.init(state: ViewState())
            
            profileRepository.getActiveProfile()
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] profile in
                        if (profile.authorizationType != .email) {
                            if let self {
                                state.screens = state.screens.just(.message(text: [Strings.AddWizard.notAvailable], action: nil))
                            }
                        }
                    }
                )
                .disposed(by: disposeBag)
        }
        
        // MARK: - View methods
        
        func onCancel(_ screen: Screen) {
            switch (screen) {
            case .configuration:
                if (stateHandler.isInactive) {
                    coordinator.dismiss()
                } else {
                    stateHandler.handle(EspConfigurationEventClose.shared)
                }
            case .manualConfiguration:
                stateHandler.handle(EspConfigurationEventClose.shared)
            default:
                coordinator.dismiss()
            }
        }
        
        func onBack(_ screen: Screen) {
            switch (screen) {
            case .welcome:
                coordinator.dismiss()
            case .configuration:
                if (stateHandler.isInactive) {
                    state.screens = state.screens.pop()
                } else {
                    stateHandler.handle(EspConfigurationEventBack.shared)
                }
            case .manualConfiguration:
                stateHandler.handle(EspConfigurationEventBack.shared)
            default:
                if (state.screens.screens.count > 1) {
                    state.screens = state.screens.pop()
                } else {
                    coordinator.dismiss()
                }
            }
        }
        
        func onNext(_ screen: Screen) {
            switch (screen) {
            case .welcome: welcomeNextStep()
            case .networkSelection: networkSelectionNextStep()
            case .configuration:
                state.processing = true
                stateHandler.handle(EspConfigurationEventStart())
            case .success:
                if let finished = suplaAppStateHolder.currentState()?.isFinished, finished {
                    suplaAppStateHolder.handle(event: .connecting)
                }
                coordinator.dismiss()
            case .message:
                coordinator.dismiss()
            case .manualConfiguration:
                state.processing = true
                stateHandler.handle(EspConfigurationEventNetworkConnected.shared)
            case .manualReconnect:
                suplaAppStateHolder.handle(event: .addWizardFinished)
                stateHandler.handle(EspConfigurationEventReconnected.shared)
            }
        }
        
        func onMessageAction(_ action: MessageAction) {
            switch (action) {
            case .location:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            case .repeatError:
                state.processing = false
                state.screens = state.screens.pop()
            case .repeatSuccess:
                state.processing = false
                state.screens = state.screens.pop()
            }
        }
        
        func onWifiSettings() {
            if let data = Data(base64Encoded: "QXBwLVByZWZzOnJvb3Q9V0lGSQ==", options: []),
               let string = String(data: data, encoding: .utf8),
               let url = URL(string: string),
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            } else if let data = Data(base64Encoded: "cHJlZnM6cm9vdD1XSUZJ", options: []),
                      let string = String(data: data, encoding: .utf8),
                      let url = URL(string: string),
                      UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            } else if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsURL)
            {
                UIApplication.shared.open(settingsURL)
            } else {
                SALog.warning("Could not open settings url")
            }
        }
        
        func onAuthorize() {
            stateHandler.handle(EspConfigurationEventAuthorized.shared)
        }
        
        func onAuthorizationCanceled() {
            state.processing = false
            stateHandler = .init(espConfigurationController: self)
        }

        func onFollowupPopupClose() {
            state.showCloudFollowupPopup = false
        }
        
        func onFollowupPopupOpen() {
            state.showCloudFollowupPopup = false
            loadActiveProfileUrlUseCase.invoke()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] url in
                    self?.coordinator.openUrl(url: url.urlString)
                })
                .disposed(by: disposeBag)
        }
        
        func onManualPopupContinueManual() {
            state.screens = state.screens.pop()
            
            state.showManualModePopup = false
            state.processing = true
            state.autoMode = false
            
            stateHandler.handle(EspConfigurationEventStart())
        }
        
        func onManualPopupContinueAuto() {
            state.showManualModePopup = false
        }
        
        func onManualPopupClose() {
            state.showManualModePopup = false
        }
        
        func onCloseProvidePasswordDialog() {
            state.canceling = true
            state.providePasswordDialogState = nil
            switch (state.screens.current) {
            case .manualConfiguration: stateHandler.handle(EspConfigurationEventBack.shared)
            default: stateHandler.handle(EspConfigurationEventCancel.shared)
            }
        }

        func onPasswordProvided(_ password: String) {
            state.providePasswordDialogState = state.providePasswordDialogState?
                .changing(path: \.processing, to: true)
                .changing(path: \.error, to: nil)

            workingTask = Task {
                dispatchPrecondition(condition: .notOnQueue(.main))

                let result = await authorizeEspUseCase.invoke(password: password)

                await MainActor.run {
                    switch result {
                    case .success:
                        state.providePasswordDialogState = nil
                        stateHandler.handle(EspConfigurationEventPasswordProvided.shared)
                    case .failureWrongPassword:
                        state.providePasswordDialogState = state.providePasswordDialogState?
                            .changing(path: \.error, to: Strings.General.incorrectPassword)
                            .changing(path: \.processing, to: false)
                    case .failureUnknown:
                        state.providePasswordDialogState = state.providePasswordDialogState?
                            .changing(path: \.error, to: Strings.Status.errorUnknown)
                            .changing(path: \.processing, to: false)
                    case .temporarilyLocked:
                        state.providePasswordDialogState = nil
                        stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: .TemporarilyLocked.shared))
                    }
                }
            }
        }

        func onCloseSetPasswordDialog() {
            state.canceling = true
            state.setPasswordDialogState = nil
            switch (state.screens.current) {
            case .manualConfiguration: stateHandler.handle(EspConfigurationEventBack.shared)
            default: stateHandler.handle(EspConfigurationEventCancel.shared)
            }
        }

        func onSetPassword(_ password: String, _ repeatPassword: String) {
            if (password.isAcceptablePassword() && password == repeatPassword) {
                state.setPasswordDialogState = state.setPasswordDialogState?
                    .changing(path: \.processing, to: true)
                    .changing(path: \.error, to: false)
                
                workingTask = Task {
                    dispatchPrecondition(condition: .notOnQueue(.main))
                    
                    let result = await createEspPasswordUseCase.invoke(password: password)
                    
                    await MainActor.run {
                        switch result {
                        case .success:
                            state.setPasswordDialogState = nil
                            stateHandler.handle(EspConfigurationEventPasswordProvided.shared)
                        case .failure:
                            state.setPasswordDialogState = state.setPasswordDialogState?
                                .changing(path: \.error, to: true)
                        case .temporarilyLocked:
                            state.providePasswordDialogState = nil
                            stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: .TemporarilyLocked.shared))
                        }
                    }
                }
            } else {
                state.setPasswordDialogState = state.setPasswordDialogState?
                    .changing(path: \.error, to: true)
            }
        }
        
        func onKeepUnchanged() {
            networkSelectionNextStep()
            state.showSpacesPopup = false
        }
        
        func onRemoveWhiteCharacters() {
            state.showSpacesPopup = false
            state.networkSsid = state.networkSsid.trimmingCharacters(in: .whitespacesAndNewlines)
            networkSelectionNextStep()
        }

        // MARK: - EspConfigurationController methods
        
        func activateRegistration() {
            workingTask = Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                
                let result = try? await enableRegistrationUseCase.invoke()
                
                await MainActor.run {
                    if (result == .success) {
                        stateHandler.handle(EspConfigurationEventRegistrationActivated.shared)
                    } else {
                        stateHandler.handle(EspConfigurationEventRegistrationNotActivated.shared)
                    }
                }
            }
        }
        
        func authorize() {
            authorizationCallback?()
        }
        
        func back() {
            state.screens = state.screens.pop()
            state.processing = false
            state.canceling = false
        }
        
        func cancel() {
            state.canceling = true
            Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                workingTask?.cancel()
                await workingTask?.value
                await MainActor.run {
                    stateHandler.handle(EspConfigurationEventCanceled.shared)
                }
            }
        }
        
        func checkRegistration() {
            workingTask = Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                
                let firstResult = await checkRegistrationEnabledCall()
                if (firstResult == .timeout) {
                    let secondResult = try? await checkRegistrationEnabledUseCase.invoke()
                    
                    await MainActor.run {
                        switch (secondResult) {
                        case .enabled: stateHandler.handle(EspConfigurationEventRegistrationEnabled.shared)
                        case .disabled: stateHandler.handle(EspConfigurationEventRegistrationDisabled.shared)
                        default: stateHandler.handle(EspConfigurationEventRegistrationUnknown.shared)
                        }
                    }
                } else {
                    await MainActor.run {
                        switch (firstResult) {
                        case .enabled: stateHandler.handle(EspConfigurationEventRegistrationEnabled.shared)
                        case .disabled: stateHandler.handle(EspConfigurationEventRegistrationDisabled.shared)
                        default: stateHandler.handle(EspConfigurationEventRegistrationUnknown.shared)
                        }
                    }
                }
            }
        }
        
        private func checkRegistrationEnabledCall() async -> SharedCore.CheckRegistrationEnabledUseCase.Result? {
            let currentTimestamp = dateProvider.currentTimestamp()
            if let registrationTime = state.registrationActivationTime,
               currentTimestamp < registrationTime + 3600
            {
                return .enabled
            } else {
                state.registrationActivationTime = currentTimestamp
                return try? await checkRegistrationEnabledUseCase.invoke()
            }
        }

        func close() {
            coordinator.dismiss()
        }
        
        func configureEsp() {
            workingTask = Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                let result = await configureEspUseCase.invoke(data: ConfigureEsp.InputData(ssid: state.networkSsid, password: state.networkPassword))
                
                await MainActor.run {
                    switch (result) {
                    case .connectionError: stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: EspConfigurationError.Communication.shared))
                    case .failed: stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: EspConfigurationError.Configuration.shared))
                    case .incompatible: stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: EspConfigurationError.Compatibility.shared))
                    case .timeout: stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: EspConfigurationError.ConfigureTimeout.shared))
                    case .credentialsNeeded: stateHandler.handle(EspConfigurationEventCredentialsNeeded.shared)
                    case .setupNeeded: stateHandler.handle(EspConfigurationEventSetupNeeded.shared)
                    case .temporarilyLocked: stateHandler.handle(EspConfigurationEventEspConfigurationFailure(error: EspConfigurationError.TemporarilyLocked.shared))
                    case .success(let result):
                        state.deviceParameters = result.parameters
                        if (result.needsCloudConfig) {
                            state.showCloudFollowupPopup = true
                        }
                        stateHandler.handle(EspConfigurationEventEspConfigured.shared)
                    }
                }
            }
        }
        
        func connectToNetwork(ssid: String) {
            if (state.autoMode) {
                workingTask = Task {
                    dispatchPrecondition(condition: .notOnQueue(.main))
                    let result = await connectToEspUseCase.invoke()
                    
                    await MainActor.run {
                        switch (result) {
                        case .success: stateHandler.handle(EspConfigurationEventNetworkConnected.shared)
                        case .failure: stateHandler.handle(EspConfigurationEventNetworkConnectionFailure.shared)
                        case .fatalError: stateHandler.handle(EspConfigurationEventNetworkConnectionInternalError.shared)
                        }
                    }
                }
            } else {
                workingTask = Task {
                    dispatchPrecondition(condition: .notOnQueue(.main))
                    disconnectUseCase.invokeSynchronous(reason: .addWizardStarted)
                    
                    await MainActor.run {
                        state.screens = state.screens.push(.manualConfiguration)
                        state.processing = false
                    }
                }
            }
        }
        
        func findEspNetwork() {
            // In iOS we're not able to find ESP network. This step is skipped
            stateHandler.handle(EspConfigurationEventNetworkFound(ssid: ""))
        }
        
        func configurePassword() {
            state.setPasswordDialogState = SetPasswordDialogState()
        }

        func providePassword() {
            state.providePasswordDialogState = ProvidePasswordDialogState()
        }

        func reinitialize() {
            state.processing = false
            state.canceling = false
        }

        func setupEspConfiguration() {
            SALog.debug("setEspConfiguration")
            espConfigurationSession.reset()
        }

        func updateProgress(progress: Float, descriptionLabel: (any LocalizedString)?) {
            state.progress = progress
            state.progressLabel = descriptionLabel?.string
        }

        func reconnect() {
            var configurationRemoved = false
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { ssids in
                if (!ssids.isEmpty) {
                    SALog.debug("Removing hotspot configuration for \(ssids[0])")
                    NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssids[0])
                    configurationRemoved = true
                }
            }
            
            if (state.autoMode == false && configurationRemoved == false) {
                // let the user manually change the network
                state.canceling = false
                state.screens = state.screens.push(.manualReconnect)
                return
            }
            
            workingTask = Task {
                dispatchPrecondition(condition: .notOnQueue(.main))
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                let result = await awaitConnectivityUseCase.invoke()
                await MainActor.run {
                    suplaAppStateHolder.handle(event: .addWizardFinished)
                    switch (result) {
                    case .success: stateHandler.handle(EspConfigurationEventReconnected.shared)
                    case .timeout: stateHandler.handle(EspConfigurationEventReconnectTimeout.shared)
                    }
                }
            }
        }
        
        func showError(error: EspConfigurationError) {
            state.processing = false
            state.canceling = false
            let errorText = switch (error) {
            case _ as EspConfigurationError.InternalError: [Strings.AddWizard.internalErrorMessage]
            default: error.messages.map { $0.string }
            }
            state.screens = state.screens.push(.message(text: errorText, action: .repeatError))
            
            if (state.autoMode == true) {
                state.showManualModePopup = true
            }
        }
        
        func showFinished() {
            state.processing = false
            state.screens = state.screens.push(.success)
        }
        
        func showNetworkSelector(ssids: [String], cached: Bool) {
            // Not used in iOS
        }
        
        // MARK: - Private methods
        
        private func welcomeNextStep() {
            state.processing = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                let locationEnabled = CLLocationManager.locationServicesEnabled()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    state.processing = false
                    
                    let appStatus = locationManager.authorizationStatus
                    SALog.info("Location status: \(appStatus)")
                    
                    if (!locationEnabled) {
                        state.screens = state.screens.just(.message(text: [Strings.AddWizard.locationServiceOff], action: .location))
                    } else if (appStatus == .authorizedWhenInUse || appStatus == .authorizedAlways) {
                        navigateToNetworkSelection()
                    } else if (appStatus == .denied) {
                        state.screens = state.screens.just(.message(text: [Strings.AddWizard.missingLocation], action: .location))
                    } else {
                        locationManager.requestWhenInUseAuthorization()
                    }
                }
            }
        }
        
        private func navigateToNetworkSelection() {
            state.screens = state.screens.push(.networkSelection)
            
            var ssid = secureSettings.wizardWifiName
            if (ssid == nil || ssid?.isEmpty == true) {
                ssid = provideCurrentSsidUseCase.invoke()
            }
            state.networkSsid = ssid ?? ""
            
            if let password = secureSettings.wizardWifiPassword {
                state.networkPassword = password
                state.rememberPassword = true
            } else {
                state.rememberPassword = false
            }
        }
        
        private func networkSelectionNextStep() {
            state.networkConfigurationError = state.networkSsid.isEmpty || state.networkPassword.isEmpty
            
            if (state.networkSsid.isEmpty || state.networkPassword.isEmpty) {
                // just return, error message is set above
            } else if (shouldInformAboutWhiteCharsInNetworkName()) {
                state.showSpacesPopup = true
            } else {
                secureSettings.wizardWifiName = state.networkSsid
                if (state.rememberPassword) {
                    secureSettings.wizardWifiPassword = state.networkPassword
                } else {
                    secureSettings.wizardWifiPassword = nil
                }
                
                state.screens = state.screens.push(.configuration)
            }
        }
        
        private func shouldInformAboutWhiteCharsInNetworkName() -> Bool {
            let stateNetworkSsid = state.networkSsid
            if (stateNetworkSsid.isEmpty) {
                return false
            }
            if (stateNetworkSsid == secureSettings.wizardWifiName) {
                // Network name is the same as last time, show the user already know about white characters
                return false
            }
            if (state.showSpacesPopup) {
                // The popup about white characters is presented to the user. User decided to keep name as it is.
                return false
            }
            
            return stateNetworkSsid != stateNetworkSsid.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

extension AddWizardFeature.ViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        SALog.info("[Callback] Location status: \(status)")
        
        if (state.screens.current == .welcome) {
            if (status == .authorizedAlways || status == .authorizedWhenInUse) {
                navigateToNetworkSelection()
            } else if (status == .denied) {
                state.screens = state.screens.just(.message(text: [Strings.AddWizard.missingLocation], action: .location))
            }
        }
    }
}

private extension String {
    func isAcceptablePassword() -> Bool {
        let hasLowercase = range(of: ".*[a-z].*", options: .regularExpression) != nil
        let hasUppercase = range(of: ".*[A-Z].*", options: .regularExpression) != nil
        let hasDigit = range(of: ".*[0-9].*", options: .regularExpression) != nil

        return hasLowercase && hasUppercase && hasDigit
    }
}
