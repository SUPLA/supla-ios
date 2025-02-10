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
    
protocol CurrentMeasurementsProvider: ElectricityMeasurementsProvider {
}

final class CurrentMeasurementsProviderImpl: CurrentMeasurementsProvider {
    @Singleton<CurrentMeasurementItemRepository> private var repository
    @Singleton<GetCaptionUseCase> var getCaptionUseCase
    
    private let formatter = VoltageValueFormatter()
    
    func formatLabelValue(_ electricityValue: SAElectricityMeterExtendedValue, _ phase: Phase) -> String {
        formatter.format(electricityValue.current(forPhase: phase.rawValue), withUnit: false)
    }
    
    func findMeasurementsForPhase(
        _ channel: SAChannel,
        _ spec: ChartDataSpec,
        _ isFirst: Bool,
        _ phase: Phase
    ) -> Observable<(Phase, HistoryDataSet)> {
        repository.findMeasurements(
            remoteId: channel.remote_id,
            serverId: channel.profile.server?.id,
            phase: phase,
            startDate: spec.startDate,
            endDate: spec.endDate
        )
        .map { self.aggregating($0, spec.aggregation) }
        .map { (phase, self.historyDataSet(channel, phase, isFirst, .voltage, spec.aggregation, $0)) }
    }
}

