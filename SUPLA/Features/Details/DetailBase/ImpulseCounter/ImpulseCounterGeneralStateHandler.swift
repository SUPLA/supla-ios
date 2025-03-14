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
    
protocol ImpulseCounterGeneralStateHandler {
    func updateState(_ state: ImpulseCounterGeneralState, _ channel: ChannelWithChildren, _ measurements: ImpulseCounterMeasurements?)
}

extension ImpulseCounterGeneralStateHandler {
    func updateState(_ state: ImpulseCounterGeneralState, _ channel: ChannelWithChildren) {
        updateState(state, channel, nil)
    }
}

final class ImpulseCounterGeneralStateHandlerImpl: ImpulseCounterGeneralStateHandler {
    @Singleton private var getChannelValueUseCase: GetChannelValueUseCase
    @Singleton private var settings: GlobalSettings
    
    func updateState(
        _ state: ImpulseCounterGeneralState,
        _ channel: ChannelWithChildren,
        _ measurements: ImpulseCounterMeasurements?
    ) {
        if (!channel.channel.isImpulseCounter() && !channel.isOrHasImpulseCounter) {
            return
        }
        
        guard let extendedValue = channel.channel.ev?.impulseCounter() else {
            handleNoExtendedValue(state, channel, measurements)
            return
        }
        let formatter = ImpulseCounterChartValueFormatter(unit: extendedValue.unit())
        
        state.online = channel.channel.status().online
        state.totalData = SummaryCardData(
            formatter: formatter,
            energy: extendedValue.calculatedValue(),
            pricePerUnit: extendedValue.pricePerUnit(),
            currency: extendedValue.currency()
        )
        state.currentMonthData = measurements?.toSummaryCardData(formatter: formatter, value: extendedValue)
    }
    
    private func handleNoExtendedValue(
        _ state: ImpulseCounterGeneralState,
        _ channel: ChannelWithChildren,
        _ measurements: ImpulseCounterMeasurements?
    ) {
        let value: Double = getChannelValueUseCase.invoke(channel.channel)
        let formatter = ImpulseCounterChartValueFormatter()
            
        state.online = channel.channel.status().online
        state.totalData = SummaryCardData(energy: formatter.format(value))
        state.currentMonthData = measurements?.toSummaryCardData(formatter: formatter)
    }
}
