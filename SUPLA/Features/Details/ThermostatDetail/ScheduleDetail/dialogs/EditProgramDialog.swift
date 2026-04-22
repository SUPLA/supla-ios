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

extension ThermostatScheduleDetailFeature {
    
    struct SetpointData: Equatable {
        let plusDisabled: Bool
        let minusDisabled: Bool
        let valueCorrect: Bool
        let initialValue: String
        let updateValue: String
        
        init(plusDisabled: Bool, minusDisabled: Bool, valueCorrect: Bool, initialValue: String, updateValue: String) {
            self.plusDisabled = plusDisabled
            self.minusDisabled = minusDisabled
            self.valueCorrect = valueCorrect
            self.initialValue = initialValue
            self.updateValue = updateValue
        }
        
        init(plusDisabled: Bool, minusDisabled: Bool, valueCorrect: Bool, value: String) {
            self.plusDisabled = plusDisabled
            self.minusDisabled = minusDisabled
            self.valueCorrect = valueCorrect
            self.initialValue = value
            self.updateValue = value
        }
        
        func copy(
            plusDisabled: Bool? = nil,
            minusDisabled: Bool? = nil,
            valueCorrect: Bool? = nil,
            initialValue: String? = nil,
            updateValue: String? = nil
        ) -> Self {
            SetpointData(
                plusDisabled: plusDisabled ?? self.plusDisabled,
                minusDisabled: minusDisabled ?? self.minusDisabled,
                valueCorrect: valueCorrect ?? self.valueCorrect,
                initialValue: initialValue ?? self.initialValue,
                updateValue: updateValue ?? self.updateValue
            )
        }
    }
    
    struct EditProgramState: Equatable {
        let program: SuplaScheduleProgram
        let temperatureUnit: TemperatureUnit
        let heatSetpoint: SetpointData?
        let coolSetpoint: SetpointData?
        
        var saveDisabled: Bool {
            if let heatSetpoint, let coolSetpoint {
                !heatSetpoint.valueCorrect || !coolSetpoint.valueCorrect
            } else if let heatSetpoint {
                !heatSetpoint.valueCorrect
            } else if let coolSetpoint {
                !coolSetpoint.valueCorrect
            } else {
                 true
            }
        }
        
        init(
            program: SuplaScheduleProgram,
            temperatureUnit: TemperatureUnit,
            heatSetpoint: SetpointData?,
            coolSetpoint: SetpointData?
        ) {
            self.program = program
            self.temperatureUnit = temperatureUnit
            self.heatSetpoint = heatSetpoint
            self.coolSetpoint = coolSetpoint
        }
        
        func copy(
            program: SuplaScheduleProgram? = nil,
            temperatureUnit: TemperatureUnit? = nil,
            heatSetpoint: SetpointData? = nil,
            coolSetpoint: SetpointData? = nil,
        ) -> Self {
            EditProgramState(
                program: program ?? self.program,
                temperatureUnit: temperatureUnit ?? self.temperatureUnit,
                heatSetpoint: heatSetpoint ?? self.heatSetpoint,
                coolSetpoint: coolSetpoint ?? self.coolSetpoint,
            )
        }
        
        func copy(
            setpointType: SetpointType,
            plusDisabled: Bool? = nil,
            minusDisabled: Bool? = nil,
            valueCorrect: Bool? = nil,
            updateValue: String? = nil
        ) -> Self {
            switch (setpointType) {
            case .heat:
                copy(
                    heatSetpoint: heatSetpoint?.copy(
                        plusDisabled: plusDisabled,
                        minusDisabled: minusDisabled,
                        valueCorrect: valueCorrect,
                        updateValue: updateValue
                    )
                )
            case .cool:
                copy(
                    coolSetpoint: coolSetpoint?.copy(
                        plusDisabled: plusDisabled,
                        minusDisabled: minusDisabled,
                        valueCorrect: valueCorrect,
                        updateValue: updateValue
                    )
                )
            }
        }
    }
    
    struct EditProgramDialog: SwiftUI.View {
        let state: EditProgramState
        
        let onDismiss: () -> Void
        let onChange: (SetpointType, String) -> Void
        let onPlus: (SetpointType, String) -> Void
        let onMinus: (SetpointType, String) -> Void
        let onSave: (String, String) -> Void
        
