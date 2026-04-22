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
    struct ConfigurationView: SwiftUI.View {
        let selectedMode: Binding<DeviceMode>
        let availableModes: [DeviceMode]
        let timeSelectionMode: TimeSelectionMode
        let infoText: String
        let edit: Bool
        let startDisabled: Bool
        let minusDisabled: Bool
        let plusDisabled: Bool
        let setpointInChange: SetpointType
        let setpointValue: String
        
        let heatingValue: Binding<CGFloat>
        let coolingValue: Binding<CGFloat>
        
        let timerDays: Binding<DayPickerItem>
        let timerHours: Binding<HourPickerItem>
        let timerMinutes: Binding<NumberPickerItem>
        let calendarDate: Binding<Date>
        
        let delegate: ViewDelegate?
        
        @ObservedObject private var orientationObserver = OrientationObserver()
        
        init(
            selectedMode: Binding<DeviceMode>,
            availableModes: [DeviceMode],
            timeSelectionMode: TimeSelectionMode,
            infoText: String,
            edit: Bool,
            startDisabled: Bool,
            minusDisabled: Bool,
            plusDisabled: Bool,
            setpointInChange: SetpointType,
            setpointValue: String,
            heatingValue: Binding<CGFloat>,
            coolingValue: Binding<CGFloat>,
            timerDays: Binding<DayPickerItem>,
            timerHours: Binding<HourPickerItem>,
            timerMinutes: Binding<NumberPickerItem>,
            calendarDate: Binding<Date>,
            delegate: ViewDelegate?,
            orientationObserver: OrientationObserver = OrientationObserver()
        ) {
            self.selectedMode = selectedMode
            self.availableModes = availableModes
            self.timeSelectionMode = timeSelectionMode
            self.infoText = infoText
            self.edit = edit
            self.startDisabled = startDisabled
            self.minusDisabled = minusDisabled
            self.plusDisabled = plusDisabled
            self.setpointInChange = setpointInChange
            self.setpointValue = setpointValue
            self.heatingValue = heatingValue
            self.coolingValue = coolingValue
            self.timerDays = timerDays
            self.timerHours = timerHours
            self.timerMinutes = timerMinutes
            self.calendarDate = calendarDate
            self.delegate = delegate
            self.orientationObserver = orientationObserver
        }
        
        var body: some SwiftUI.View {
            if (orientationObserver.orientation.isLandscape) {
                LandscapeView()
            } else {
                PortraitView()
            }
        }
        
        private func LandscapeView() -> some SwiftUI.View {
            HStack(alignment: .top, spacing: Distance.small) {
                VStack(alignment: .leading) {
                    SelectionModeViews()
                    Spacer()
                    LandscapeButtons()
                }
                VStack {
                    ScrollView {
                        TimeSelectionViews()
                    }
                }
            }
            .padding(Distance.default)
        }
        
        private func PortraitView() -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: Distance.tiny) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Distance.tiny) {
                        SelectionModeViews()
                        Spacer().frame(height: Distance.tiny)
                        TimeSelectionViews()
                    }
                }
                PortraitButtons()
            }
            .padding(Distance.default)
        }
        
        @ViewBuilder
        private func SelectionModeViews() -> some SwiftUI.View {
            Text(Strings.TimerDetail.selectMode.uppercased())
                .fontBodyMedium()
                .textColor(.Supla.gray)
            SuplaCore.SegmentedPicker(
                selected: selectedMode,
                items: availableModes
            )
            .onChange(of: selectedMode.wrappedValue) { newValue in delegate?.onDeviceModeChange(newValue) }
            
            if (selectedMode.wrappedValue != .off) {
                VStack(alignment: .leading, spacing: Distance.tiny) {
                    HStack(alignment: .center) {
                        Text(Strings.TimerDetail.minTemp.uppercased())
                            .fontBodySmall()
                            .textColor(.Supla.gray)
                        Spacer()
                        Text(setpointValue)
                            .fontLabelMedium()
                        Spacer()
                        Text(Strings.TimerDetail.maxTemp.uppercased())
                            .fontBodySmall()
                            .textColor(.Supla.gray)
                    }
                    HStack(alignment: .center) {
                        CorrectionButton(.Icons.minus) { delegate?.onSetpointChange(.smallDown) }
                            .disabled(minusDisabled)
                        switch (selectedMode.wrappedValue) {
                        case .off: EmptyView()
                        case .auto:
                            SuplaCore.RangeSlider(
                                lower: heatingValue,
                                upper: coolingValue,
                                thumbSize: SuplaCore.HeatingThumb.size,
                                lowerThumb: { SuplaCore.HeatingThumb() },
                                upperThumb: { SuplaCore.CoolingThumb() }
                            )
                            .onChange(of: heatingValue.wrappedValue) { delegate?.onHeatValueChange($0) }
                            .onChange(of: coolingValue.wrappedValue) { delegate?.onCoolValueChange($0) }
                        case .heating:
                            SuplaCore.Slider(
                                value: heatingValue,
                                thumbSize: SuplaCore.HeatingThumb.size,
                                thumb: { SuplaCore.HeatingThumb() }
                            )
                            .onChange(of: heatingValue.wrappedValue) { delegate?.onHeatValueChange($0) }
                        case .cooling:
                            SuplaCore.Slider(
                                value: coolingValue,
                                thumbSize: SuplaCore.CoolingThumb.size,
                                thumb: { SuplaCore.CoolingThumb() }
                            )
                            .onChange(of: coolingValue.wrappedValue) { delegate?.onCoolValueChange($0) }
                        }
                        CorrectionButton(.Icons.plus) { delegate?.onSetpointChange(.smallUp) }
                            .disabled(plusDisabled)
                    }
                }.padding(.top, Distance.small)
            }
        }
        
        @ViewBuilder
        private func CorrectionButton(_ icon: String, action: @escaping () -> Void) -> some SwiftUI.View {
            IconButton(
                name: icon,
                action: action
            )
            .borderedButtonStyle(colors: .based(on: setpointInChange.color), radius: Dimens.iconSize)
        }
        
        private func SelectionModeButton() -> some SwiftUI.View {
            Button(action: { delegate?.onTimeSelectionModeChange(timeSelectionMode.alternative) }) {
                HStack {
                    Image(timeSelectionMode.alternative.icon)
                        .renderingMode(.template)
                        .foregroundColor(.Supla.primary)
                    Text(timeSelectionMode.alternative.label)
                        .fontBodyMedium()
                        .textColor(.Supla.onBackground)
                }
            }
        }
        
        @ViewBuilder
        private func TimeSelectionViews() -> some SwiftUI.View {
            HStack {
                Text(Strings.TimerDetail.selectTime.uppercased())
                    .fontBodyMedium()
                    .textColor(.Supla.gray)
                Spacer()
                SelectionModeButton()
            }
            switch (timeSelectionMode) {
            case .timer: TimePicker()
            case .calendar: DatePicker()
            }
            
            ThermostatInfoText()
        }
        
        private func TimePicker() -> some SwiftUI.View {
            HStack(spacing: 0) {
                SuplaCore.WheelPicker(selected: timerDays, items: Array(0...360).map { $0.asDayPickerItem })
                SuplaCore.WheelPicker(selected: timerHours, items: Array(0...23).map { $0.asHourPickerItem })
                SuplaCore.WheelPicker(selected: timerMinutes, items: Array(0...59).map { $0.asMinutePickerItem })
            }
            .frame(height: 140)
        }
        
        private func DatePicker() -> some SwiftUI.View {
            SwiftUI.DatePicker("", selection: calendarDate)
                .datePickerStyle(.graphical)
                .tint(.Supla.primary)
        }
        
        private func ThermostatInfoText() -> some SwiftUI.View {
            Text(infoText)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .fontBodyMedium()
                .textColor(.Supla.gray)
                .padding(.top, Distance.small)
        }
        
        @ViewBuilder
        private func PortraitButtons() -> some SwiftUI.View {
            if (edit) {
                TitleButton(
                    title: Strings.General.cancel,
                    fullWidth: true,
                    action: { delegate?.onCancelEditMode() }
                )
                .borderedButtonStyle()
            }
            TitleButton(
                title: edit ? Strings.General.save : Strings.General.start,
                fullWidth: true,
                action: { delegate?.onStart() }
            )
            .filledButtonStyle()
            .disabled(startDisabled)
        }
        
        @ViewBuilder
        private func LandscapeButtons() -> some SwiftUI.View {
            HStack(spacing: Distance.small) {
                PortraitButtons()
            }
        }
    }
}

