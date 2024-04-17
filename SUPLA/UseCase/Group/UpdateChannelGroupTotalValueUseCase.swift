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

import Foundation
import RxSwift

protocol UpdateChannelGroupTotalValueUseCase {
    func invoke() -> Observable<[Int32]>
}

final class UpdateChannelGroupTotalValueUseCaseImpl: UpdateChannelGroupTotalValueUseCase {
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<ChannelGroupRelationRepository> private var channelGroupRelationRepository
    
    func invoke() -> Observable<[Int32]> {
        return channelGroupRelationRepository.getAllVisibleRelationsForActiveProfile()
            .map { self.updateGroupTotalValues(relations: $0) }
            .flatMapFirst { updatedEntries in
                if (updatedEntries.isEmpty) {
                    return Observable.just(updatedEntries)
                }
                    
                return self.channelGroupRelationRepository
                    .save()
                    .map { updatedEntries }
            }
    }
    
    private func updateGroupTotalValues(relations: [SAChannelGroupRelation]) -> [Int32] {
        if (relations.isEmpty) {
            return []
        }
        
        var group: SAChannelGroup?
        var groupTotalValue = GroupTotalValue()
        var groupOnlineSummary = GroupOnlineSummary()
        var result: [Int32] = []
        
        for relation in relations {
            if (group == nil) {
                group = relation.group
            } else if (group?.remote_id != relation.group?.remote_id) {
                group?.updatedBy(groupTotalValue, groupOnlineSummary) { result.append($0.remote_id) }
                groupTotalValue = GroupTotalValue()
                groupOnlineSummary = GroupOnlineSummary()
                group = relation.group
            }
            
            groupOnlineSummary.count += 1
            if let value = relation.value,
               let groupValue = group?.getGroupValue(value),
               value.online
            {
                groupTotalValue.values.append(groupValue)
                groupOnlineSummary.onlineCount += 1
            }
        }
        
        group?.updatedBy(groupTotalValue, groupOnlineSummary) { result.append($0.remote_id) }
        
        return result
    }
    
    struct GroupOnlineSummary {
        var onlineCount = 0
        var count = 0
        
        var value: Int16 {
            if (count == 0) {
                0
            } else {
                Int16(onlineCount * 100 / count)
            }
        }
    }
}

private extension SAChannelGroup {
    func updatedBy(
        _ totalValue: GroupTotalValue,
        _ onlineSummary: UpdateChannelGroupTotalValueUseCaseImpl.GroupOnlineSummary,
        _ onChangedCallback: (SAChannelGroup) -> Void
    ) {
        let onlineValue = onlineSummary.value
        let currentTotalValue = total_value as? GroupTotalValue
        
        if (online != onlineValue || currentTotalValue != totalValue) {
            online = onlineValue
            total_value = totalValue
            onChangedCallback(self)
        }
    }
    
    func getGroupValue(_ value: SAChannelValue) -> BaseGroupValue? {
        switch (self.func) {
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
                return BoolGroupValue(value: (value.hiSubValue() & 0x1) == 1)
            case SUPLA_CHANNELFNC_POWERSWITCH,
                 SUPLA_CHANNELFNC_LIGHTSWITCH,
                 SUPLA_CHANNELFNC_STAIRCASETIMER,
                 SUPLA_CHANNELFNC_VALVE_OPENCLOSE:
                return BoolGroupValue(value: value.hiValue() == 1)
            case SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
                return IntegerGroupValue(value: Int(value.percentValue()))
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
                 SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW:
                return RollerShutterGroupValue(
                    position: value.asRollerShutterValue().position,
                    openSensorActive: value.hiSubValue() == 1
                )
            case SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND:
                let facadeBlindValue = value.asFacadeBlindValue()
                return FacadeBlindGroupValue(
                    position: facadeBlindValue.position,
                    tilt: facadeBlindValue.tilt
                )
            case SUPLA_CHANNELFNC_DIMMER:
                return IntegerGroupValue(value: Int(value.brightnessValue()))
            case SUPLA_CHANNELFNC_RGBLIGHTING:
                return RgbLightingGroupValue(
                    color: value.colorValue(),
                    brightness: Int(value.colorBrightnessValue())
                )
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                return DimmerAndRgbLightingGroupValue(
                    color: value.colorValue(),
                    colorBrightness: Int(value.colorBrightnessValue()),
                    brightness: Int(value.brightnessValue())
                )
            case SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS:
                let thermostatValue = value.asHeatpolThermostatValue()
                return HeatpolThermostatGroupValue(
                    on: thermostatValue.on,
                    measuredTemperature: thermostatValue.measuredTemperature,
                    presetTemperature: thermostatValue.presetTemperature
                )
            default: return nil
        }
    }
}