        init(
            state: EditProgramState,
            onDismiss: @escaping () -> Void,
            onChange: @escaping (SetpointType, String) -> Void,
            onPlus: @escaping (SetpointType, String) -> Void,
            onMinus: @escaping (SetpointType, String) -> Void,
            onSave: @escaping (String, String) -> Void
        ) {
            self.state = state
            self.onDismiss = onDismiss
            self.onChange = onChange
            self.onPlus = onPlus
            self.onMinus = onMinus
            self.onSave = onSave
            self._heatValue = State(initialValue: state.heatSetpoint?.initialValue ?? "")
            self._coolValue = State(initialValue: state.coolSetpoint?.initialValue ?? "")
        }
        
        @State private var heatValue: String
        @State private var coolValue: String
        
        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss, alignment: .leading, width: 300) {
                Header()
                
                if let heatSetpoint = state.heatSetpoint {
                    TemperatureEdit(type: .heat, heatSetpoint, $heatValue)
                        .padding(.horizontal, Distance.default)
                        .onChange(of: heatValue) { onChange(.heat, $0) }
                        .onChange(of: heatSetpoint.updateValue) { heatValue = $0 }
                }
                if let coolSetpoint = state.coolSetpoint {
                    TemperatureEdit(type: .cool, coolSetpoint, $coolValue)
                        .padding(.horizontal, Distance.default)
                        .onChange(of: coolValue) { onChange(.cool, $0) }
                        .onChange(of: coolSetpoint.updateValue) { coolValue = $0 }
                }
                
                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: onDismiss,
                    onPrimaryClick: { onSave(heatValue, coolValue) },
                    primaryDisabled: state.saveDisabled
                )
            }
        }
        
        private func Header() -> some SwiftUI.View {
            HStack(alignment: .center) {
                state.program.color
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                Text(Strings.ThermostatDetail.editProgramDialogHeader.arguments(state.program.rawValue))
                    .fontTitleLarge()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(Distance.default)
        }
        
        @ViewBuilder
        private func TemperatureEdit(type: SetpointType, _ setpointData: SetpointData, _ value: Binding<String>) -> some SwiftUI.View {
            Text(type.label)
                .fontBodyLarge()
                .textColor(.Supla.onSurfaceVariant)
            HStack(alignment: .center, spacing: Distance.tiny) {
                MinusButton(type, value.wrappedValue, setpointData.minusDisabled)
                AccessoryTextField(
                    text: value,
                    suffix: { AccessoryText(state.temperatureUnit.valueUnit.text) }
                )
                .keyboardType(.decimalPad)
                .frame(width: 120)
                PlusButton(type, value.wrappedValue, setpointData.plusDisabled)
            }
            .padding(.vertical, Distance.tiny)
        }
        
        private func MinusButton(_ type: SetpointType, _ value: String, _ disabled: Bool) -> some SwiftUI.View {
            IconButton(
                name: .Icons.minus,
                action: { onMinus(type, value) }
            )
            .filledButtonStyle()
            .disabled(disabled)
            .clipShape(Circle())
        }
        
        private func PlusButton(_ type: SetpointType, _ value: String, _ disabled: Bool) -> some SwiftUI.View {
            IconButton(
                name: .Icons.plus,
                action: { onPlus(type, value) }
            )
            .filledButtonStyle()
            .disabled(disabled)
            .clipShape(Circle())
        }
        
        private func filterInput(_ text: String) -> String {
            text.filter { $0.isNumber || $0 == "." || $0 == "," }
        }
    }
}

fileprivate extension SetpointType {
    var label: String {
        switch (self) {
        case .heat: Strings.ThermostatDetail.heatingTemperature
        case .cool: Strings.ThermostatDetail.coolingTemperature
        }
    }
}

#Preview {
    BackgroundStack {
        ThermostatScheduleDetailFeature.EditProgramDialog(
            state: ThermostatScheduleDetailFeature.EditProgramState(
                program: .program1,
                temperatureUnit: .celsius,
                heatSetpoint: ThermostatScheduleDetailFeature.SetpointData(
                    plusDisabled: false,
                    minusDisabled: false,
                    valueCorrect: true,
                    value: "22,0",
                ),
                coolSetpoint: ThermostatScheduleDetailFeature.SetpointData(
                    plusDisabled: false,
                    minusDisabled: false,
                    valueCorrect: true,
                    value: "23,0"
                )
            ),
            onDismiss: {},
            onChange: { _, _ in },
            onPlus: { _, _ in },
            onMinus: { _, _ in },
            onSave: { _, _ in }
        )
    }
}
