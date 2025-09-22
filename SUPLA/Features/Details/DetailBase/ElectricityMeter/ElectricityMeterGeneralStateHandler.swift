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
    
protocol ElectricityMeterGeneralStateHandler {
    func updateState(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?)
}

extension ElectricityMeterGeneralStateHandler {
    func updateState(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren) {
        updateState(state, channel, nil)
    }
}

final class ElectricityMeterGeneralStateHandlerImpl: ElectricityMeterGeneralStateHandler {
    @Singleton private var getChannelValueUseCase: GetChannelValueUseCase
    @Singleton private var settings: GlobalSettings
    
    private let defaultFormatter = SharedCore.DefaultValueFormatter.shared
    private let emFormatter = SharedCore.ElectricityMeterValueFormatter(defaultFormatSpecification: ValueFormatSpecification.companion.ElectricityMeterForGeneral)
    
    func updateState(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?) {
        if (!channel.channel.isElectricityMeter() && !channel.isOrHasElectricityMeter) {
            return
        }
        
        guard let extendedValue = channel.channel.ev?.electricityMeter() else {
            handleNoExtendedValue(state, channel, measurements)
            return
        }
        
        let allTypes = extendedValue.suplaElectricityMeterMeasuredTypes.sorted(by: { $0.ordering < $1.ordering })
        let phaseTypes = allTypes.filter { $0.phaseType }
        let moreThanOnePhase = Phase.allCases
            .filter { channel.channel.flags & $0.disabledFlag == 0 }
            .count > 1
        
        state.online = channel.channel.status().online
        state.totalForwardActiveEnergy = extendedValue.getForwardEnergy(formatter: emFormatter)
        state.totalReverseActiveEnergy = extendedValue.getReverseEnergy(formatter: emFormatter)
        state.currentMonthForwardActiveEnergy = measurements?.toForwardEnergy(formatter: emFormatter, value: extendedValue)
        state.currentMonthReverseActiveEnergy = measurements?.toReverseEnergy(formatter: emFormatter, value: extendedValue)
        state.phaseMeasurementTypes = phaseTypes
        state.phaseMeasurementValues = getPhaseData(phaseTypes, channel.channel.flags, extendedValue, defaultFormatter)
        state.vectorBalancedValues = vectorBalancedValues(moreThanOnePhase, extendedValue, allTypes)
        state.electricGridParameters = getGridParameters(channel.channel.flags, extendedValue)
        state.showIntroduction = settings.showEmGeneralIntroduction && channel.channel.status().online && moreThanOnePhase
    }
    
    private func handleNoExtendedValue(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?) {
        let value: Double = getChannelValueUseCase.invoke(channel.channel)
        
        state.online = channel.channel.status().online
        state.totalForwardActiveEnergy = SummaryCardData(energy: emFormatter.format(value: value))
        state.totalReverseActiveEnergy = nil
        state.currentMonthForwardActiveEnergy = measurements?.toForwardEnergy(formatter: emFormatter)
        state.currentMonthReverseActiveEnergy = measurements?.toReverseEnergy(formatter: emFormatter)
        state.phaseMeasurementTypes = []
        state.phaseMeasurementValues = []
        state.vectorBalancedValues = nil
    }
    
    private func getPhaseData(
        _ types: [SuplaElectricityMeasurementType],
        _ channelFlags: Int64,
        _ extendedValue: SAElectricityMeterExtendedValue,
        _ formatter: SharedCore.ValueFormatter
    ) -> [PhaseWithMeasurements] {
        // Collect data for each phase
        let phasesWithData: [(Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value])] = Phase.allCases
            .filter { channelFlags & $0.disabledFlag == 0 }
            .map { (Int($0.rawValue), $0.label, extendedValue.measuredValues(types, $0)) }
        
        // Extract summary for all three phases if available
        var result: [PhaseWithMeasurements] = []
        if phasesWithData.count == 3 {
            let allPhasesData = extractAllPhasesData(phasesWithData)
            let allPhasesMeasurements = allPhasesData.2.toMeasurementTypeValue(formatter).sorted(by: { $0.type.ordering < $1.type.ordering })
            
            result.append(PhaseWithMeasurements(id: allPhasesData.0, phase: allPhasesData.1, values: allPhasesMeasurements))
        }
        
        // Extract each single phase
        phasesWithData.forEach {
            let measurements = $2
                .map { ElectricityMeterGeneralState.MeaurementTypeValue(type: $0.key, value: format(formatter, $0.value, $0.key.precision)) }
                .sorted(by: { $0.type.ordering < $1.type.ordering })
            
            result.append(PhaseWithMeasurements(id: $0, phase: $1, values: measurements))
        }
        
