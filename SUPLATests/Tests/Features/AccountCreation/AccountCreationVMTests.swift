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
    private lazy var viewModel: AccountCreationVM! = { AccountCreationVM() }()
    
    private lazy var globalSettings: GlobalSettingsMock! = { GlobalSettingsMock() }()
    private lazy var deleteProfileUseCase: DeleteProfileUseCaseMock! = { DeleteProfileUseCaseMock() }()
    private lazy var saveOrCreateProfileUseCase: SaveOrCreateProfileUseCaseMock! = {
        SaveOrCreateProfileUseCaseMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, component: globalSettings!)
        DiContainer.shared.register(type: DeleteProfileUseCase.self, component: deleteProfileUseCase!)
        DiContainer.shared.register(type: SaveOrCreateProfileUseCase.self, component: saveOrCreateProfileUseCase!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        globalSettings = nil
        deleteProfileUseCase = nil
        saveOrCreateProfileUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldCleanServerAddres_whenEmailAddressChanged() {
        // given
        let email = "second@test.org"
        
        let state = AccountCreationViewState(
            emailAddress: "other",
            serverAddressForEmail: "www"
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.emailAddress, to: email).changing(path: \.serverAddressForEmail, to: ""))
        ])
    }
    
    func test_shouldDoNothing_whenEmailAddressSame() {
        // given
        let email = "second@test.org"
        let serverAddress = "test.com"
        
        let state = AccountCreationViewState(
            emailAddress:email,
            serverAddressForEmail: serverAddress
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.setEmailAddress(email)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state)
        ])
    }
    
    func test_shouldCleanServerAddress_whenSettingAutodetectOn() {
        // given
        let serverAddress = "test.com"
        let state = AccountCreationViewState(
            serverAutoDetect: false,
            serverAddressForEmail: serverAddress
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
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
        
        let state = AccountCreationViewState(
            emailAddress: email,
            serverAutoDetect: true,
            serverAddressForEmail: ""
        )
        viewModel.updateView(state: state)
        
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state
                .changing(path: \.serverAutoDetect, to: false)
                .changing(path: \.serverAddressForEmail, to: serverAddress))
        ])
    }
    
    func test_shouldDoNothing_whenSettingAutodetectToSameValue() {
        // given
        let state = AccountCreationViewState(
            emailAddress: "",
            serverAutoDetect: true,
            serverAddressForEmail: ""
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.setServerAutodetect(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state)
        ])
    }
    
    func test_shouldChangeStateToAdvanced() {
        // given
        let state = AccountCreationViewState(advancedMode: false)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(true)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: true))
        ])
    }
    
    func test_shouldShowBasicModeUnavailable_whenAuthTypeEmail() {
        // given
        let state = AccountCreationViewState(
            advancedMode: true,
            authType: .accessId
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 3)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: false)),
            .next(1, state)
        ])
        XCTAssertEqual(eventObserver.events, [.next(1, .showBasicModeUnavailableDialog)])
    }
    
    func test_shouldShowBasicModeUnavailable_whenServerAutodetectOff() {
        // given
        let state = AccountCreationViewState(
            advancedMode: true,
            serverAutoDetect: false
        )
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.toggleAdvancedState(false)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 3)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.advancedMode, to: false)),
            .next(1, state)
        ])
        XCTAssertEqual(eventObserver.events, [.next(1, .showBasicModeUnavailableDialog)])
    }
    
    func test_shouldShowRemovalDialog_whenRemoveButtonTapped() {
        // given
        let state = AccountCreationViewState()
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.removeTapped()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showRemovalDialog) ])
    }
    
    func test_shouldNavigateToAddAccount_whenCreateAccountButtonTapped() {
        // given
        let state = AccountCreationViewState()
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.addAccountTapped()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
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
        // given
        let profile = AuthProfileItem(testContext: nil)
        deleteProfileUseCase.returns = .just(DeleteProfileResult(restartNeeded: false, reauthNeeded: false))
        let state = AccountCreationViewState(profileId: profile.objectID)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, event) ])
        
        XCTAssertEqual(deleteProfileUseCase.parameters, [profile.objectID])
    }
    
    func test_shouldShowRemovalFailure_whenProfileRemovalFailed() {
        doTest_shouldShowRemovalFailure(event: .showRemovalFailure) {
            viewModel.removeAccount()
        }
    }
    
    func test_shouldShowRemovalFailure_whenProfileLogoutFailed() {
        doTest_shouldShowRemovalFailure(event: .showRemovalFailure) {
            viewModel.logoutAccount()
        }
    }
    
    private func doTest_shouldShowRemovalFailure(event: AccountCreationViewEvent, _ action: () -> Void) {
        // given
        let profile = AuthProfileItem(testContext: nil)
        deleteProfileUseCase.returns = .error(DeleteProfileError.profileNotExist)
        
        let state = AccountCreationViewState(profileId: profile.objectID)
        viewModel.updateView(state: state)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        action()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [ .next(0, state) ])
        XCTAssertEqual(eventObserver.events, [ .next(1, .showProgress), .next(1, event) ])
        
        XCTAssertEqual(deleteProfileUseCase.parameters, [profile.objectID])
        
    }
    
    func test_shouldShowEmptyNameDialog_whenProfileNameVisible() {
        // given
        globalSettings.anyAccountRegisteredReturns = true
        
        let state = AccountCreationViewState(
            profileName: "Some name",
            profileNameVisible: true
        )
        viewModel.updateView(state: state)
        
        let nameObservable = PublishSubject<String>()
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.bind(field: \.profileName, toObservable: nameObservable)
        nameObservable.on(.next(""))
        scheduler.advanceTo(2)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.profileName, to: ""))
        ])
        XCTAssertEqual(eventObserver.events, [ .next(2, .showEmptyNameDialog) ])
    }
    
    func test_shouldShowDuplicatedNameDialog_whenProfileWithSameNameExists() {
        // given
        let name = "Some name"
        let state = AccountCreationViewState(
            profileName: name,
            emailAddress: "some@email.com",
            authType: .email,
            serverAutoDetect: true,
            serverAddressForEmail: "email.com",
            accessId: "",
            accessIdPassword: "",
            serverAddressForAccessId: ""
        )
        viewModel.updateView(state: state)
        
        saveOrCreateProfileUseCase.returns = Observable<SaveOrCreateProfileResult>.error(SaveOrCreateProfileError.duplicatedName)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
        ])
        XCTAssertEqual(eventObserver.events, [
            .next(1, .showProgress),
            .next(1, .showDuplicatedNameDialog)
        ])
        
        XCTAssertTuples(saveOrCreateProfileUseCase.parameters, [
            (nil, name, false, AuthInfo.from(state: state))
        ])
    }
    
    func test_shouldShowMissingRequiredDataDialog_whenMailIsNotProvided() {
        // given
        let name = "Some name"
        let state = AccountCreationViewState(
            profileName: name,
            emailAddress: "some@email.com",
            authType: .email,
            serverAutoDetect: true,
            serverAddressForEmail: "email.com",
            accessId: "",
            accessIdPassword: "",
            serverAddressForAccessId: ""
        )
        viewModel.updateView(state: state)
        
        saveOrCreateProfileUseCase.returns = Observable<SaveOrCreateProfileResult>.error(SaveOrCreateProfileError.dataIncomplete)
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
        ])
        XCTAssertEqual(eventObserver.events, [
            .next(1, .showProgress),
            .next(1, .showRequiredDataMisingDialog)
        ])
        
        XCTAssertTuples(saveOrCreateProfileUseCase.parameters, [
            (nil, name, false, AuthInfo.from(state: state))
        ])
    }
    
    func test_shouldSaveProfile() {
        // given
        let name = "Some name"
        let state = AccountCreationViewState(
            profileName: name,
            emailAddress: "some@email.com",
            authType: .email,
            serverAutoDetect: true,
            serverAddressForEmail: "email.com",
            accessId: "",
            accessIdPassword: "",
            serverAddressForAccessId: ""
        )
        viewModel.updateView(state: state)
        
        saveOrCreateProfileUseCase.returns = .just(SaveOrCreateProfileResult(saved: true, needsReauth: true))
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
        ])
        XCTAssertEqual(eventObserver.events, [
            .next(1, .showProgress),
            .next(1, .formSaved(needsReauth: true))
        ])
        
        XCTAssertTuples(saveOrCreateProfileUseCase.parameters, [
            (nil, name, false, AuthInfo.from(state: state))
        ])
    }
    
    func test_shouldSaveProfileWithoutReauth_whenNoAuthDataChanged() {
        // given
        let name = "Some name"
        let state = AccountCreationViewState(
            profileName: name,
            emailAddress: "some@email.com",
            authType: .email,
            serverAutoDetect: true,
            serverAddressForEmail: "email.com",
            accessId: "",
            accessIdPassword: "",
            serverAddressForAccessId: ""
        )
        viewModel.updateView(state: state)
        
        saveOrCreateProfileUseCase.returns = .just(SaveOrCreateProfileResult(saved: true, needsReauth: false))
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.save()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 2)
        
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
        ])
        XCTAssertEqual(eventObserver.events, [
            .next(1, .showProgress),
            .next(1, .formSaved(needsReauth: false))
        ])
        
        XCTAssertTuples(saveOrCreateProfileUseCase.parameters, [
            (nil, name, false, AuthInfo.from(state: state))
        ])
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
