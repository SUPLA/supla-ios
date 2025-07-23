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
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, EspConfigurationController {
        @Singleton<SuplaAppCoordinator> private var coordinator
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<SecureSettings.Interface> private var secureSettings
        @Singleton<ProvideCurrentSsid.UseCase> private var provideCurrentSsidUseCase
        @Singleton<CheckRegistrationEnabled.UseCase> private var checkRegistrationEnabledUseCase
        @Singleton<EnableRegistration.UseCase> private var enableRegistrationUseCase
        @Singleton<ConnectToEsp.UseCase> private var connectToEspUseCase
        @Singleton<ConfigureEsp.UseCase> private var configureEspUseCase
        @Singleton<SuplaAppStateHolder> private var suplaAppStateHolder
        @Singleton<AwaitConnectivity.UseCase> private var awaitConnectivityUseCase
        @Singleton<DisconnectUseCase> private var disconnectUseCase
        @Singleton<LoadActiveProfileUrlUseCase> private var loadActiveProfileUrlUseCase
        
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
                                state.screens = state.screens.just(.message(text: Strings.AddWizard.notAvailable, action: nil))
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
                    state.screens = state.screens.pop()
                } else {
                    stateHandler.handle(EspConfigurationEventCancel.shared)
                }
            case .manualConfiguration:
                stateHandler.handle(EspConfigurationEventCancel.shared)
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
            }
        }
        
        func onMessageAction(_ action: MessageAction) {
            switch (action) {
            case .location:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            case .repeat:
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
        
        func onFollowupClose() {
            state.followupPopupState = nil
        }
        
        func onFollowupOpen() {
            state.followupPopupState = nil
            loadActiveProfileUrlUseCase.invoke()
                .asDriverWithoutError()
                .drive(onNext: { [weak self] url in
                    self?.coordinator.openUrl(url: url.urlString)
                })
                .disposed(by: disposeBag)
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
                
                let firstResult = try? await checkRegistrationEnabledUseCase.invoke()
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
                    case .success(let result):
                        state.deviceParameters = result.parameters
                        if (result.needsCloudConfig) {
                            state.followupPopupState = .init(
                                header: Strings.AddWizard.cloudFollowupTitle,
                                message: Strings.AddWizard.cloudFollowupMessage,
                                positiveButtonText: Strings.AddWizard.cloudFollowupGoToCloud,
                                negativeButtonText: Strings.AddWizard.cloudFollowupClose
                            )
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
        
        func reconnect() {
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { ssids in
                if (!ssids.isEmpty) {
                    SALog.debug("Removing hotspot configuration for \(ssids[0])")
                    NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssids[0])
                }
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
            state.screens = state.screens.push(.message(text: error.message.string, action: .repeat))
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
            let status = locationManager.authorizationStatus
            SALog.info("Location status: \(status)")
            
            if (status == .authorizedWhenInUse || status == .authorizedAlways) {
                navigateToNetworkSelection()
            } else if (status == .denied) {
                state.screens = state.screens.just(.message(text: Strings.AddWizard.missingLocation, action: .location))
            } else {
                locationManager.requestWhenInUseAuthorization()
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
            
            if (!state.networkSsid.isEmpty && !state.networkPassword.isEmpty) {
                secureSettings.wizardWifiName = state.networkSsid
                if (state.rememberPassword) {
                    secureSettings.wizardWifiPassword = state.networkPassword
                } else {
                    secureSettings.wizardWifiPassword = nil
                }
                
                state.screens = state.screens.push(.configuration)
            }
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
                state.screens = state.screens.just(.message(text: Strings.AddWizard.missingLocation, action: .location))
            }
        }
    }
}