private extension ThermostatTimerDetailFeature.DeviceMode {
    var setpointType: SetpointType {
        switch (self) {
        case .off: .heat
        case .auto, .heating: .heat
        case .cooling: .cool
        }
    }
}

#Preview("Time") {
    BackgroundStack(alignment: .top) {
        ThermostatTimerDetailFeature.ConfigurationView(
            selectedMode: .constant(.heating),
            availableModes: [.off, .heating],
            timeSelectionMode: .timer,
            infoText: "Thermostat will stay turned off for 3 hours",
            edit: false,
            startDisabled: false,
            minusDisabled: false,
            plusDisabled: false,
            setpointInChange: .heat,
            setpointValue: "22.0",
            heatingValue: .constant(0.3),
            coolingValue: .constant(0),
            timerDays: .constant(0.asDayPickerItem),
            timerHours: .constant(3.asHourPickerItem),
            timerMinutes: .constant(0.asMinutePickerItem),
            calendarDate: .constant(Date()),
            delegate: nil
        )
    }
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("Time (Landscape)", traits: .landscapeRight) {
    BackgroundStack(alignment: .top) {
        ThermostatTimerDetailFeature.ConfigurationView(
            selectedMode: .constant(.cooling),
            availableModes: [.off, .cooling],
            timeSelectionMode: .timer,
            infoText: "Thermostat will stay turned off for 3 hours",
            edit: false,
            startDisabled: false,
            minusDisabled: false,
            plusDisabled: false,
            setpointInChange: .cool,
            setpointValue: "22.0",
            heatingValue: .constant(0.3),
            coolingValue: .constant(0),
            timerDays: .constant(0.asDayPickerItem),
            timerHours: .constant(3.asHourPickerItem),
            timerMinutes: .constant(0.asMinutePickerItem),
            calendarDate: .constant(Date()),
            delegate: nil
        )
        .safeAreaPadding()
    }
}
#endif // swift(>=5.9)

