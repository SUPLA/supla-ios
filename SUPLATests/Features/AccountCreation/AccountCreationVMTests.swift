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

class AccountCreationVMTests: XCTestCase {
    
    private lazy var scheduler: TestScheduler! = { TestScheduler(initialClock: 0) }()
    private lazy var stateObserver: TestableObserver<AccountCreationViewState>! = {
        scheduler.createObserver(AccountCreationViewState.self)
    }()
    private lazy var eventObserver: TestableObserver<AccountCreationViewEvent>! = {
        scheduler.createObserver(AccountCreationViewEvent.self)
    }()
    private lazy var disposeBag: DisposeBag! = { DisposeBag() }()
    
    private lazy var ctx: NSManagedObjectContext! = { setUpInMemoryManagedObjectContext() }()
    private lazy var profile: AuthProfileItem! = {
        let profile = AuthProfileItem(context: ctx)
        profile.isActive = true
        profile.authInfo = AuthInfo.empty()
        return profile
    }()
    private lazy var profileManager: ProfileManagerMock! = { ProfileManagerMock(item: profile) }()
    private lazy var viewModel: AccountCreationVM! = {
        AccountCreationVM(profileManager: profileManager, profileId: profile.objectID)
    }()
    
    private lazy var globalSettings: GlobalSettingsMock! = { GlobalSettingsMock() }()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, component: globalSettings!)
    }
    
    override func tearDown() {
        viewModel = nil
        profile = nil
        profileManager = nil
        
        scheduler = nil
        stateObserver = nil
        eventObserver = nil
        disposeBag = nil
        
        globalSettings = nil
    }
    
    func test_shouldCleanServerAddres_whenEmailAddressChanged() {
        // given
        let email = "second@test.org"
        let serverAddress = "test.com"
        profile.authInfo?.serverForEmail = serverAddress
        observe()
        
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
        // given
        let email = "second@test.org"
        let serverAddress = "test.com"
        
        profile.authInfo?.emailAddress = email
        profile.authInfo?.serverForEmail = serverAddress
        observe()
        
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
        // given
        let serverAddress = "test.com"
        profile.authInfo?.serverAutoDetect = false
        profile.authInfo?.serverForEmail = serverAddress
        observe()
        
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
        // given
        let serverAddress = "test.com"
        let email = "some@\(serverAddress)"
        
        profile.authInfo?.emailAddress = email
        observe()
        
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
        // given
        observe()
        
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
        // given
        observe()
        
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
        // given
        profile.advancedSetup = true
        profile.authInfo?.emailAuth = false
        observe()
        
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
        // given
        profile.advancedSetup = true
        profile.authInfo?.serverAutoDetect = false
        observe()
        
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
        // given
        observe()
        
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
        // given
        observe()
        
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
        doTest_shouldRemoveLogoutAccount_whenNotActive(event: .navigateToRemoveAccount(needsRestart: false)) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutAccount_whenNotActive() {
        doTest_shouldRemoveLogoutAccount_whenNotActive(event: .finish(needsRestart: false)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldRemoveLogoutAccount_whenNotActive(event: AccountCreationViewEvent, _ action: () -> Void) {
        // given
        profile.isActive = false
        observe()
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile.objectID)
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: .navigateToRemoveAccount(needsRestart: true)) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: .finish(needsRestart: true)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldLogoutRemoveActiveAccountAndRestartApp_whenNoOtherActiveAccountAvailable(event: AccountCreationViewEvent, _ action: () -> Void) {
        // given
        observe()
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile.objectID)
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], false)
    }
    
    func test_shouldRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: .navigateToRemoveAccount(needsRestart: false)) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldLogoutActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable() {
        doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: .finish(needsRestart: false)) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldLogoutRemoveActiveAccountAndActivateOther_whenOtherInactiveAccountAvailable(event: AccountCreationViewEvent, _ action: () -> Void) {
        // given
        let otherProfile = createProfile()
        profileManager.allProfilesResult = [profile, otherProfile]
        observe()
        
        // when
        scheduler.advanceTo(1)
        action()
        
        // then
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, event) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 1)
        XCTAssertTrue(profileManager.deletedProfiles[0] == profile.objectID)
        XCTAssertEqual(profileManager.activatedProfiles.count, 1)
        XCTAssertEqual(profileManager.activatedProfiles[0], ProfileManagerMock.ActivatedProfile(id: otherProfile.objectID, force: true))
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldShowRemovalFailure_whenCouldNotActivateOtherProfile() {
        // given
        let otherProfile = createProfile()
        profileManager.allProfilesResult = [profile, otherProfile]
        profileManager.activateResults = [false]
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.logoutAccount()
        
        // then
        let state = AccountCreationViewState.create()
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showRemovalFailure) ])
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 1)
        XCTAssertEqual(profileManager.activatedProfiles[0], ProfileManagerMock.ActivatedProfile(id: otherProfile.objectID, force: true))
        
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldShowEmptyNameDialog_whenProfileNameVisible() {
        // given
        globalSettings.anyAccountRegisteredReturns = true
        let nameObservable = PublishSubject<String>()
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.bind(field: \.profileName, toObservable: nameObservable)
        nameObservable.on(.next(""))
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.title, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
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
        // given
        globalSettings.anyAccountRegisteredReturns = true
        let name = "Some name"
        let nameObservable = PublishSubject<String>()
        let otherProfile = createProfile()
        otherProfile.name = name
        profileManager.allProfilesResult = [profile, otherProfile]
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.bind(field: \.profileName, toObservable: nameObservable)
        nameObservable.on(.next(name))
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.title, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
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
        // given
        globalSettings.anyAccountRegisteredReturns = true
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.title, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showRequiredDataMisingDialog) ])
        
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 0)
    }
    
    func test_shouldSaveProfile() {
        // given
        let email = "some@email.org"
        globalSettings.anyAccountRegisteredReturns = true
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.title, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.emailAddress, to: email))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .formSaved(needsReauth: true)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profile.objectID)
        XCTAssertEqual(profile.authInfo?.preferredProtocolVersion, Int(SUPLA_PROTO_VERSION))
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
    }
    
    func test_shouldSaveProfileWithoutReauth_whenNoAuthDataChanged() {
        // given
        let email = "some@email.org"
        profile.authInfo?.emailAddress = email
        globalSettings.anyAccountRegisteredReturns = true
        observe()
        
        // when
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        let state = AccountCreationViewState.create(title: Strings.AccountCreation.title, emailAddress: email, profileNameVisible: true, deleteButtonVisible: true, backButtonVisible: true)
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .formSaved(needsReauth: false)) ])
        
        XCTAssertEqual(profileManager.updatedProfiles.count, 1)
        XCTAssertEqual(profileManager.updatedProfiles[0], profile.objectID)
        XCTAssertEqual(profile.authInfo?.preferredProtocolVersion, 0)
        
        XCTAssertEqual(profileManager.deletedProfiles.count, 0)
        XCTAssertEqual(profileManager.activatedProfiles.count, 0)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues.count, 1)
        XCTAssertEqual(globalSettings.anyAccountRegisteredValues[0], true)
    }
    
    private func observe() {
        viewModel.eventsObervable().subscribe(eventObserver).disposed(by: disposeBag)
        viewModel.stateObservable().subscribe(stateObserver).disposed(by: disposeBag)
    }
    
    private func createProfile() -> AuthProfileItem {
        let profile = AuthProfileItem(context: ctx)
        profile.authInfo = AuthInfo.empty()
        return profile
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
