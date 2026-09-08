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

import Foundation
import RxSwift

extension RateAppFeature {
    class ViewModel: SuplaCore.Dialog.ViewModel {
        @Singleton<GlobalSettings> private var settings
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository
        @Singleton<AppRouter> private var router

        private static let reviewUrl = URL(
            string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=996384706&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
        )

        private var initializationTask: Task<Void, Never>?

        override init() {
            super.init()

            initializationTask = Task { [weak self] in await self?.initialize() }
        }

        deinit {
            initializationTask?.cancel()
        }

        func onRateNow() {
            moreDays(365)
            present = false

            guard let url = Self.reviewUrl else { return }
            router.openUrl(url: url)
        }

        func onLater() {
            moreDays(7)
            present = false
        }

        func onNoThanks() {
            settings.rateAppConfigTime = -1
            present = false
        }

        private func initialize() async {
            guard BrandingConfiguration.ASK_FOR_RATE else { return }

            let rateTime = settings.rateAppConfigTime
            if (rateTime == -1) {
                // User declined to provide feedback
            } else if (rateTime == 0) {
                // First application start - give the user three days to play with it.
                moreDays(3)
            } else if (Int(Date().timeIntervalSince1970) >= rateTime) {
                let hasChannels = await hasAnyChannel()
                if (hasChannels) {
                    // There are channels, so the user already used the app - ask for rate.
                    await MainActor.run { present = true }
                } else {
                    // No channels - wait one day more.
                    moreDays(1)
                }
            }
        }

        private func moreDays(_ days: Int) {
            let rateTime = Int(Date(timeIntervalSinceNow: TimeInterval(days * 86_400)).timeIntervalSince1970)
            settings.rateAppConfigTime = rateTime
        }

        private func hasAnyChannel() async -> Bool {
            guard let profile = try? await profileRepository.getActiveProfile().awaitFirstElement() else { return false }
            guard let channels = try? await channelRepository.getAllChannels(forProfile: profile).awaitFirstElement() else { return false }

            return channels.count > 0
        }
    }
}
