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

protocol GroupActivePercentageProvider {
    func handleFunction(_ function: Int32) -> Bool
    func getActivePercentage(_ valueIndex: Int, _ totalValue: GroupTotalValue) -> Int
}

protocol GetGroupActivePercentageUseCase {
    func invoke(_ channelGroup: SAChannelGroup, valueIndex: Int) -> Int
}

extension GetGroupActivePercentageUseCase {
    func invoke(_ channelGroup: SAChannelGroup, valueIndex: Int = 0) -> Int {
        invoke(channelGroup, valueIndex: valueIndex)
    }
}

final class GetGroupActivePercentageUseCaseImpl: GetGroupActivePercentageUseCase {
    let providers: [GroupActivePercentageProvider] = [
        DimmerAndRgbGroupActivePercentageProvider(),
        DimmerGroupActivePercentageProvider(),
        FacadeBlindGroupActivePercentageProvider(),
        HeatpolThermostatGroupActivePercentageProvider(),
        OpenedClosedGroupActivePercentageProvider(),
        PercentageChannelActivePercentageProvider(),
        RgbGroupActivePercentageProvider(),
        ShadingSystemGroupActivePercentageProvider()
        
    ]

    func invoke(_ channelGroup: SAChannelGroup, valueIndex: Int) -> Int {
        guard let groupTotalValue = channelGroup.total_value as? GroupTotalValue else { return 0 }

        if (groupTotalValue.values.isEmpty) {
            return 0
        }

        for provider in providers {
            if (provider.handleFunction(channelGroup.func)) {
                return provider.getActivePercentage(valueIndex, groupTotalValue)
            }
        }

        return 0
    }
}
