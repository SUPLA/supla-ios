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

import RxRelay
import RxSwift
import SharedCore

extension ThermostatTimerDetailFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ViewDelegate {
        @Singleton<ExecuteThermostatActionUseCase> private var executeThermostatActionUseCase
        @Singleton<ReadChannelByRemoteIdUseCase> private var readChannelByRemoteIdUseCase
        @Singleton<ChannelConfigEventsManager> private var channelConfigEventManager
        @Singleton<GetChannelConfigUseCase> private var getChannelConfigUseCase
        @Singleton<DateProvider> private var dateProvider
        
        private let item: ItemBundle
        private let channelRelay = PublishRelay<SAChannel>()
        private let loadingTimeoutManager: LoadingTimeoutManager
        
        init(item: ItemBundle, loadingTimeoutManager: LoadingTimeoutManager = LoadingTimeoutManagerImpl()) {
            self.item = item
            self.loadingTimeoutManager = loadingTimeoutManager
            super.init(state: ViewState())
        }
        
        override func onViewDidLoad() {
            loadingTimeoutManager.watch(
                stateProvider: { [weak self] in self?.state.loadingState },
                onTimeout: { [weak self] in self?.loadData() }
            )
            .disposed(by: disposeBag)
            
            Observable.combineLatest(
                channelRelay,
                channelConfigEventManager.observeConfig(id: item.remoteId)
                    .filter { $0.config is SuplaChannelHvacConfig && $0.result == .resultTrue }
            ).asDriverWithoutError()
                .debounce(.milliseconds(100))
                .drive(onNext: { [weak self] in
                    self?.handleData($0.0, $0.1.config as! SuplaChannelHvacConfig)
                })
                .disposed(by: disposeBag)
        }
        
