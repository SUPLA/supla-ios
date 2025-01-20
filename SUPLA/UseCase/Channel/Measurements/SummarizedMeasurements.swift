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
    
protocol SummarizedMeasurements {}

struct ElectricityMeasurements: SummarizedMeasurements {
    let forwardActiveEnergy: Double
    let reverseActiveEnergy: Double

    func toForwardEnergy(
        formatter: ListElectricityMeterValueFormatter,
        value: SAElectricityMeterExtendedValue? = nil
    ) -> SummaryCardData? {
        if let value {
            value.hasForwardEnergy.ifTrue {
                SummaryCardData(
                    formatter: formatter,
                    energy: forwardActiveEnergy,
                    pricePerUnit: value.pricePerUnit(),
                    currency: value.currency()
                )
            }
        } else {
            SummaryCardData(energy: formatter.format(forwardActiveEnergy))
        }
    }

    func toReverseEnergy(
        formatter: ListElectricityMeterValueFormatter,
        value: SAElectricityMeterExtendedValue? = nil
    ) -> SummaryCardData? {
        if let value {
            value.hasReverseEnergy.ifTrue { SummaryCardData(energy: formatter.format(reverseActiveEnergy)) }
        } else {
            SummaryCardData(energy: formatter.format(reverseActiveEnergy))
        }
    }
}

struct ImpulseCounterMeasurements: SummarizedMeasurements {
    let counter: Double
    
    func toSummaryCardData(
        formatter: ImpulseCounterChartValueFormatter,
        value: SAImpulseCounterExtendedValue? = nil
    ) -> SummaryCardData {
        if let value {
            SummaryCardData(formatter: formatter, energy: counter, pricePerUnit: value.pricePerUnit(), currency: value.currency())
        } else {
            SummaryCardData(energy: formatter.format(counter))
        }
    }
}
