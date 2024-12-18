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
    
enum SuplaElectricityMeasurementType: Identifiable, Codable, CaseIterable, PickerItem {
    case frequency
    case voltage
    case current
    case powerActive
    case powerReactive
    case powerApparent
    case powerFactor
    case phaseAngle
    case forwardActiveEnergy
    case reverseActiveEnergy
    case forwardReactiveEnergy
    case reverseReactiveEnergy
    case currentOver65a
    case forwardActiveEnergyBanalced
    case reverseActiveEnergyBalanced
    case voltagePhaseAngle12
    case voltagePhaseAngle13
    case voltagePhaseSequence
    case currentPhaseSequence
    case powerActiveKw
    case powerReactiveKvar
    case powerApparentKva
    
    var id: Int32 { self.value }
    var label: String { self.string }
    
    var value: Int32 {
        switch (self) {
        case .frequency: EM_VAR_FREQ
        case .voltage: EM_VAR_VOLTAGE
        case .current: EM_VAR_CURRENT
        case .powerActive: EM_VAR_POWER_ACTIVE
        case .powerReactive: EM_VAR_POWER_REACTIVE
        case .powerApparent: EM_VAR_POWER_APPARENT
        case .powerFactor: EM_VAR_POWER_FACTOR
        case .phaseAngle: EM_VAR_PHASE_ANGLE
        case .forwardActiveEnergy: EM_VAR_FORWARD_ACTIVE_ENERGY
        case .reverseActiveEnergy: EM_VAR_REVERSE_ACTIVE_ENERGY
        case .forwardReactiveEnergy: EM_VAR_FORWARD_REACTIVE_ENERGY
        case .reverseReactiveEnergy: EM_VAR_REVERSE_REACTIVE_ENERGY
        case .currentOver65a: EM_VAR_CURRENT_OVER_65A
        case .forwardActiveEnergyBanalced: EM_VAR_FORWARD_ACTIVE_ENERGY_BALANCED
        case .reverseActiveEnergyBalanced: EM_VAR_REVERSE_ACTIVE_ENERGY_BALANCED
        case .voltagePhaseAngle12: EM_VAR_VOLTAGE_PHASE_ANGLE_12
        case .voltagePhaseAngle13: EM_VAR_VOLTAGE_PHASE_ANGLE_13
        case .voltagePhaseSequence: EM_VAR_VOLTAGE_PHASE_SEQUENCE
        case .currentPhaseSequence: EM_VAR_CURRENT_PHASE_SEQUENCE
        case .powerActiveKw: EM_VAR_POWER_ACTIVE_KW
        case .powerReactiveKvar: EM_VAR_POWER_REACTIVE_KVAR
        case .powerApparentKva: EM_VAR_POWER_APPARENT_KVA
        }
    }
    
    var string: String {
        switch self {
        case .frequency: Strings.ElectricityMeter.frequency
        case .voltage: Strings.ElectricityMeter.voltage
        case .current: Strings.ElectricityMeter.current
        case .powerActive: Strings.ElectricityMeter.powerActive
        case .powerReactive: Strings.ElectricityMeter.powerReactive
        case .powerApparent: Strings.ElectricityMeter.powerApparent
        case .powerFactor: Strings.ElectricityMeter.powerFactor
        case .phaseAngle: Strings.ElectricityMeter.phaseAngle
        case .forwardActiveEnergy: Strings.ElectricityMeter.forwardActiveEnergy
        case .reverseActiveEnergy: Strings.ElectricityMeter.reverseActiveEnergy
        case .forwardReactiveEnergy: Strings.ElectricityMeter.forwardReactiveEnergy
        case .reverseReactiveEnergy: Strings.ElectricityMeter.reverseReactiveEnergy
        case .currentOver65a: Strings.ElectricityMeter.current
        case .forwardActiveEnergyBanalced: Strings.ElectricityMeter.forwardActiveEnergy
        case .reverseActiveEnergyBalanced: Strings.ElectricityMeter.reverseActiveEnergy
        case .voltagePhaseAngle12: Strings.ElectricityMeter.voltagePhaseAngle12
        case .voltagePhaseAngle13: Strings.ElectricityMeter.voltagePhaseAngle13
        case .voltagePhaseSequence: Strings.ElectricityMeter.voltagePhaseSequence
        case .currentPhaseSequence: Strings.ElectricityMeter.currentPhaseSequence
        case .powerActiveKw: Strings.ElectricityMeter.powerActive
        case .powerReactiveKvar: Strings.ElectricityMeter.powerReactive
        case .powerApparentKva: Strings.ElectricityMeter.powerApparent
        }
    }
    