#Preview("Date") {
    BackgroundStack(alignment: .top) {
        ThermostatTimerDetailFeature.ConfigurationView(
            selectedMode: .constant(.heating),
            availableModes: [.off, .heating],
            timeSelectionMode: .calendar,
            infoText: "Thermostat will stay turned off for 3 hours",
            edit: true,
            startDisabled: true,
            minusDisabled: false,
            plusDisabled: false,
            setpointInChange: .heat,
            setpointValue: "22.0",
            heatingValue: .constant(0.3),
            coolingValue: .constant(0),
            timerDays: .constant(0.asDayPickerItem),
            timerHours: .constant(3.asHourPickerItem),
            timerMinutes: .constant(0.asMinutePickerItem),
            calendarDate: .constant(Date()),
            delegate: nil
        )
    }
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("Date (Landscape)", traits: .landscapeRight) {
    BackgroundStack(alignment: .top) {
        ThermostatTimerDetailFeature.ConfigurationView(
            selectedMode: .constant(.cooling),
            availableModes: [.off, .cooling],
            timeSelectionMode: .calendar,
            infoText: "Thermostat will stay turned off for 3 hours",
            edit: true,
            startDisabled: true,
            minusDisabled: false,
            plusDisabled: false,
            setpointInChange: .cool,
            setpointValue: "22.0",
            heatingValue: .constant(0.3),
            coolingValue: .constant(0),
            timerDays: .constant(0.asDayPickerItem),
            timerHours: .constant(3.asHourPickerItem),
            timerMinutes: .constant(0.asMinutePickerItem),
            calendarDate: .constant(Date()),
            delegate: nil
        )
        .safeAreaPadding()
    }
}
#endif // swift(>=5.9)
