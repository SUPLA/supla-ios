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

extension MainFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton<ProfileRepository> private var profileRepository
        @Singleton<ChannelRepository> private var channelRepository

        init(state: ViewState = ViewState()) {
            super.init(state: state)
        }

        override func onViewAppear() {
            Task {
                await loadProfilesIconVisibility()
                await loadZWaveChannels()
            }
        }

        private func loadProfilesIconVisibility() async {
            let count = await profileRepository.getProfileCount()

            await MainActor.run {
                state.showProfilesIcon = count > 1
            }
        }
        
        private func loadZWaveChannels() async {
            let zWaveAvailable = await channelRepository.findZWaveChannelAvailable()
            
            await MainActor.run() {
                state.showZWave = zWaveAvailable
            }
        }
    }
}
