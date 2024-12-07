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
    
    private let formatter = ListElectricityMeterValueFormatter(useNoValue: false)
    
    func updateState(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?) {
        if (!channel.channel.isElectricityMeter() && !channel.hasElectricityMeter) {
            return
        }
        
        guard let extendedValue = channel.channel.ev?.electricityMeter() else {
            handleNoExtendedValue(state, channel, measurements)
            return
        }
        
        let allTypes = extendedValue.suplaElectricityMeterMeasuredTypes.sorted(by: { $0.ordering < $1.ordering })
        let phaseTypes = allTypes.filter { $0.phaseType }
        
        state.online = channel.channel.isOnline()
        state.totalForwardActiveEnergy = extendedValue.getForwardEnergy(formatter: formatter)
        state.totalReverseActiveEnergy = extendedValue.getReverseEnergy(formatter: formatter)
        state.currentMonthForwardActiveEnergy = measurements?.toForwardEnergy(formatter: formatter, value: extendedValue)
        state.currentMonthReverseActiveEnergy = measurements?.toReverseEnergy(formatter: formatter, value: extendedValue)
        state.phaseMeasurementTypes = phaseTypes
        state.phaseMeasurementValues = getPhaseData(phaseTypes, channel.channel.flags, extendedValue, formatter)
        state.vectorBalancedValues = vectorBalancedValues(channel.channel, extendedValue, allTypes)
    }
    
    private func handleNoExtendedValue(_ state: ElectricityMeterGeneralState, _ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?) {
        let value: Double = getChannelValueUseCase.invoke(channel.channel)
        
        state.online = channel.channel.isOnline()
        state.totalForwardActiveEnergy = EnergyData(energy: formatter.format(value))
        state.totalReverseActiveEnergy = nil
        state.currentMonthForwardActiveEnergy = measurements?.toForwardEnergy(formatter: formatter)
        state.currentMonthReverseActiveEnergy = measurements?.toReverseEnergy(formatter: formatter)
        state.phaseMeasurementTypes = []
        state.phaseMeasurementValues = []
        state.vectorBalancedValues = nil
    }
    
    private func getPhaseData(
        _ types: [SuplaElectricityMeasurementType],
        _ channelFlags: Int64,
        _ extendedValue: SAElectricityMeterExtendedValue,
        _ formatter: ListElectricityMeterValueFormatter
    ) -> [PhaseWithMeasurements] {
        var phasesWithData: [(Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value])] = Phase.allCases
            .filter { channelFlags & $0.disabledFlag == 0 }
            .map { (Int($0.rawValue), $0.label, extendedValue.measuredValues(types, $0)) }
        
        if phasesWithData.count == 3 {
            phasesWithData.append(extractAllPhasesData(phasesWithData))
        }
        
        return phasesWithData
            .map {
                let measurements = $2.map {
                    ($0.key, format(formatter, $0.value, $0.key.precision))
                }
                return PhaseWithMeasurements(id: $0, phase: $1, values: Dictionary(uniqueKeysWithValues: measurements))
            }
            .sorted(by: { $0.id < $1.id })
    }
    
    private func format(
        _ formatter: ListElectricityMeterValueFormatter,
        _ value: SuplaElectricityMeasurementType.Value,
        _ precision: Int
    ) -> String {
        let precision: ChannelValuePrecision = .customPrecision(value: precision)
        
        switch (value) {
        case .single(let value):
            return formatter.format(value, withUnit: false, precision: precision)
        case .double(let first, let second):
            let firstFormatted = formatter.format(first, withUnit: false, precision: .customPrecision(value: 0))
            let secondFormatted = formatter.format(second, withUnit: false, precision: .customPrecision(value: 0))
            return "\(firstFormatted) - \(secondFormatted)"
        }
    }
    
    private func extractAllPhasesData(
        _ phasesWithData: [(Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value])]
    ) -> (Int, String, [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value]) {
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
    ) -> (SuplaElectricityMeasurementType, SuplaElectricityMeasurementType.Value)? {
        if let mergedValue = type.merge(values) {
            (type, mergedValue)
        } else {
            nil
        }
    }
    
    private func vectorBalancedValues(
        _ channel: SAChannel,
        _ value: SAElectricityMeterExtendedValue,
        _ types: [SuplaElectricityMeasurementType]
    ) -> [SuplaElectricityMeasurementType: String]? {
        let moreThanOnePhase = Phase.allCases
            .filter { channel.flags & $0.disabledFlag == 0 }
            .count > 1
        
        if (moreThanOnePhase && types.hasForwardAndReverseEnergy) {
            return [
                .forwardActiveEnergyBanalced: formatter.format(value.totalForwardActiveEnergyBalanced(), withUnit: false),
                .reverseActiveEnergyBalanced: formatter.format(value.totalReverseActiveEnergyBalanced(), withUnit: false)
            ]
        }
        
        return nil
    }
}
