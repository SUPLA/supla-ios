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
    
extension ThermostatSlavesFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
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
                    onNext: { [weak self] in self?.handle(channel: $0) }
                )
                .disposed(by: disposeBag)
        }
        
        private func handle(channel: ChannelWithChildren) {
            state.master = channel.toThermostatData()
            state.slaves = channel.allDescendantFlat
                .filter { $0.relationType == .masterThermostat }
                .map { $0.toThermostatData() }
        }
    }
}

private extension ChannelChild {
    func toThermostatData() -> ThermostatSlavesFeature.ThermostatData {
        @Singleton var getChannelCaptionUseCase: GetChannelBaseCaptionUseCase
        @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
        @Singleton var getChannelValueStringUseCase: GetChannelValueStringUseCase
        @Singleton var valuesFormatter: ValuesFormatter
        
        let thermostatValue = channel.value?.asThermostatValue()
        let mainThermometer = children.first(where: { $0.relationType == .mainThermometer })
        let pumpSwitchChild = children.first(where: { $0.relationType == .pumpSwitch })
        let sourceSwitchChild = children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
        
        let value = mainThermometer != nil ? getChannelValueStringUseCase.invoke(mainThermometer!.channel) : NO_VALUE_TEXT
        
        return ThermostatSlavesFeature.ThermostatData(
            id: channel.remote_id,
            onlineState: ListOnlineState.from(channel.isOnline()),
            caption: getChannelCaptionUseCase.invoke(channelBase: channel),
            icon: getChannelIcon(channel),
            currentPower: thermostatValue?.state.power?.also { valuesFormatter.percentageToString($0/100) },
            value: value,
            indicatorIcon: thermostatValue?.indicatorIcon ?? .off,
            issueIconType: thermostatValue?.issueIcon,
            issueMessage: thermostatValue?.issueText,
            showChannelStateIcon: channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0,
            subValue: thermostatValue?.setpointText,
            pumpSwitchIcon: getChannelIcon(pumpSwitchChild?.channel),
            sourceSwitchIcon: getChannelIcon(sourceSwitchChild?.channel),
            channel: channel
        )
    }
    

}

private extension ChannelWithChildren {
    func toThermostatData() -> ThermostatSlavesFeature.ThermostatData {
        @Singleton var getChannelCaptionUseCase: GetChannelBaseCaptionUseCase
        @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
        @Singleton var getChannelValueStringUseCase: GetChannelValueStringUseCase
        @Singleton var valuesFormatter: ValuesFormatter
        
        let thermostatValue = channel.value?.asThermostatValue()
        let mainThermometer = children.first(where: { $0.relationType == .mainThermometer })
        let pumpSwitchChild = children.first(where: { $0.relationType == .pumpSwitch })
        let sourceSwitchChild = children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
        
        let value = mainThermometer != nil ? getChannelValueStringUseCase.invoke(mainThermometer!.channel) : NO_VALUE_TEXT
        
        return ThermostatSlavesFeature.ThermostatData(
            id: channel.remote_id,
            onlineState: ListOnlineState.from(channel.isOnline()),
            caption: getChannelCaptionUseCase.invoke(channelBase: channel),
            icon: getChannelIcon(channel),
            currentPower: thermostatValue?.state.power?.also { valuesFormatter.percentageToString($0/100) },
            value: value,
            indicatorIcon: thermostatValue?.indicatorIcon ?? .off,
            issueIconType: thermostatValue?.issueIcon,
            issueMessage: thermostatValue?.issueText,
            showChannelStateIcon: channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0,
            subValue: thermostatValue?.setpointText,
            pumpSwitchIcon: getChannelIcon(pumpSwitchChild?.channel),
            sourceSwitchIcon: getChannelIcon(sourceSwitchChild?.channel),
            channel: channel
        )
    }
}

private func getChannelIcon(_ channel: SAChannel?) -> IconResult? {
    guard let channel = channel else { return nil }
    @Singleton var getChannelIconUseCase: GetChannelBaseIconUseCase
    
    let subfunction: ThermostatSubfunction? = channel.isHvacThermostat() ? channel.value?.asThermostatValue().subfunction : nil
    return getChannelIconUseCase.invoke(channel: channel, subfunction: subfunction)
}
