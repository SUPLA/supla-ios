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
    
extension SAElectricityMeterExtendedValue {
    var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = Locale.current.decimalSeparator
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }

    var hasForwardEnergy: Bool {
        Int32(measuredValues()) & SuplaElectricityMeasurementType.forwardActiveEnergy.value > 0
    }
    
    var hasReverseEnergy: Bool {
        Int32(measuredValues()) & SuplaElectricityMeasurementType.reverseActiveEnergy.value > 0
    }
    
    func getForwardEnergy(formatter: ListElectricityMeterValueFormatter) -> SummaryCardData? {
        hasForwardEnergy.ifTrue {
            SummaryCardData(formatter: formatter, energy: totalForwardActiveEnergy(), pricePerUnit: pricePerUnit(), currency: currency())
        }
    }
    
    func getReverseEnergy(formatter: ListElectricityMeterValueFormatter) -> SummaryCardData? {
        hasReverseEnergy.ifTrue {
            let energy = totalReverseActiveEnergy()
            return SummaryCardData(energy: formatter.format(energy))
        }
    }
    
    func measuredValues(
        _ types: [SuplaElectricityMeasurementType],
        _ phase: Phase
    ) -> [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value] {
        var result: [SuplaElectricityMeasurementType: SuplaElectricityMeasurementType.Value] = [:]
        
        for type in types {
            if let provider = type.provider,
               let value = provider(self, phase)
            {
                result[type] = .single(value: value)
            }
        }
        
        return result
    }
}
