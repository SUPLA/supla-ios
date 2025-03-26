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
    
extension ThermostatSlavesFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ChannelUpdatesObserver {
        @Singleton private var readChannelWithChildrenTreeUseCase: ReadChannelWithChildrenTreeUseCase
        @Singleton private var globalSettings: GlobalSettings
        
        init() {
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            state.scale = CGFloat(globalSettings.channelHeight.factor())
        }
        
        func loadData(_ remoteId: Int32) {
            readChannelWithChildrenTreeUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(
                    onNext: { [weak self] in self?.handle(channel: $0) },
                    onCompleted: { SALog.debug("Completed!!") }
                )
                .disposed(by: disposeBag)
        }
        
        func reloadData(_ remoteId: Int32, _ relatedId: Int32) {
            if (state.relatedIds.contains(relatedId)) {
                loadData(remoteId)
            }
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            handle(channel: channelWithChildren)
        }
        
        private func handle(channel: ChannelWithChildren) {
            state.master = channel.toThermostatData()
            state.slaves = channel.allDescendantFlat
                .filter { $0.relationType == .masterThermostat }
                .map { $0.toThermostatData() }
            
            state.relatedIds = channel.relatedIds
            state.relatedIds.append(
                contentsOf: channel.allDescendantFlat
                    .filter { $0.relationType == .masterThermostat }
                    .flatMap { $0.relatedIds }
            )
        }
    }
}

private extension ChannelChild {
    var relatedIds: [Int32] {
        var ids: [Int32] = []
        ids.append(channel.remote_id)
        
        if let thermometer = children.first(where: { $0.relationType == .mainThermometer }) {
            ids.append(thermometer.channel.remote_id)
        }
        
        if let pumpSwitch = children.first(where: { $0.relationType == .pumpSwitch }) {
            ids.append(pumpSwitch.channel.remote_id)
        }
        
        if let heatOrColdSourceSwitch = children.first(where: { $0.relationType == .heatOrColdSourceSwitch }) {
            ids.append(heatOrColdSourceSwitch.channel.remote_id)
        }
        
        return ids
    }
    
    func toThermostatData() -> ThermostatSlavesFeature.ThermostatData {
        @Singleton var getChannelIssuesForSlavesUseCase: GetChannelIssuesForSlavesUseCase
        @Singleton var getChannelValueStringUseCase: GetChannelValueStringUseCase
        @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
        @Singleton var getCaptionUseCase: GetCaptionUseCase
        @Singleton var valuesFormatter: ValuesFormatter
        
        let thermostatValue = channel.value?.asThermostatValue()
        let mainThermometer = children.first(where: { $0.relationType == .mainThermometer })
        let pumpSwitchChild = children.first(where: { $0.relationType == .pumpSwitch })
        let sourceSwitchChild = children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
        
        let value = mainThermometer != nil ? getChannelValueStringUseCase.invoke(mainThermometer!.channel) : NO_VALUE_TEXT
        
        return ThermostatSlavesFeature.ThermostatData(
            id: channel.remote_id,
            onlineState: channel.onlineState,
            caption: getCaptionUseCase.invoke(data: channel.shareable).string,
            userCaption: channel.caption ?? "",
            icon: getChannelIcon(channel),
            currentPower: thermostatValue?.state.power?.floatValue.also { valuesFormatter.percentageToString($0/100) },
            value: value,
            indicatorIcon: thermostatValue?.indicatorIcon ?? .off,
            issues: getChannelIssuesForSlavesUseCase.invoke(channel: channel.shareable),
            showChannelStateIcon: channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0,
            subValue: thermostatValue?.setpointText,
            pumpSwitchIcon: getChannelIcon(pumpSwitchChild?.channel),
            sourceSwitchIcon: getChannelIcon(sourceSwitchChild?.channel)
        )
    }
}

private extension ChannelWithChildren {
    var relatedIds: [Int32] {
        var ids: [Int32] = []
        ids.append(channel.remote_id)
        
        if let thermometer = children.first(where: { $0.relationType == .mainThermometer }) {
            ids.append(thermometer.channel.remote_id)
        }
        
        if let pumpSwitch = children.first(where: { $0.relationType == .pumpSwitch }) {
            ids.append(pumpSwitch.channel.remote_id)
        }
        
        if let heatOrColdSourceSwitch = children.first(where: { $0.relationType == .heatOrColdSourceSwitch }) {
            ids.append(heatOrColdSourceSwitch.channel.remote_id)
        }
        
        return ids
    }
    
    func toThermostatData() -> ThermostatSlavesFeature.ThermostatData {
        @Singleton var getChannelIssuesForSlavesUseCase: GetChannelIssuesForSlavesUseCase
        @Singleton var getChannelValueStringUseCase: GetChannelValueStringUseCase
        @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
        @Singleton var getCaptionUseCase: GetCaptionUseCase
        @Singleton var valuesFormatter: ValuesFormatter
        
        let thermostatValue = channel.value?.asThermostatValue()
        let mainThermometer = children.first(where: { $0.relationType == .mainThermometer })
        let pumpSwitchChild = children.first(where: { $0.relationType == .pumpSwitch })
        let sourceSwitchChild = children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
        
        let value = mainThermometer != nil ? getChannelValueStringUseCase.invoke(mainThermometer!.channel) : NO_VALUE_TEXT
        
        return ThermostatSlavesFeature.ThermostatData(
            id: channel.remote_id,
            onlineState: channel.onlineState,
            caption: getCaptionUseCase.invoke(data: channel.shareable).string,
            userCaption: channel.caption ?? "",
            icon: getChannelIcon(channel),
            currentPower: thermostatValue?.state.power?.floatValue.also { valuesFormatter.percentageToString($0/100) },
            value: value,
            indicatorIcon: thermostatValue?.indicatorIcon ?? .off,
            issues: getChannelIssuesForSlavesUseCase.invoke(channelWithChildren: shareable),
            showChannelStateIcon: channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0,
            subValue: thermostatValue?.setpointText,
            pumpSwitchIcon: getChannelIcon(pumpSwitchChild?.channel),
            sourceSwitchIcon: getChannelIcon(sourceSwitchChild?.channel)
        )
    }
}

private func getChannelIcon(_ channel: SAChannel?) -> IconResult? {
    guard let channel = channel else { return nil }
    @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
    
    let subfunction: ThermostatSubfunction? = channel.isHvacThermostat() ? channel.value?.asThermostatValue().subfunction : nil
    return getChannelIconUseCase.invoke(channel: channel, subfunction: subfunction)
}
