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
@testable import SUPLA
import XCTest

final class RateAppViewModelTests: XCTestCase {
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    private lazy var profileRepository: ProfileRepositoryMock! = ProfileRepositoryMock()
    private lazy var channelRepository: ChannelRepositoryMock! = ChannelRepositoryMock()
    private lazy var router: AppRouterMock! = AppRouterMock()

    override func setUp() {
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        DiContainer.shared.register(type: ProfileRepository.self, profileRepository!)
        DiContainer.shared.register(type: ChannelRepository.self, channelRepository!)
        DiContainer.shared.register(type: AppRouter.self, router!)
    }

    override func tearDown() {
        settings = nil
        profileRepository = nil
        channelRepository = nil
        router = nil
    }

    func test_shouldSetRateTimeThreeDaysAhead_whenFirstStarted() async {
        // given
        settings.rateAppConfigTimeReturns = 0

        // when
        let viewModel = createViewModel()

        // then
        await waitUntil { !self.settings.rateAppConfigTimeValues.isEmpty }
        XCTAssertFalse(viewModel.present)
        XCTAssertEqual(profileRepository.activeProfileCalls, 0)
        XCTAssertRateTime(daysAhead: 3, settings.rateAppConfigTimeValues.last)
    }

    func test_shouldNotShowDialog_whenUserDeclinedRating() async {
        // given
        settings.rateAppConfigTimeReturns = -1

        // when
        let viewModel = createViewModel()

        // then
        await waitShortly()
        XCTAssertFalse(viewModel.present)
        XCTAssertTrue(settings.rateAppConfigTimeValues.isEmpty)
        XCTAssertEqual(profileRepository.activeProfileCalls, 0)
    }

    func test_shouldNotShowDialog_whenRateTimeIsInFuture() async {
        // given
        settings.rateAppConfigTimeReturns = timestamp(daysFromNow: 1)

        // when
        let viewModel = createViewModel()

        // then
        await waitShortly()
        XCTAssertFalse(viewModel.present)
        XCTAssertTrue(settings.rateAppConfigTimeValues.isEmpty)
        XCTAssertEqual(profileRepository.activeProfileCalls, 0)
    }

    func test_shouldPostponeOneDay_whenRateTimePassedAndThereAreNoChannels() async {
        // given
        let profile = AuthProfileItem(testContext: nil)
        settings.rateAppConfigTimeReturns = timestamp(daysFromNow: -1)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.allChannelsObservable = .just([])

        // when
        let viewModel = createViewModel()

        // then
        await waitUntil { !self.settings.rateAppConfigTimeValues.isEmpty }
        XCTAssertFalse(viewModel.present)
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertRateTime(daysAhead: 1, settings.rateAppConfigTimeValues.last)
    }

    func test_shouldShowDialog_whenRateTimePassedAndThereAreChannels() async {
        // given
        let profile = AuthProfileItem(testContext: nil)
        let channel = SAChannel(testContext: nil)
        settings.rateAppConfigTimeReturns = timestamp(daysFromNow: -1)
        profileRepository.activeProfileObservable = .just(profile)
        channelRepository.allChannelsObservable = .just([channel])

        // when
        let viewModel = createViewModel()

        // then
        await waitUntil { viewModel.present }
        XCTAssertEqual(profileRepository.activeProfileCalls, 1)
        XCTAssertTrue(settings.rateAppConfigTimeValues.isEmpty)
    }

    func test_onLater_shouldPostponeSevenDaysAndHideDialog() {
        // given
        settings.rateAppConfigTimeReturns = -1
        let viewModel = createViewModel()
        viewModel.present = true

        // when
        viewModel.onLater()

        // then
        XCTAssertFalse(viewModel.present)
        XCTAssertRateTime(daysAhead: 7, settings.rateAppConfigTimeValues.last)
    }

    func test_onNoThanks_shouldDisableDialogAndHideDialog() {
        // given
        settings.rateAppConfigTimeReturns = -1
        let viewModel = createViewModel()
        viewModel.present = true

        // when
        viewModel.onNoThanks()

        // then
        XCTAssertFalse(viewModel.present)
        XCTAssertEqual(settings.rateAppConfigTimeValues.last, -1)
    }

    func test_onRateNow_shouldPostponeOneYearHideDialogAndOpenReviewUrl() {
        // given
        settings.rateAppConfigTimeReturns = -1
        let viewModel = createViewModel()
        viewModel.present = true

        // when
        viewModel.onRateNow()

        // then
        XCTAssertFalse(viewModel.present)
        XCTAssertRateTime(daysAhead: 365, settings.rateAppConfigTimeValues.last)
        router.openUrlMock.verifyCalls(1)
        XCTAssertEqual(router.openUrlMock.parameters.first?.scheme, "itms-apps")
    }

    private func createViewModel() -> RateAppFeature.ViewModel {
        RateAppFeature.ViewModel()
    }

    private func timestamp(daysFromNow days: Int) -> Int {
        Int(Date(timeIntervalSinceNow: TimeInterval(days * 86_400)).timeIntervalSince1970)
    }

    private func waitShortly() async {
        try? await Task.sleep(nanoseconds: 50_000_000)
    }

    private func waitUntil(
        timeout: TimeInterval = 1,
        condition: @escaping () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let endTime = Date().timeIntervalSince1970 + timeout

        while (endTime > Date().timeIntervalSince1970) {
            if (condition()) {
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTFail("Time is up!", file: file, line: line)
    }

    private func XCTAssertRateTime(daysAhead: Int, _ timestamp: Int?, file: StaticString = #filePath, line: UInt = #line) {
        guard let timestamp else {
            XCTFail("Rate time was not set", file: file, line: line)
            return
        }

        let expected = self.timestamp(daysFromNow: daysAhead)
        XCTAssertLessThanOrEqual(abs(timestamp - expected), 2, file: file, line: line)
    }
}