        return result.sorted(by: { $0.id < $1.id })
    }
    
    private func extractAllPhasesData(
        _ phasesWithData: [(Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value])]
    ) -> (Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value?]) {
        var allValues: [SuplaElectricityMeasurementType: [Double]] = [:]
        
        phasesWithData.map { $2 }
            .forEach { phaseValues in
                for phaseValue in phaseValues {
                    let value: Double = switch (phaseValue.value) {
                    case .single(let value): value
                    default: 0
                    }
                    
                    if allValues[phaseValue.key] != nil {
                        allValues[phaseValue.key]?.append(value)
                    } else {
                        allValues[phaseValue.key] = [value]
                    }
                }
            }
        
        let phasesValues = allValues.map { mergeForAllPhases($0.key, $0.value) }
            .compactMap { $0 }
        
        return (0, Strings.ElectricityMeter.allPhases, Dictionary(uniqueKeysWithValues: phasesValues))
    }
    
    private func mergeForAllPhases(
        _ type: SuplaElectricityMeasurementType,
        _ values: [Double]
    ) -> (SuplaElectricityMeasurementType, SuplaElectricityMeasurementType.Value?) {
        if let mergedValue = type.merge(values) {
            (type, mergedValue)
        } else {
            (type, nil)
        }
    }
    
    private func vectorBalancedValues(
        _ moreThanOnePhase: Bool,
        _ value: SAElectricityMeterExtendedValue,
        _ types: [SuplaElectricityMeasurementType]
    ) -> [ElectricityMeterGeneralState.MeaurementTypeValue]? {
        if (moreThanOnePhase && types.hasForwardAndReverseEnergy) {
            return [
                .init(
                    type: .forwardActiveEnergyBanalced,
                    value: defaultFormatter.format(value: value.totalForwardActiveEnergyBalanced())
                ),
                .init(
                    type: .reverseActiveEnergyBalanced,
                    value: defaultFormatter.format(value: value.totalReverseActiveEnergyBalanced())
                )
            ]
        }
        
        return nil
    }
    
    private func getGridParameters(
        _ channelFlags: Int64,
        _ value: SAElectricityMeterExtendedValue
    ) -> [ElectricityMeterGeneralState.MeaurementTypeValue]? {
        let measuredValues = value.suplaElectricityMeterMeasuredTypes
        var result: [ElectricityMeterGeneralState.MeaurementTypeValue] = []
        
        if (measuredValues.contains(.frequency)) {
            if let phase = Phase.allCases.first(where: { channelFlags & $0.disabledFlag == 0 }) {
                result.append(.init(
                    type: .frequency,
                    value: defaultFormatter.custom(value.freq(forPhase: phase.rawValue), SuplaElectricityMeasurementType.frequency.precision)
                ))
            }
        }
        if (measuredValues.contains(.voltagePhaseAngle12)) {
            result.append(.init(
                type: .voltagePhaseAngle12,
                value: defaultFormatter.custom(value.voltagePhaseAngle12(), SuplaElectricityMeasurementType.voltagePhaseAngle12.precision)
            ))
        }
        if (measuredValues.contains(.voltagePhaseAngle13)) {
            result.append(.init(
                type: .voltagePhaseAngle13,
                value: defaultFormatter.custom(value.voltagePhaseAngle13(), SuplaElectricityMeasurementType.voltagePhaseAngle13.precision)
            ))
        }
        if (measuredValues.contains(.voltagePhaseSequence)) {
            result.append(.init(
                type: .voltagePhaseSequence,
                value: value.voltagePhaseSequence.text
            ))
        }
        if (measuredValues.contains(.currentPhaseSequence)) {
            result.append(.init(
                type: .currentPhaseSequence,
                value: value.currentPhaseSequence.text
            ))
        }
        
        return result.count > 0 ? result : nil
    }
}

private extension Dictionary where Key == SuplaElectricityMeasurementType, Value == SuplaElectricityMeasurementType.Value? {
    func toMeasurementTypeValue(_ formatter: SharedCore.ValueFormatter) -> [ElectricityMeterGeneralState.MeaurementTypeValue] {
        map {
            if let value = $0.value {
                ElectricityMeterGeneralState.MeaurementTypeValue(type: $0.key, value: format(formatter, value, $0.key.precision))
            } else {
                ElectricityMeterGeneralState.MeaurementTypeValue(type: $0.key, value: nil)
            }
        }
    }
}

private func format(
    _ formatter: SharedCore.ValueFormatter,
    _ value: SuplaElectricityMeasurementType.Value,
    _ precision: Int
) -> String {
    switch (value) {
    case .single(let value):
        return formatter.custom(value, precision)
    case .double(let first, let second):
        let firstFormatted = formatter.custom(first, 0)
        let secondFormatted = formatter.custom(second, 0)
        return "\(firstFormatted) - \(secondFormatted)"
    }
}

private extension SharedCore.ValueFormatter {
    func custom(_ value: Double, _ precision: Int) -> String {
        format(value: value, format: ValueFormatKt.customPrecision(precision: Int32(precision)))
    }
}
