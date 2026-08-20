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

import RxSwift
import RxTest
import SharedCore
import XCTest

@testable import SUPLA

final class ChannelListVMTests: SuplaCore.ViewModelTest<ChannelListFeature.ViewState> {
    private lazy var viewModel: ChannelListFeature.ViewModel! = ChannelListFeature.ViewModel()

    private lazy var createProfileChannelsListUseCase: CreateProfileChannelsList.Mock! = CreateProfileChannelsList.Mock()

    private lazy var swapChannelPositionsUseCase: SwapChannelPositionsUseCaseMock! = SwapChannelPositionsUseCaseMock()

    private lazy var toggleLocationUseCase: ToggleLocationUseCaseMock! = ToggleLocationUseCaseMock()

    private lazy var provideDetailTypeUseCase: ProvideChannelDetailTypeUseCaseMock! = ProvideChannelDetailTypeUseCaseMock()

    private lazy var updateEventsManager: UpdateEventsManagerMock! = UpdateEventsManagerMock()

    private lazy var channelBaseActionUseCase: ChannelBaseActionUseCaseMock! = ChannelBaseActionUseCaseMock()

    private lazy var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCaseMock! = ReadChannelWithChildrenUseCaseMock()

    private lazy var executeSimpleActionUseCase: ExecuteSimpleAction.Mock! = ExecuteSimpleAction.Mock()

    private lazy var channelToMainListItemUseCase: ChannelToMainListItem.Mock! = ChannelToMainListItem.Mock()

    private lazy var triggerLogHistoryDownloadUseCase: TriggerLogHistoryDownload.Mock! = TriggerLogHistoryDownload.Mock()

    private lazy var router: AppRouterMock! = AppRouterMock()

    override func setUp() {
        updateEventsManager.observeAllChannelsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllGroupsMock.returns = .single(Observable.empty())
        updateEventsManager.observeAllScenesMock.returns = .single(Observable.empty())

        DiContainer.shared.register(type: CreateProfileChannelsList.UseCase.self, createProfileChannelsListUseCase!)
        DiContainer.shared.register(type: SwapChannelPositionsUseCase.self, swapChannelPositionsUseCase!)
        DiContainer.shared.register(type: ProvideChannelDetailTypeUseCase.self, provideDetailTypeUseCase!)
        DiContainer.shared.register(type: ToggleLocationUseCase.self, toggleLocationUseCase!)
        DiContainer.shared.register(type: UpdateEventsManager.self, updateEventsManager!)
        DiContainer.shared.register(type: ChannelBaseActionUseCase.self, channelBaseActionUseCase!)
        DiContainer.shared.register(type: ReadChannelWithChildrenUseCase.self, readChannelWithChildrenUseCase!)
        DiContainer.shared.register(type: ExecuteSimpleAction.UseCase.self, executeSimpleActionUseCase!)
        DiContainer.shared.register(type: ChannelToMainListItem.UseCase.self, channelToMainListItemUseCase!)
        DiContainer.shared.register(type: TriggerLogHistoryDownload.UseCase.self, triggerLogHistoryDownloadUseCase!)
        DiContainer.shared.register(type: AppRouter.self, router!)
    }

    override func tearDown() {
        viewModel?.onViewDisappear()
        viewModel = nil

        createProfileChannelsListUseCase = nil
        swapChannelPositionsUseCase = nil
        provideDetailTypeUseCase = nil
        toggleLocationUseCase = nil
        updateEventsManager = nil
        channelBaseActionUseCase = nil
        readChannelWithChildrenUseCase = nil
        executeSimpleActionUseCase = nil
        channelToMainListItemUseCase = nil
        triggerLogHistoryDownloadUseCase = nil
        router = nil

        super.tearDown()
    }

    func test_shouldReloadItems_onChannelStructureUpdate() {
        // given
        let items = [channelItem(remoteId: 1)]
        updateEventsManager.observeChannelUpdatesObservable = Observable.just(())
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just(items))
        
        // then
        _ = viewModel

        // then
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldUpdateListItems_onViewAppear() {
        // given
        let items = [MainListItem.location(locationItem(remoteId: 10)), channelItem(remoteId: 1)]
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onViewAppear()

        // then
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
        XCTAssertFalse(viewModel.state.loading)
        XCTAssertTrue(viewModel.state.listLoaded)
    }

