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
    
import SwiftUI

extension ThermostatTimerDetailFeature {
    
    struct InProgressView : SwiftUI.View {
        let deviceStateData: DeviceState.Data?
        let timerEndTime: Date?
        let delegate: ViewDelegate?
        
        private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        @State private var timerString: String = ""
        
        @ObservedObject private var orientationObserver = OrientationObserver()
        
        var body: some SwiftUI.View {
            if (orientationObserver.orientation.isLandscape) {
                LandscapeView()
            } else {
                PortraitView()
            }
        }
        
        private func LandscapeView() -> some SwiftUI.View {
            HStack(alignment: .center, spacing: Distance.default) {
                VStack {
                    if let deviceStateData {
                        Text(deviceStateData.label.uppercased())
                            .fontBodyMedium()
                            .textColor(Color.Supla.onSurfaceVariant)
                        
                        HStack(spacing: Distance.tiny) {
                            if let icon = deviceStateData.icon {
                                icon.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                            }
                            
                            Text(deviceStateData.value)
                                .font(.Supla.bodyMedium.bold())
                        }
                    }
                    Spacer()
                    EditTimerButton()
                }
                .padding(.vertical, Distance.default)
                TimerView()
                VStack(spacing: Distance.small) {
                    Spacer()
                    Text(Strings.TimerDetail.cancelThermostat)
                        .fontBodyMedium()
                    CancelButtons()
                    Spacer()
                }
            }
        }
        
        private func PortraitView() -> some SwiftUI.View {
            VStack(spacing: 0) {
                if let deviceStateData {
                    DeviceState.View(data: deviceStateData)
                }
                Spacer()
                VStack(spacing: Distance.default) {
                    TimerView()
                    EditTimerButton()
                }
                Spacer()
                Text(Strings.TimerDetail.cancelThermostat)
                    .fontBodyMedium()
                HStack(spacing: Distance.tiny) {
                    CancelButtons()
                }
                .padding(.horizontal, Distance.default)
                .padding(.top, Distance.tiny)
                .padding(.bottom, Distance.default)
            }
        }
        
        private func TimerView() -> some SwiftUI.View {
            ZStack {
                TimerProgressView(indeterminate: true)
                Text(timerString)
                    .fontTitleLarge()
                    .onReceive(timer) { _ in
                        timerString = leftTimeString
                    }
            }
        }
        
        private func EditTimerButton() -> some SwiftUI.View {
            Button(action: { delegate?.onEditTimer() }) {
                HStack {
                    Text(Strings.TimerDetail.editTime)
                        .fontBodyMedium()
                        .textColor(.Supla.onBackground)
                    Image(.Icons.pencil)
                        .renderingMode(.template)
                        .foregroundColor(.Supla.primary)
                }
            }
        }
        
        @ViewBuilder
        private func CancelButtons() -> some SwiftUI.View {
            SwitchButton(Strings.ThermostatDetail.modeManual) { delegate?.onCancelTimerIntoManualMode() }
            SwitchButton(Strings.ThermostatDetail.modeWeeklySchedule) { delegate?.onCancelTimerIntoProgramMode() }
        }
        
        private var leftTimeString: String {
            let currentDate = Date()
            
            guard let timerEndTime,
                  currentDate.timeIntervalSince1970 <= timerEndTime.timeIntervalSince1970
            else {
                return ""
            }
            
            let leftTime = timerEndTime.differenceInSeconds(currentDate)
                
            @Singleton<ValuesFormatter> var formatter
            let timeString = formatter.getTimeString(
                hour: leftTime.hoursInDay,
                minute: leftTime.minutesInHour,
                second: leftTime.secondsInMinute
            )
                
            let days = leftTime.days
            if (days == 0) {
                return timeString
            } else if (days == 1) {
                let daysString = Strings.TimerDetail.dayPattern.arguments(days)
                return "\(daysString)\n\(timeString)"
            } else {
                let daysString = Strings.TimerDetail.daysPattern.arguments(days)
                return "\(daysString)\n\(timeString)"
            }
        }
    }
}

#Preview {
    ThermostatTimerDetailFeature.InProgressView(
        deviceStateData: DeviceState.Data(
            label: "STATE UNTIL 17.04.2026 00:59:",
            icon: .suplaIcon(name: .Icons.powerButton),
            value: "OFF"
        ),
        timerEndTime: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 154),
        delegate: nil
    )
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("(Landscape)", traits: .landscapeRight) {
    BackgroundStack(alignment: .top) {
        ThermostatTimerDetailFeature.InProgressView(
            deviceStateData: DeviceState.Data(
                label: "STATE UNTIL 17.04.2026 00:59:",
                icon: .suplaIcon(name: .Icons.powerButton),
                value: "OFF"
            ),
            timerEndTime: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 154),
            delegate: nil
        )
        .safeAreaPadding()
    }
}
#endif // swift(>=5.9)
