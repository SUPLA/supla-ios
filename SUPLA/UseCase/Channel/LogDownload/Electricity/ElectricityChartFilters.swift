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

struct ElectricityChartFilters: ChartDataSpec.Filters, Codable, Equatable {
    let type: ElectricityMeterChartType
    let availableTypes: [ElectricityMeterChartType]
    let selectedPhases: [Phase]
    let availablePhases: [Phase]
    
    func isEqualTo(_ other: (any ChartDataSpec.Filters)?) -> Bool {
        if let other = other as? ElectricityChartFilters {
            return self == other
        }
        
        return false
    }
    
    func copy(
        type: ElectricityMeterChartType? = nil, a
        availableTypes: [ElectricityMeterChartType]? = nil,
        selectedPhases: [Phase]? = nil,
        availablePhases: [Phase]? = nil
    ) -> Self {
        ElectricityChartFilters(
            type: type ?? self.type,
            availableTypes: availableTypes ?? self.availableTypes,
            selectedPhases: selectedPhases ?? self.selectedPhases,
            availablePhases: availablePhases ?? self.availablePhases
        )
    }
    
    static func standard() -> ElectricityChartFilters {
        ElectricityChartFilters(
            type: .forwardActiveEnergy,
            availableTypes: ElectricityMeterChartType.allCases,
            selectedPhases: Phase.allCases,
            availablePhases: Phase.allCases
        )
    }
    
    static func restore(
        flags: Int64,
        value: SAElectricityMeterExtendedValue?,
        configDto: ElectricityMeterConfigDto?,
        state: ChartState?
    ) -> ElectricityChartFilters {
        let filters = (state as? ElectricityChartState)?.customFilters ?? standard()
        let availablePhases = filterPhases(flags: flags, phases: Phase.allCases)
        var selectedPhases = filterPhases(flags: flags, phases: filters.selectedPhases)
        if (selectedPhases.isEmpty && filters.type.needsPhases) {
            selectedPhases = availablePhases
        }
        
        return ElectricityChartFilters(
            type: filters.type,
            availableTypes: buildTypes(value: value, configDto: configDto),
            selectedPhases: selectedPhases,
            availablePhases: availablePhases
        )
    }
    
    private static func filterPhases(flags: Int64, phases: [Phase]) -> [Phase] {
        var result: [Phase] = []
        
        phases.forEach {
            if ((flags & $0.disabledFlag) == 0) {
                result.append($0)
            }
        }
        
        return result
    }
    
    private static func buildTypes(
        value: SAElectricityMeterExtendedValue?,
        configDto: ElectricityMeterConfigDto?
    ) -> [ElectricityMeterChartType] {
        guard let value = value else { return [] }
        
        let measuredTypes = value.suplaElectricityMeterMeasuredTypes
        var result: [ElectricityMeterChartType] = []
        
        let hasForwardEnergy = measuredTypes.contains(.forwardActiveEnergy)
        if (hasForwardEnergy) {
            result.append(.forwardActiveEnergy)
        }
        let hasReverseEnergy = measuredTypes.contains(.reverseActiveEnergy)
        if (hasReverseEnergy) {
            result.append(.reverseActiveEnergy)
        }
        if (measuredTypes.contains(.forwardReactiveEnergy)) {
            result.append(.forwardReactiveEnergy)
        }
        if (measuredTypes.contains(.reverseReactiveEnergy)) {
            result.append(.reverseReactiveEnergy)
        }
        if (hasForwardEnergy && hasReverseEnergy) {
            result.append(.balanceArithmetic)
            result.append(.balanceHourly)
            result.append(.balanceChartAggregated)
        }
        if (measuredTypes.hasBalance) {
            result.append(.balanceVector)
        }
        configDto?.voltageLoggerEnabled.ifTrue { result.append(.voltage) }
        configDto?.currentLoggerEnabled.ifTrue { result.append(.current) }
        configDto?.powerActiveLoggerEnabled.ifTrue { result.append(.powerActive) }
        
        return result
    }
}

extension Phase {
    var color: UIColor? {
        switch (self) {
        case .phase1: .chartPhase1
        case .phase2: .chartPhase2
        case .phase3: .chartPhase3
        }
    }
}

extension ChartDataSpec.Filters {
    func ifPhase(_ phase: Phase, _ callback: () -> Void) {
        if ((self as? ElectricityChartFilters)?.selectedPhases.contains(phase) != false) {
            callback()
        }
    }
    
    func ifPhase1(_ callback: () -> Void) {
        if ((self as? ElectricityChartFilters)?.selectedPhases.contains(.phase1) != false) {
            callback()
        }
    }
    
    func ifPhase2(_ callback: () -> Void) {
        if ((self as? ElectricityChartFilters)?.selectedPhases.contains(.phase2) != false) {
            callback()
        }
    }
    
    func ifPhase3(_ callback: () -> Void) {
        if ((self as? ElectricityChartFilters)?.selectedPhases.contains(.phase3) != false) {
            callback()
        }
    }
}