        func loadData() {
            readChannelByRemoteIdUseCase.invoke(remoteId: item.remoteId)
                .subscribe(onNext: { [weak self] in self?.channelRelay.accept($0) })
                .disposed(by: disposeBag)
            
            getChannelConfigUseCase.invoke(remoteId: item.remoteId, type: .defaultConfig)
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        func onDeviceModeChange(_ mode: ThermostatTimerDetailFeature.DeviceMode) {
            switch (mode) {
            case .auto:
                state.setpointInChange = .heat
                // swap values if needed
                if (state.heatValue > state.coolValue) {
                    let heatValue = state.heatValue
                    state.heatValue = state.coolValue
                    state.coolValue = heatValue
                    
                    let heatSetpoint = state.heatSetpoint
                    state.heatSetpoint = state.coolSetpoint
                    state.coolSetpoint = heatSetpoint
                }
            case .heating:
                state.setpointInChange = .heat
            case .cooling:
                state.setpointInChange = .cool
            default: break // nothing to do
            }
        }
        
        func onHeatValueChange(_ value: CGFloat) {
            state.setpointInChange = .heat
            state.heatSetpoint = ((state.configMax - state.configMin) * Float(value) + state.configMin).roundToTenths()
            
            state.minusDisabled = state.heatSetpoint <= state.configMin
            state.plusDisabled = state.heatSetpoint >= state.configMax
        }
        
        func onCoolValueChange(_ value: CGFloat) {
            state.setpointInChange = .cool
            state.coolSetpoint = ((state.configMax - state.configMin) * Float(value) + state.configMin).roundToTenths()
            
            state.minusDisabled = state.coolSetpoint <= state.configMin
            state.plusDisabled = state.coolSetpoint >= state.configMax
        }
        
        func onSetpointChange(_ step: TemperatureChangeStep) {
            switch (state.setpointInChange) {
            case .cool:
                state.coolSetpoint += step.rawValue
                
                state.minusDisabled = state.coolSetpoint <= state.configMin
                state.plusDisabled = state.coolSetpoint >= state.configMax
            case .heat:
                state.heatSetpoint += step.rawValue
                
                state.minusDisabled = state.heatSetpoint <= state.configMin
                state.plusDisabled = state.heatSetpoint >= state.configMax
            }
            state.updateValues()
        }
        
        func onTimeSelectionModeChange(_ mode: ThermostatTimerDetailFeature.TimeSelectionMode) {
            state.timeSelectionMode = mode
        }
        
        func onEditTimer() {
            state.isTimerEditing = true

            guard let endTime = state.timerEndTime else { return }
            let currentTime = dateProvider.currentDate()
            let leftTime = endTime.differenceInSeconds(currentTime)
            
            state.timerDays = leftTime.days.asDayPickerItem
            state.timerHours = leftTime.hoursInDay.asHourPickerItem
            state.timerMinutes = leftTime.minutesInHour.asMinutePickerItem
            state.timeSelectionMode = .timer
        }
        
        func onStart() {
            let duration = state.getTimerDuration(dateProvider.currentDate())
            if (duration <= 0) {
                return
            }
            
            state.loadingState = state.loadingState.copy(loading: true)
            state.isTimerEditing = false
            
            let mode: SuplaHvacMode = state.selectedMode.hvacMode
            let sendHeat = state.selectedMode == .heating || state.selectedMode == .auto
            let sendCool = state.selectedMode == .cooling || state.selectedMode == .auto
            
            executeThermostatActionUseCase.invoke(
                type: .channel,
                remoteId: item.remoteId,
                mode: mode,
                setpointTemperatureHeat: sendHeat ? state.heatSetpoint : nil,
                setpointTemperatureCool: sendCool ? state.coolSetpoint : nil,
                durationInSec: Int32(duration)
            )
            .asDriverWithoutError()
            .drive()
            .disposed(by: disposeBag)
        }
        
        func onCancelEditMode() {
            state.isTimerEditing = false
        }
        
        func onCancelTimerIntoManualMode() {
            state.loadingState = state.loadingState.copy(loading: true)
            
            executeThermostatActionUseCase.invoke(
                type: .channel,
                remoteId: item.remoteId,
                mode: .cmdSwitchToManual,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: nil,
                durationInSec: nil
            ).asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        func onCancelTimerIntoProgramMode() {
            state.loadingState = state.loadingState.copy(loading: true)
            
            executeThermostatActionUseCase.invoke(
                type: .channel,
                remoteId: item.remoteId,
                mode: .cmdWeeklySchedule,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: nil,
                durationInSec: nil
            ).asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        private func handleData(_ channel: SAChannel, _ config: SuplaChannelHvacConfig) {
            SALog.debug("Handle data")
            let currentDate = dateProvider.currentDate()
            let timerEndDate = channel.getTimerEndDate()
            let isTimerOn = timerEndDate != nil && timerEndDate!.timeIntervalSince1970 > currentDate.timeIntervalSince1970
            
            guard let minTemperature = config.minTemperature,
                  let maxTemperature = config.maxTemperature,
                  let thermostatValue = channel.value?.asThermostatValue()
            else { return }
            
            state.availableModes = DeviceMode.modsFor(channel.func, subfunction: thermostatValue.subfunction)
            state.selectedMode = state.availableModes.first ?? .off
            
            state.calendarDate = currentDate.shift(days: 7)
            state.isTimerRunning = isTimerOn
            state.timerEndTime = isTimerOn ? timerEndDate : nil
            state.offline = channel.status().offline
            state.minusDisabled = thermostatValue.lowSetpoint <= minTemperature
            state.plusDisabled = thermostatValue.highSetpoint >= maxTemperature
            
            state.loadingState = state.loadingState.copy(loading: false)
            
            state.configMin = minTemperature
            state.configMax = maxTemperature
            state.heatSetpoint = thermostatValue.setpointTemperatureHeat
            state.coolSetpoint = thermostatValue.setpointTemperatureCool
            state.updateValues()
            
            state.deviceStateData = DeviceState.Data(
                label: ThermostatStateHelper.endDateText(timerEndDate),
                icon: thermostatValue.mode.icon.map { .suplaIcon(name: $0) },
                value: ThermostatStateHelper.currentStateValue(thermostatValue.mode, heatSetpoint: state.heatSetpoint, coolSetpoint: state.coolSetpoint),
                iconColor: thermostatValue.mode.color
            )
        }
    }
}

private extension ThermostatValue {
    var lowSetpoint: Float {
        switch (mode) {
        case .heat, .heatCool: setpointTemperatureHeat
        case .cool: setpointTemperatureCool
        default: 0
        }
    }
    
    var highSetpoint: Float {
        switch (mode) {
        case .heat: setpointTemperatureHeat
        case .cool, .heatCool: setpointTemperatureCool
        default: 0
        }
    }
}