    var shortString: String {
        switch self {
        case .frequency: Strings.ElectricityMeter.frequency
        case .voltage: Strings.ElectricityMeter.voltage
        case .current: Strings.ElectricityMeter.current
        case .powerActive: Strings.ElectricityMeter.powerActive
        case .powerReactive: Strings.ElectricityMeter.powerReactive
        case .powerApparent: Strings.ElectricityMeter.powerApparent
        case .powerFactor: Strings.ElectricityMeter.powerFactor
        case .phaseAngle: Strings.ElectricityMeter.phaseAngle
        case .forwardActiveEnergy: Strings.ElectricityMeter.forwardActiveEnergyShort
        case .reverseActiveEnergy: Strings.ElectricityMeter.reverseActiveEnergyShort
        case .forwardReactiveEnergy: Strings.ElectricityMeter.forwardReactiveEnergyShort
        case .reverseReactiveEnergy: Strings.ElectricityMeter.reverseReactiveEnergyShort
        case .currentOver65a: Strings.ElectricityMeter.current
        case .forwardActiveEnergyBanalced: Strings.ElectricityMeter.forwardActiveEnergyShort
        case .reverseActiveEnergyBalanced: Strings.ElectricityMeter.reverseActiveEnergyShort
        case .voltagePhaseAngle12: Strings.ElectricityMeter.voltagePhaseAngle12
        case .voltagePhaseAngle13: Strings.ElectricityMeter.voltagePhaseAngle13
        case .voltagePhaseSequence: Strings.ElectricityMeter.voltagePhaseSequence
        case .currentPhaseSequence: Strings.ElectricityMeter.currentPhaseSequence
        case .powerActiveKw: Strings.ElectricityMeter.powerActive
        case .powerReactiveKvar: Strings.ElectricityMeter.powerReactive
        case .powerApparentKva: Strings.ElectricityMeter.powerApparent
        }
    }
    
    var unit: String {
        switch self {
        case .frequency: "Hz"
        case .voltage: "V"
        case .current, .currentOver65a: "A"
        case .powerActive, .powerActiveKw: "W"
        case .powerReactive, .powerReactiveKvar: "var"
        case .powerApparent, .powerApparentKva: "VA"
        case .powerFactor, .voltagePhaseSequence, .currentPhaseSequence: " "
        case .phaseAngle, .voltagePhaseAngle12, .voltagePhaseAngle13: "°"
        case .forwardActiveEnergy, .reverseActiveEnergy, .forwardActiveEnergyBanalced, .reverseActiveEnergyBalanced: "kWh"
        case .forwardReactiveEnergy, .reverseReactiveEnergy: "kvarh"
        }
    }
    
    var ordering: Int {
        switch self {
        case .frequency: 1
        case .voltage: 2
        case .current, .currentOver65a: 3
        case .powerActive, .powerActiveKw: 4
        case .powerReactive, .powerReactiveKvar: 5
        case .powerApparent, .powerApparentKva: 6
        case .powerFactor: 7
        case .phaseAngle: 8
        case .forwardActiveEnergy: 9
        case .reverseActiveEnergy: 10
        case .forwardReactiveEnergy: 11
        case .reverseReactiveEnergy: 12
        case .forwardActiveEnergyBanalced: 13
        case .reverseActiveEnergyBalanced: 14
        case .voltagePhaseAngle12: 2
        case .voltagePhaseAngle13: 3
        case .voltagePhaseSequence: 4
        case .currentPhaseSequence: 5
        }
    }
    
    var phaseType: Bool {
        switch self {
        case .voltage,
             .current,
             .powerActive,
             .powerReactive,
             .powerApparent,
             .powerFactor,
             .phaseAngle,
             .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy,
             .currentOver65a,
             .powerActiveKw,
             .powerReactiveKvar,
             .powerApparentKva: true
        case .frequency,
             .forwardActiveEnergyBanalced,
             .reverseActiveEnergyBalanced,
             .voltagePhaseAngle12,
             .voltagePhaseAngle13,
             .voltagePhaseSequence,
             .currentPhaseSequence: false
        }
    }
    
