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
import SwiftUI

extension ThermostatGeneralFeature {
    final class ViewState: ObservableObject {
        @Published var remoteId: Int32? = nil
        @Published var channelFunc: Int32? = nil
        @Published var mode: SuplaHvacMode? = nil
        @Published var offline: Bool = true
        @Published var configMin: Float? = nil
        @Published var configMax: Float? = nil
        @Published var childrenIds: [Int32] = []
        @Published var sent: Bool = false
        @Published var lastInteractionTime: TimeInterval? = nil
        @Published var changing: Bool = false
        @Published var loadingState: LoadingState = .init()
        @Published var subfunction: ThermostatSubfunction? = nil
        @Published var timerEndDate: Date? = nil
        @Published var currentPower: Int? = nil
        @Published var setpointHeat: Float? = nil
        @Published var setpointCool: Float? = nil
        @Published var activeSetpointType: SetpointType? = nil
        @Published var currentTemperaturePercentage: Float? = nil
        @Published var heatingIndicatorActive: Bool? = nil
        @Published var coolingIndicatorActive: Bool? = nil
        @Published var manualActive: Bool = false
        @Published var weeklyScheduleActive: Bool = false
        @Published var plusMinusHidden: Bool = false
        @Published var temporaryChangeActive: Bool = false
        @Published var programInfo: [ThermostatProgramInfo] = []
        @Published var issues: [ChannelIssueItem] = []
        @Published var sensorIssue: SensorIssue? = nil
        @Published var pumpSwitchIcon: IconResult? = nil
        @Published var heatOrColdSourceSwitchIcon: IconResult? = nil
        @Published var controlButtonsEnabled: Bool = false
        let thermometerValues = ThermometerValuesState()
        @Published var channelCurrentStateData: ChannelCurrentState.Data? = nil
        @Published var channelProgramState: [ChannelProgramState.Data] = []
        @Published var thermostatAutoMode: ThermostatAutoMode? = nil

        var operationalMode: ThermostatOperationalMode {
            if offline { return .offline }
            if mode == .off || mode == .notSet {
                return .off(heating: heatingIndicatorActive == true, cooling: coolingIndicatorActive == true)
            }
            if heatingIndicatorActive == true { return .heating }
            if coolingIndicatorActive == true { return .cooling }
            return .standby
        }

        var off: Bool { offline || mode == .off || mode == .notSet }
        var setpointText: String? {
            if offline { return "offline" }
            if off { return "off" }
            if mode == .heat { return setpointHeat.toTemperatureString(ValueFormat.companion.TemperatureWithDegree) }
            if mode == .cool { return setpointCool.toTemperatureString(ValueFormat.companion.TemperatureWithDegree) }
            if mode == .heatCool {
                let heat = setpointHeat.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
                let cool = setpointCool.toTemperatureString(ValueFormat.companion.TemperatureWithDegree)
                return "\(heat) - \(cool)"
            }
            return nil
        }
        var setpointHeatPercentage: Float? {
            guard let min = configMin, let max = configMax, let current = setpointHeat, !off || weeklyScheduleActive else { return nil }
            
            return switch (mode) {
            case .heat, .heatCool: (current - min) / (max - min)
            default: nil
            }
        }
        var setpointCoolPercentage: Float? {
            guard let min = configMin, let max = configMax, let current = setpointCool, !off || weeklyScheduleActive else { return nil }
            
            return switch (mode) {
            case .cool, .heatCool: (current - min) / (max - min)
            default: nil
            }
        }
        var plusButtonEnabled: Bool {
            guard mode != .off || weeklyScheduleActive else { return false }
            switch activeSetpointType {
            case .heat: return (setpointHeat ?? 0) < (configMax ?? 0)
            case .cool: return (setpointCool ?? 0) < (configMax ?? 0)
            default: return false
            }
        }
        var minusButtonEnabled: Bool {
            guard mode != .off || weeklyScheduleActive else { return false }
            switch activeSetpointType {
            case .heat: return (setpointHeat ?? 0) > (configMin ?? 0)
            case .cool: return (setpointCool ?? 0) > (configMin ?? 0)
            default: return false
            }
        }
        var powerIconColor: UIColor { ((off && !weeklyScheduleActive) || offline) ? .red : .primary }
        var configMinMaxHidden: Bool { offline }
        var grayOutSetpoints: Bool { !offline && off && weeklyScheduleActive }
        var timerInfoHidden: Bool {
            sensorIssue != nil || timerEndDate == nil || timerEndDate!.timeIntervalSince1970 < Date().timeIntervalSince1970
        }
        var endDateText: String { ThermostatStateHelper.endDateText(timerEndDate) }
        var currentStateIcon: UIImage? { ThermostatStateHelper.currentStateIcon(mode)?.uiImage }
        var currentStateIconColor: UIColor { ThermostatStateHelper.currentStateIconColor(mode) }
        var currentStateValue: String {
            ThermostatStateHelper.currentStateValue(mode, heatSetpoint: setpointHeat, coolSetpoint: setpointCool)
        }
    }
}


