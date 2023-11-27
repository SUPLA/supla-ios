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

import XCTest
import RxTest
import RxSwift
import RxCocoa
import CoreData

@testable import SUPLA

class AccountCreationVMTests: ViewModelTest<AccountCreationViewState, AccountCreationViewEvent> {
    
    private lazy var ctx: NSManagedObjectContext! = { setUpInMemoryManagedObjectContext() }()
    private lazy var profile: AuthProfileItem? = nil
    private lazy var profileManager: ProfileManagerMock! = { ProfileManagerMock(ctx) }()
    private lazy var viewModel: AccountCreationVM! = {
        AccountCreationVM(profileManager: profileManager, profileId: profile?.objectID)
    }()
    
    private lazy var globalSettings: GlobalSettingsMock! = { GlobalSettingsMock() }()
    private lazy var runtimeConfig: RuntimeConfigMock! = { RuntimeConfigMock() }()
    private lazy var suplaClientProvider: SuplaClientProviderMock! = { SuplaClientProviderMock() }()
    private lazy var suplaApp: SuplaAppWrapperMock! = { SuplaAppWrapperMock() }()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, component: globalSettings!)
        DiContainer.shared.register(type: RuntimeConfig.self, component: runtimeConfig!)
        DiContainer.shared.register(type: SuplaClientProvider.self, component: suplaClientProvider!)
        DiContainer.shared.register(type: SuplaAppWrapper.self, component: suplaApp!)
    }
    
    override func tearDown() {
        viewModel = nil
        profile = nil
        profileManager = nil
        
        globalSettings = nil
        runtimeConfig = nil
        suplaClientProvider = nil
        suplaApp = nil
        
        super.tearDown()
    }
    
    func test_shouldCleanServerAddres_whenEmailAddressChanged() {
        setupProfile()
        
        // given
        let email = "second@test.org"
        let serverAddress = "test.com"
        profile?.authInfo = profile?.authInfo?.copy(serverForEmail: serverAddress)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create(serverAddressForEmail: serverAddress)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state
                .changing(path: \.emailAddress, to: email)
                .changing(path: \.serverAddressForEmail, to: ""))
        ])
    }
    
    func test_shouldDoNothing_whenEmailAddressSame() {
        setupProfile()
        
        // given
        let email = "second@test.org"
        let serverAddress = "test.com"
        
        profile?.authInfo = profile?.authInfo?.copy(emailAddress: email, serverForEmail: serverAddress)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create(emailAddress: email, serverAddressForEmail: serverAddress)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state)
        ])
    }
    
    func test_shouldCleanServerAddress_whenSettingAutodetectOn() {
        setupProfile()
        
        // given
        let serverAddress = "test.com"
        profile?.authInfo = profile?.authInfo?.copy(serverAutoDetect: false, serverForEmail: serverAddress)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create(serverAutoDetect: false, serverAddressForEmail: serverAddress)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state
                .changing(path: \.serverAutoDetect, to: true)
                .changing(path: \.serverAddressForEmail, to: ""))
        ])
    }
    
    func test_shouldSetServerAddressToDomain_whenSettingAutodetectOff() {
        setupProfile()
        
        // given
        let serverAddress = "test.com"
        let email = "some@\(serverAddress)"
        
        profile?.authInfo = profile?.authInfo?.copy(emailAddress: email)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create(emailAddress: email)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state
                .changing(path: \.serverAutoDetect, to: false)
                .changing(path: \.serverAddressForEmail, to: serverAddress))
        ])
    }
    
    func test_shouldDoNothing_whenSettingAutodetectToSameValue() {
        setupProfile()
        
        // given
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [
            .next(0, state)
        ])
    }
    
    func test_shouldChangeStateToAdvanced() {
        setupProfile()
        
        // given
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: true))
        ])
    }
    
    func test_shouldShowBasicModeUnavailable_whenAuthTypeEmail() {
        setupProfile()
        
        // given
        profile?.advancedSetup = true
        profile?.authInfo = profile?.authInfo?.copy(emailAuth: false)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 3)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(advancedMode: true, authType: .accessId)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: false)),
            .next(1, state)
        ])
        XCTAssertEqual(eventObserver.events, [.next(1, .showBasicModeUnavailableDialog)])
    }
    
    func test_shouldShowBasicModeUnavailable_whenServerAutodetectOff() {
        setupProfile()
        
        // given
        profile?.advancedSetup = true
        profile?.authInfo = profile?.authInfo?.copy(serverAutoDetect: false)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 3)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(advancedMode: true, serverAutoDetect: false)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: false)),
            .next(1, state)
        ])
        XCTAssertEqual(eventObserver.events, [.next(1, .showBasicModeUnavailableDialog)])
    }
    
    func test_shouldShowRemovalDialog_whenRemoveButtonTapped() {
        setupProfile()
        
        // given
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.removeTapped()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showRemovalDialog) ])
    }
    
    func test_shouldNavigateToAddAccount_whenCreateAccountButtonTapped() {
        setupProfile()
        
        // given
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.addAccountTapped()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .navigateToCreateAccount) ])
    }
    
    func test_shouldRemoveAccount_whenNotActive() {
        doTest_shouldRemoveLogoutAccount_whenNotActive(event: .navigateToRemoveAccount(needsRestart: false, serverAddress: nil)) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutAccount_whenNotActive() {
        doTest_shouldRemoveLogoutAccount_whenNotActive(event: .finish(needsRestart: false, needsReauth: false)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldRemoveLogoutAccount_whenNotActive(event: AccountCreationViewEvent, _ action: () -> Void) {
        setupProfile()
        
        // given
        profile?.isActive = false
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile?.objectID)
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
        XCTAssertEqual(suplaApp.terminateCalls, 0)
    }
    
    func test_shouldRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: .navigateToRemoveAccount(needsRestart: true, serverAddress: "some.url.com")) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: .finish(needsRestart: true, needsReauth: true)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: AccountCreationViewEvent, _ action: () -> Void) {
        setupProfile()
        
        // given
        let server = "some.url.com"
        profile?.authInfo = profile?.authInfo?.copy(serverAutoDetect: false, serverForEmail: server)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        let state = AccountCreationViewState.create(authType: .email, serverAutoDetect: false, serverAddressForEmail: server)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile?.objectID)
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], false)
        
        XCTAssertEqual(runtimeConfig.activeProfileIdValues.count, 1)
        XCTAssertEqual(runtimeConfig.activeProfileIdValues, [nil])
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
        XCTAssertEqual(suplaApp.terminateCalls, 1)
    }
    
    func test_shouldRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: .navigateToRemoveAccount(needsRestart: false, serverAddress: "other.url.com")) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: .finish(needsRestart: false, needsReauth: true)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: AccountCreationViewEvent, _ action: () -> Void) {
        setupProfile()
        
        // given
        let otherProfile = createProfile()
        profileManager.allProfilesResult = [profile!, otherProfile]
        
        let server = "other.url.com"
        profile?.authInfo = profile?.authInfo?.copy(emailAuth: false, serverForAccessID: server)
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        let state = AccountCreationViewState.create(authType: .accessId, serverAddressForAccessId: server)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile?.objectID)
        XCTAssertEqual(profileManager.activatedProfiles.count, 1)
        XCTAssertEqual(profileManager.activatedProfiles[0], ProfileManagerMock.ActivatedProfile(id: otherProfile.objectID, force: true))
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
        XCTAssertEqual(suplaApp.terminateCalls, 1)
    }
    
    func test_shouldShowRemovalFailure_whenCouldNotActivateOtherProfile() {
        setupProfile()
        
        // given
        let otherProfile = createProfile()
        profileManager.allProfilesResult = [profile!, otherProfile]
        profileManager.activateResults = [false]
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.logoutAccount()
        
        // then
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, .showRemovalFailure) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 1)
        XCTAssertEqual(profileManager.activatedProfiles[0], ProfileManagerMock.ActivatedProfile(id: otherProfile.objectID, force: true))
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldShowEmptyNameDialog_whenProfileNameVisible() {
        setupProfile()
        
        // given
        globalSettings.anyAccountRegisteredReturns = true
        let nameObservable = PublishSubject<String>()
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.bind(field: \.profileName, toObservable: nameObservable)
        nameObservable.on(.next(""))
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.profileName, to: ""))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .showEmptyNameDialog) ])
        
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldShowDuplicatedNameDialog_whenProfileWithSameNameExists() {
        setupProfile()
        
        // given
        globalSettings.anyAccountRegisteredReturns = true
        let name = "Some name"
        let nameObservable = PublishSubject<String>()
        let otherProfile = createProfile()
        otherProfile.name = name
        profileManager.allProfilesResult = [profile!, otherProfile]
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.bind(field: \.profileName, toObservable: nameObservable)
        nameObservable.on(.next(name))
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.profileName, to: name))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .showDuplicatedNameDialog) ])
        
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldShowMissingRequiredDataDialog_whenMailIsNotProvided() {
        setupProfile()
        
        // given
        globalSettings.anyAccountRegisteredReturns = true
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showRequiredDataMisingDialog) ])
        
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldSaveProfile() {
        setupProfile()
        
        // given
        let email = "some@email.org"
        globalSettings.anyAccountRegisteredReturns = true
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.emailAddress, to: email))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .formSaved(needsReauth: true)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profile?.objectID)
        XCTAssertEqual(profile?.authInfo?.preferredProtocolVersion, Int(SUPLA_PROTO_VERSION))
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
    }
    
    func test_shouldSaveProfileWithoutReauth_whenNoAuthDataChanged() {
        setupProfile()
        
        // given
        let email = "some@email.org"
        profile?.authInfo = profile?.authInfo?.copy(emailAddress: email)
        globalSettings.anyAccountRegisteredReturns = true
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, emailAddress: email, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .formSaved(needsReauth: false)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profile?.objectID)
        XCTAssertEqual(profile?.authInfo?.preferredProtocolVersion, 0)
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
    }
    
    func test_shouldSaveProfileWithoutReauth_whenInactiveProfileSaved() {
        setupProfile()
        
        // given
        let email = "some@email.org"
        profile?.isActive = false
        globalSettings.anyAccountRegisteredReturns = true
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.creationTitle, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.emailAddress, to: email))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .formSaved(needsReauth: false)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profile?.objectID)
        XCTAssertEqual(profile?.authInfo?.preferredProtocolVersion, Int(SUPLA_PROTO_VERSION))
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 0)
    }
    
    func test_shouldCreateNewProfile_whenNoProfileIdProvided() {
        // given
        let email = "same@email.org"
        globalSettings.anyAccountRegisteredReturns = false
        observe(viewModel)
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(profileName: "", accessId: "")
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.emailAddress, to: email))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .formSaved(needsReauth: true)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(profileManager.createdProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profileManager.createdProfiles[0].objectID)
        
        XCTAssertEqual(profileManager.createdProfiles[0].authInfo?.preferredProtocolVersion, Int(SUPLA_PROTO_VERSION))
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.reconnectCalls, 1)
    }
    
    private func createProfile() -> AuthProfileItem {
        let profile = AuthProfileItem(context: ctx)
        profile.authInfo = AuthInfo.empty()
        return profile
    }
    
    private func setupProfile() {
        profile = AuthProfileItem(context: ctx)
        profile?.isActive = true
        profile?.authInfo = AuthInfo.empty()
        
        profileManager.item = profile
    }
}

extension AccountCreationViewState {
    static func create(
        title: String = "supla",
        profileName: String = Strings.Profiles.defaultProfileName,
        emailAddress: String = "",
        advancedMode: Bool = false,
        authType: AuthType = .email,
        serverAutoDetect: Bool = true,
        serverAddressForEmail: String = "",
        accessId: String = "0",
        accessIdPassword: String = "",
        serverAddressForAccessId: String = "",
        profileNameVisible: Bool = false,
        deleteButtonVisible: Bool = false,
        backButtonVisible: Bool = false
    ) -> AccountCreationViewState {
        AccountCreationViewState(
            title: title,
            profileName: profileName,
            emailAddress: emailAddress,
            advancedMode: advancedMode,
            authType: authType,
            serverAutoDetect: serverAutoDetect,
            serverAddressForEmail: serverAddressForEmail,
            accessId: accessId,
            accessIdPassword: accessIdPassword,
            serverAddressForAccessId: serverAddressForAccessId,
            profileNameVisible: profileNameVisible,
            deleteButtonVisible: deleteButtonVisible,
            backButtonVisible: backButtonVisible
        )
    }
}