    func test_shouldUpdateSingleItem_onChannelUpdate() {
        // given
        let channelUpdates = PublishSubject<Int32>()
        let initialItem = channelItem(remoteId: 1, title: "Old")
        let updatedItem = channelItem(remoteId: 1, title: "New")
        let channel = channel(remoteId: 1)

        updateEventsManager.observeAllChannelsMock.returns = .single(channelUpdates.asObservable())
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just([initialItem]))
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        channelToMainListItemUseCase.invokeMock.returns = .single(updatedItem)

        viewModel.onViewAppear()

        // when
        channelUpdates.onNext(1)

        // then
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [1])
        XCTAssertEqual(channelToMainListItemUseCase.invokeMock.parameters.count, 1)
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, [updatedItem])
    }

    func test_shouldNotReloadList_whenSingleChannelUpdateIsHandled() {
        // given
        let channelUpdates = PublishSubject<Int32>()
        let channel = channel(remoteId: 1)

        updateEventsManager.observeAllChannelsMock.returns = .single(channelUpdates.asObservable())
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just([channelItem(remoteId: 1)]))
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        channelToMainListItemUseCase.invokeMock.returns = .single(channelItem(remoteId: 1, title: "Updated"))

        viewModel.onViewAppear()

        // when
        channelUpdates.onNext(1)

        // then
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
    }

    func test_shouldSwipeItemsAndReloadList() {
        // given
        let firstItem = channelItem(remoteId: 2, locationCaption: "Caption")
        let secondItem = channelItem(remoteId: 4, locationCaption: "Caption")
        let reloadedItems = [secondItem, firstItem]

        swapChannelPositionsUseCase.invokeMock.returns = .single(Observable.just(()))
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just(reloadedItems))

        // when
        viewModel.onMove(firstItem, secondItem)

        // then
        XCTAssertTuples(swapChannelPositionsUseCase.invokeMock.parameters, [(2, 4, "Caption")])
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, reloadedItems)
    }

    func test_shouldReloadList_whenLocationToggled() {
        // given
        let location = locationItem(remoteId: 123)
        let items = [MainListItem.location(location)]

        toggleLocationUseCase.invokeMock = FunctionMock()
        toggleLocationUseCase.invokeMock.returns = .single(Observable.just(()))
        createProfileChannelsListUseCase.invokeMock.returns = .single(Observable.just(items))

        // when
        viewModel.onLocationClick(location)

        // then
        XCTAssertTuples(toggleLocationUseCase.invokeMock.parameters, [(123, .channel)])
        createProfileChannelsListUseCase.invokeMock.verifyCalls(1)
        XCTAssertEqual(viewModel.state.items, items)
    }

    func test_shouldOpenLegacyDetail_whenChannelIsOnline() {
        // given
        let channel = channel(remoteId: 321, function: SUPLA_CHANNELFNC_THERMOMETER, online: true)
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        provideDetailTypeUseCase.detailType = .legacy(type: .thermostat_hp)

        // when
        viewModel.onItemClick(channelItem(remoteId: 321))

        // then
        XCTAssertEqual(readChannelWithChildrenUseCase.parameters, [321])
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 1)
        XCTAssertEqual(router.navigateMock.parameters, [
            .legacyDetail(type: .thermostat_hp, channelRemoteId: 321)
        ])
    }

    func test_shouldOpenLegacyDetail_whenChannelIsOfflineButAvailableOffline() {
        // given
        let channel = channel(remoteId: 321, function: SUPLA_CHANNELFNC_THERMOMETER, online: false)
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        provideDetailTypeUseCase.detailType = .legacy(type: .thermostat_hp)

        // when
        viewModel.onItemClick(channelItem(remoteId: 321))

        // then
        XCTAssertEqual(router.navigateMock.parameters, [
            .legacyDetail(type: .thermostat_hp, channelRemoteId: 321)
        ])
    }

    func test_shouldNotOpenDetail_whenChannelIsOfflineAndUnavailableOffline() {
        // given
        let channel = channel(remoteId: 321, function: SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL, online: false)
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        provideDetailTypeUseCase.detailType = .legacy(type: .thermostat_hp)

        // when
        viewModel.onItemClick(channelItem(remoteId: 321))

        // then
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 0)
        XCTAssertEqual(router.navigateMock.parameters, [])
    }

    func test_shouldNotOpenDetail_whenDetailTypeIsMissing() {
        // given
        let channel = channel(remoteId: 321, function: SUPLA_CHANNELFNC_STAIRCASETIMER, online: true)
        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        provideDetailTypeUseCase.detailType = nil

        // when
        viewModel.onItemClick(channelItem(remoteId: 321))

        // then
        XCTAssertEqual(provideDetailTypeUseCase.channelBaseArray.count, 1)
        XCTAssertEqual(router.navigateMock.parameters, [])
    }

    func test_shouldOpenStandardDetail() {
        // given
        let remoteId: Int32 = 322
        let deviceId: Int32 = 433
        let function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH
        let profileId: Int32 = 1
        let channel = channel(remoteId: remoteId, profileId: profileId, deviceId: deviceId, function: function, online: true)

        readChannelWithChildrenUseCase.returns = Observable.just(ChannelWithChildren(channel: channel, children: []))
        provideDetailTypeUseCase.detailType = .standardDetail(pages: [.switchGeneral])

        // when
        viewModel.onItemClick(channelItem(remoteId: remoteId))

        // then
        XCTAssertEqual(router.navigateMock.parameters, [
            .standardDetail(
                item: ItemBundle(remoteId: remoteId, profileId: profileId, deviceId: deviceId, subjectType: .channel, function: function),
                pages: [.switchGeneral]
            )
        ])
    }

    func test_leftButtonClicked() {
        // given
        let item = channelItem(remoteId: 321)
        channelBaseActionUseCase.remoteIdMock.returns = .single(Observable.just(.success))

        // when
        viewModel.onLeftButtonClick(item)

        // then
        XCTAssertTuples(channelBaseActionUseCase.remoteIdMock.parameters, [(321, .leftButton)])
        XCTAssertNil(viewModel.state.alertDialogState)
    }

    func test_rightButtonClicked_shouldShowConfirmationAlert() {
        // given
        let item = channelItem(remoteId: 321)
        channelBaseActionUseCase.remoteIdMock.returns = .single(Observable.just(.overcurrentRelayOff))

        // when
        viewModel.onRightButtonClick(item)

        // then
        XCTAssertTuples(channelBaseActionUseCase.remoteIdMock.parameters, [(321, .rightButton)])
        XCTAssertEqual(viewModel.state.alertDialogState?.message, Strings.SwitchDetail.overcurrentQuestion)
        XCTAssertEqual(viewModel.state.alertDialogState?.remoteId, 321)
        XCTAssertEqual(viewModel.state.alertDialogState?.action, .turnOn)
    }

    func test_shouldExecuteAlertAction_whenAlertConfirmed() {
        // given
        executeSimpleActionUseCase.returns = Observable.just(())

        // when
        viewModel.onAlertConfirmed(321, .open)

        // then
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [
            (.open, SUPLA.SubjectType.channel, 321)
        ])
        XCTAssertNil(viewModel.state.alertDialogState)
    }

    func test_shouldNavigateToAddWizard() {
        // when
        viewModel.onAddDeviceClick()

        // then
        XCTAssertEqual(router.navigateMock.parameters, [.addWizard])
    }

    func test_shouldNavigateToDeviceCatalog() {
        // when
        viewModel.onDeviceCatalogClick()

        // then
        XCTAssertEqual(router.navigateMock.parameters, [.deviceCatalog])
    }

    private func channelItem(
        remoteId: Int32,
        profileId: Int32 = 1,
        function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH,
        locationCaption: String = "Location",
        title: String = "Title"
    ) -> MainListItem {
        .channel(
            DefaultListItem(
                remoteId: remoteId,
                profileId: profileId,
                userCaption: title,
                function: SuplaFunction.companion.from(value: function),
                locationCaption: locationCaption,
                locationId: 1,
                status: .channel(.online),
                title: title,
                icon: .suplaIcon(name: ""),
                value: nil
            )
        )
    }

    private func locationItem(remoteId: Int32, profileId: Int32 = 1) -> LocationListItem {
        LocationListItem(
            remoteId: remoteId,
            profileId: profileId,
            userCaption: "Location",
            collapsed: false
        )
    }

    private func channel(
        remoteId: Int32,
        profileId: Int32 = 1,
        deviceId: Int32 = 1,
        function: Int32 = SUPLA_CHANNELFNC_LIGHTSWITCH,
        online: Bool = true
    ) -> SAChannel {
        let profile = AuthProfileItem(testContext: nil)
        profile.id = profileId

        let channel = SAChannel(testContext: nil)
        channel.profile = profile
        channel.value = SAChannelValue(testContext: nil)
        channel.value?.online = online ? SUPLA_CHANNEL_ONLINE_FLAG_ONLINE : 0
        channel.remote_id = remoteId
        channel.device_id = deviceId
        channel.func = function

        return channel
    }
}
