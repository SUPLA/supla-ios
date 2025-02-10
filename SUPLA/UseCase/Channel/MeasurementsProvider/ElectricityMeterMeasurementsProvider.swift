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
    
import RxSwift

protocol ElectricityMeterMeasurementsProvider: ChannelMeasurementsProvider {}

final class ElectricityMeterMeasurementsProviderImpl: ElectricityMeterMeasurementsProvider {
    
    @Singleton<ElectricityConsumptionProvider> private var electricityConsumptionProvider
    @Singleton<VoltageMeasurementsProvider> private var voltageMeasurementsProvider
    @Singleton<CurrentMeasurementsProvider> private var currentMeasurementsProvider
    @Singleton<PowerActiveMeasurementsProvider> private var powerActiveMeasurementsProvider
    
    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        channelWithChildren.isOrHasElectricityMeter
    }
    
    func provide(
        _ channelWithChildren: ChannelWithChildren,
        _ spec: ChartDataSpec,
        _ colorProvider: ((ChartEntryType) -> UIColor)?
    ) -> Observable<ChannelChartSets> {
        let type = (spec.customFilters as? ElectricityChartFilters)?.type ?? ElectricityMeterChartType.forwardActiveEnergy
        
        return switch (type) {
        case .current: currentMeasurementsProvider.provide(channelWithChildren, spec, colorProvider)
        case .voltage: voltageMeasurementsProvider.provide(channelWithChildren, spec, colorProvider)
        case .powerActive: powerActiveMeasurementsProvider.provide(channelWithChildren, spec, colorProvider)
        default: electricityConsumptionProvider.provide(channelWithChildren, spec, colorProvider)
        }
    }
}
