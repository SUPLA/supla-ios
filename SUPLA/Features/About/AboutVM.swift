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
    

extension AboutFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton private var coordinator: SuplaAppCoordinator
        @Singleton private var buildInfo: BuildInfo
        @Singleton private var formatter: ValuesFormatter
        @Singleton private var settings: GlobalSettings
        
        private var buildTimeClickCount = 0
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            state.version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
            state.buildTime = formatter.getFullDateString(date: buildInfo.compileDate())
        }
        
        func onHomePageClicked() {
            coordinator.openUrl(url: "https://\(Strings.About.address)")
        }
        
        func onBuildTimeClicked() {
            if (settings.devModeActive) {
                // Do nothing, dev mode already activated
                return
            }
            
            buildTimeClickCount += 1
            if buildTimeClickCount == 5 {
                settings.devModeActive = true
                state.showToast = true
                
                Task {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    
                    await MainActor.run {
                        state.showToast = false
                    }
                }
            }
        }
    }
}
