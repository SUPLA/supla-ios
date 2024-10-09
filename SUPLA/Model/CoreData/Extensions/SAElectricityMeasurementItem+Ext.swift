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

extension SAElectricityMeasurementItem: ChartDataAggregation.Reduceable {}

extension SAElectricityMeasurementItem {
    func getValues(spec: ChartDataSpec) -> [Double] {
        switch ((spec.customFilters as? ElectricityChartFilters)?.type) {
        case nil: noFiltersValues()
        case .balanceVector: vectorBalance()
        case .balanceArithmetic: arithmeticBalance()
        case .balanceChartAggregated: arithmeticChartBalance()
        default: phasesValues(spec.customFilters as! ElectricityChartFilters)
        }
    }
    
    func valueFor(phase: Phase, spec: ChartDataSpec) -> Double {
        if let customFilters = spec.customFilters as? ElectricityChartFilters {
            return valueFor(phase: phase, type: customFilters.type)
        } else {
            return valueFor(phase: phase, type: .forwardActiveEnergy)
        }
    }

    private func noFiltersValues() -> [Double] {
        [phase1_fae, phase2_fae, phase3_fae]
    }

    private func vectorBalance() -> [Double] {
        balanceValues(consumption: fae_balanced, production: rae_balanced)
    }

    private func arithmeticBalance() -> [Double] {
        let consumption = phase1_fae + phase2_fae + phase3_fae
        let production = phase1_rae + phase2_rae + phase3_rae
        return balanceValues(consumption: consumption, production: production)
    }

    private func arithmeticChartBalance() -> [Double] {
        let consumption = phase1_fae + phase2_fae + phase3_fae
        let production = phase1_rae + phase2_rae + phase3_rae
        return chartBalancedValues(consumption: consumption, production: production)
    }

    private func phasesValues(_ filters: ElectricityChartFilters) -> [Double] {
        var values: [Double] = []
        for cas in Phase.allCases {
            if (filters.selectedPhases.contains(cas)) {
                values.append(valueFor(phase: cas, type: filters.type))
            }
        }
        return values
    }

    private func valueFor(phase: Phase, type: ElectricityMeterChartType) -> Double {
        switch (phase) {
        case .phase1: valueFor(type: type, phase1_fae, phase1_rae, phase1_fre, phase1_rre)
        case .phase2: valueFor(type: type, phase2_fae, phase2_rae, phase2_fre, phase2_rre)
        case .phase3: valueFor(type: type, phase3_fae, phase3_rae, phase3_fre, phase3_rre)
        }
    }

    private func valueFor(type: ElectricityMeterChartType, _ fae: Double, _ rae: Double, _ fre: Double, _ rre: Double) -> Double {
        switch (type) {
        case .reverseActiveEnergy: rae
        case .forwardReactiveEnergy: fre
        case .reverseReactiveEnergy: rre
        default: fae
        }
    }
}

extension Array where Element == SAElectricityMeasurementItem {
    func balanceHourly() -> [BalancedValue] {
        reduce([TimeInterval: LinkedList<SAElectricityMeasurementItem>]()) { ChartDataAggregation.hours.reductor($0, $1) }
            .filter { $0.value.isEmpty == false }
            .map { group in
                let consumption = group.value.map { $0.phase1_fae + $0.phase2_fae + $0.phase3_fae }.sum { $0 }
                let production = group.value.map { $0.phase1_rae + $0.phase2_rae + $0.phase3_rae }.sum { $0 }

                let result = consumption - production
                return BalancedValue(item: group.value.head!.value, result > 0 ? result : 0.0, result < 0 ? -result : 0.0)
            }
    }
}

func balanceValues(consumption: Double, production: Double) -> [Double] {
    [consumption, -production]
}

func chartBalancedValues(consumption: Double, production: Double) -> [Double] {
    let smaller = min(consumption, production)
    return [-1 * smaller, consumption - smaller, -1 * (production - smaller), smaller]
}

struct BalancedValue: ChartDataAggregation.Reduceable {
    let date: Date
    let forwarded: Double
    let reversed: Double
    
    var hour: Int16
    var day: Int16
    var month: Int16
    var year: Int16
    
    init(item: SAMeasurementItem, _ forwarded: Double, _ reversed: Double) {
        self.date = item.date!
        self.hour = item.hour
        self.day = item.day
        self.month = item.month
        self.year = item.year
        self.forwarded = forwarded
        self.reversed = reversed
    }
}