    var provider: ((SAElectricityMeterExtendedValue, Phase) -> Double?)? {
        switch (self) {
        case .frequency: { value, phase in value.freq(forPhase: phase.rawValue) }
        case .voltage: { value, phase in value.voltege(forPhase: phase.rawValue) }
        case .current: { value, phase in value.current(forPhase: phase.rawValue) }
        case .currentOver65a: { value, phase in value.current(forPhase: phase.rawValue) }
        case .powerActive: { value, phase in value.powerActive(forPhase: phase.rawValue) }
        case .powerActiveKw: { value, phase in value.powerActive(forPhase: phase.rawValue) * 1000 }
        case .powerReactive: { value, phase in value.powerReactive(forPhase: phase.rawValue) }
        case .powerReactiveKvar: { value, phase in value.powerReactive(forPhase: phase.rawValue) * 1000 }
        case .powerApparent: { value, phase in value.powerApparent(forPhase: phase.rawValue) }
        case .powerApparentKva: { value, phase in value.powerApparent(forPhase: phase.rawValue) * 1000 }
        case .powerFactor: { value, phase in value.powerFactor(forPhase: phase.rawValue) }
        case .phaseAngle: { value, phase in value.phaseAngle(forPhase: phase.rawValue) }
        case .forwardActiveEnergy: { value, phase in value.totalForwardActiveEnergy(forPhase: phase.rawValue) }
        case .reverseActiveEnergy: { value, phase in value.totalReverseActiveEnergy(forPhase: phase.rawValue) }
        case .forwardReactiveEnergy: { value, phase in value.totalForwardReactiveEnergy(forPhase: phase.rawValue) }
        case .reverseReactiveEnergy: { value, phase in value.totalReverseReactiveEnergy(forPhase: phase.rawValue) }
        default: nil
        }
    }
    
    var precision: Int {
        switch (self) {
        case .frequency,
             .voltagePhaseSequence,
             .currentPhaseSequence,
             .voltage,
             .current,
             .powerActive,
             .powerReactive,
             .powerApparent,
             .phaseAngle: 2
        case .powerFactor: 3
        case .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy: 5
        case .voltagePhaseAngle12,
             .voltagePhaseAngle13: 1
        default: 0
        }
    }
    
    func merge(_ values: [Double]) -> Value? {
        switch (self) {
        case .frequency: .single(value: values.first!)
        case .voltage: .double(first: values.min()!, second: values.max()!)
        case .powerActive,
             .powerActiveKw,
             .powerReactive,
             .powerReactiveKvar,
             .powerApparent,
             .powerApparentKva,
             .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy: .single(value: values.sumOrNan())
        default: nil
        }
    }
    
    var showEnergyLabel: Bool {
        switch (self) {
        case .forwardActiveEnergy,
             .reverseActiveEnergy,
             .forwardReactiveEnergy,
             .reverseReactiveEnergy: true
        default: false
        }
    }
        
    static func from(_ value: Int32) -> [SuplaElectricityMeasurementType] {
        var result: [SuplaElectricityMeasurementType] = []
        
        for type in SuplaElectricityMeasurementType.allCases {
            if (value & type.value > 0) {
                result.append(type)
            }
        }
        
        if (result.contains(.current) && result.contains(.currentOver65a)) {
            result = result.filter { $0 != .currentOver65a }
        }
        
        if (result.contains(.powerReactive) && result.contains(.powerReactiveKvar)) {
            result = result.filter { $0 != .powerReactive }
        }
        
        if (result.contains(.powerApparent) && result.contains(.powerApparentKva)) {
            result = result.filter { $0 != .powerApparent }
        }
        
        return result
    }
    
    enum Value {
        case single(value: Double)
        case double(first: Double, second: Double)
    }
}

extension SAElectricityMeterExtendedValue {
    var suplaElectricityMeterMeasuredTypes: [SuplaElectricityMeasurementType] {
        SuplaElectricityMeasurementType.from(Int32(measuredValues()))
    }
}

extension Array where Element == SuplaElectricityMeasurementType {
    var hasForwardAndReverseEnergy: Bool {
        contains(.forwardActiveEnergyBanalced) && contains(.reverseActiveEnergyBalanced)
    }

    var hasBalance: Bool {
        contains(.forwardActiveEnergyBanalced) && contains(.reverseActiveEnergyBalanced)
    }
}
