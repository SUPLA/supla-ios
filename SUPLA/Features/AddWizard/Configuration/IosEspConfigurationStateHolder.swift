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
    
import SharedCore

class IosEspConfigurationStateHolder: SharedCore.EspConfigurationStateHolder {
    private let espConfigurationController: EspConfigurationController
    private lazy var state: EspConfigurationState = Idle(stateHolder: self, espConfigurationController: espConfigurationController)
    
    var isInactive: Bool {
        state is Idle || state is Finished || state is ConfigurationFailure || state is Canceled
    }
    
    var currentState: EspConfigurationState { state }
    
    init(espConfigurationController: EspConfigurationController) {
        self.espConfigurationController = espConfigurationController
    }
    
    func handle(_ event: EspConfigurationEvent) {
        synced(self) {
            SALog.info("Handling event `\(event)` by state `\(state)`")
            state.handle(event: event)
        }
    }
    
    func setState(state: any EspConfigurationState) {
        SALog.info("State changed to \(state)")
        self.state = state
        // On iOS WiFi scann is not allowed so we're asking to connect to a network with specific ESSID.
        // Each connection try take some time (about 3 secs), so we want show that on progress bar.
        // The connection state has progress 0.5, so we shift down everything before 0.5 dividing by two.
        // Everything above 0.5 is shifted up, so we get internal half of the progress for the connection checks.
        let progress = Self.remappedProgress(for: state.progress)
        
        // 0 ...................... 0.25 ...................... 0.5 ...................... 0.75 ...................... 1
        //      progress by state     |        progress by state + ssid connection try       |    progress by state    |
        
        espConfigurationController.updateProgress(progress: progress, descriptionLabel: state.progressLabel)
    }

    static func remappedProgress(for progress: Float) -> Float {
        let remappedProgress = progress <= 0.5 ? (progress / 2) : (0.5 + progress / 2)
        return min(max(remappedProgress, 0), 1)
    }
}
