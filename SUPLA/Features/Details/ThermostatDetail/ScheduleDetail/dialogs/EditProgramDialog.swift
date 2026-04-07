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
    enum ThermostatType {
        case heat
        case cool
        
        var label: String {
            switch self {
            case .heat: Strings.ThermostatDetail.heatingTemperature
            case .cool: Strings.ThermostatDetail.coolingTemperature
            }
        }
    }
    
    struct EditProgramState: Equatable {
        let program: SuplaScheduleProgram
        let thermostatType: ThermostatType
        let temperatureUnit: TemperatureUnit
        let plusDisabled: Bool
        let minusDisabled: Bool
        let saveDisabled: Bool
        
        let initialValue: String
        let updateValue: String
        
        init(
            program: SuplaScheduleProgram,
            thermostatType: ThermostatType,
            temperatureUnit: TemperatureUnit,
            value: String,
            plusDisabled: Bool,
            minusDisabled: Bool,
            saveDisabled: Bool
        ) {
            self.program = program
            self.thermostatType = thermostatType
            self.temperatureUnit = temperatureUnit
            self.plusDisabled = plusDisabled
            self.minusDisabled = minusDisabled
            self.saveDisabled = saveDisabled
            self.initialValue = value
            self.updateValue = value
        }
        
        private init(
            program: SuplaScheduleProgram,
            thermostatType: ThermostatType,
            temperatureUnit: TemperatureUnit,
            plusDisabled: Bool,
            minusDisabled: Bool,
            saveDisabled: Bool,
            initialValue: String,
            updateValue: String
        ) {
            self.program = program
            self.thermostatType = thermostatType
            self.temperatureUnit = temperatureUnit
            self.plusDisabled = plusDisabled
            self.minusDisabled = minusDisabled
            self.saveDisabled = saveDisabled
            self.initialValue = initialValue
            self.updateValue = updateValue
        }
        
        func copy(
            program: SuplaScheduleProgram? = nil,
            thermostatType: ThermostatType? = nil,
            temperatureUnit: TemperatureUnit? = nil,
            updateValue: String? = nil,
            plusDisabled: Bool? = nil,
            minusDisabled: Bool? = nil,
            saveDisabled: Bool? = nil
        ) -> Self {
            EditProgramState(
                program: program ?? self.program,
                thermostatType: thermostatType ?? self.thermostatType,
                temperatureUnit: temperatureUnit ?? self.temperatureUnit,
                plusDisabled: plusDisabled ?? self.plusDisabled,
                minusDisabled: minusDisabled ?? self.minusDisabled,
                saveDisabled: saveDisabled ?? self.saveDisabled,
                initialValue: initialValue,
                updateValue: updateValue ?? self.updateValue
            )
        }
    }
    
    struct EditProgramDialog: SwiftUI.View {
        let state: EditProgramState
        
        let onDismiss: () -> Void
        let onChange: (String) -> Void
        let onPlus: (String) -> Void
        let onMinus: (String) -> Void
        let onSave: (String) -> Void
        
        init(
            state: EditProgramState,
            onDismiss: @escaping () -> Void,
            onChange: @escaping (String) -> Void,
            onPlus: @escaping (String) -> Void,
            onMinus: @escaping (String) -> Void,
            onSave: @escaping (String) -> Void
        ) {
            self.state = state
            self.onDismiss = onDismiss
            self.onChange = onChange
            self.onPlus = onPlus
            self.onMinus = onMinus
            self.onSave = onSave
            self._value = State(initialValue: state.initialValue)
        }
        
        @State private var value: String
        
        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: onDismiss, alignment: .leading, width: 300) {
                Header()
                Text(state.thermostatType.label)
                    .fontBodyLarge()
                    .textColor(.Supla.onSurfaceVariant)
                    .padding(.horizontal, Distance.default)
                TemperatureEdit()
                    .padding(.vertical, Distance.tiny)
                    .padding(.horizontal, Distance.default)
                
                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: onDismiss,
                    onPrimaryClick: { onSave(value) },
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
        
        private func TemperatureEdit() -> some SwiftUI.View {
            HStack(alignment: .center, spacing: Distance.tiny) {
                IconButton(
                    name: .Icons.minus,
                    color: .Supla.onPrimary,
                    action: { onMinus(value) }
                )
                .disabled(state.minusDisabled)
                .buttonStyle(FilledIconStyle())
                .clipShape(Circle())
                AccessoryTextField(
                    text: $value,
                    suffix: { AccessoryText(state.temperatureUnit.valueUnit.text) }
                )
                .onChange(of: value) {
                    onChange($0)
                }
                .onChange(of: state.updateValue) {
                    value = $0
                }
                .keyboardType(.decimalPad)
                .frame(width: 120)
                IconButton(
                    name: .Icons.plus,
                    color: .Supla.onPrimary,
                    action: { onPlus(value) }
                )
                .disabled(state.plusDisabled)
                .buttonStyle(FilledIconStyle())
                .clipShape(Circle())
                Spacer()
            }
        }
        
        private func filterInput(_ text: String) -> String {
            text.filter { $0.isNumber || $0 == "." || $0 == "," }
        }
    }
}

#Preview {
    BackgroundStack {
        ThermostatScheduleDetailFeature.EditProgramDialog(
            state: ThermostatScheduleDetailFeature.EditProgramState(
                program: .program1,
                thermostatType: .heat,
                temperatureUnit: .celsius,
                value: "22,0",
                plusDisabled: false,
                minusDisabled: false,
                saveDisabled: false
            ),
            onDismiss: {},
            onChange: { _ in },
            onPlus: { _ in },
            onMinus: { _ in },
            onSave: { _ in }
        )
    }
}
