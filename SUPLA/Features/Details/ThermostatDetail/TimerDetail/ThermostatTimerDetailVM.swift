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
import RxRelay
import RxSwift
import SharedCore

extension ThermostatTimerDetailFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
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
            super.init(
                state: ViewState(),
                eventSelector: #selector(handleChannelValueChange(notification:)),
                eventName: NSNotification.Name.saChannelValueChanged
            )
        }
        
        override func onViewCreated() {
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

        override func onViewAppear() {
            loadData()
        }

        @objc
        private func handleChannelValueChange(notification: Notification) {
            if let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
               let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
               !isGroup.boolValue,
               remoteId.int32Value == item.remoteId
            {
                loadData()
            }
        }
        
        private func loadData() {
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
            state.updateStepButtons()
        }
        
        func onHeatValueChange(_ value: CGFloat) {
            guard value.isFinite,
                  ThermostatTemperatureRange.isAdjustable(minimum: state.configMin, maximum: state.configMax),
                  let temperature = Float(value).thermostatTemperature(
                    minimum: state.configMin,
                    maximum: state.configMax
                  )
            else { return }

            state.setpointInChange = .heat
            state.heatSetpoint = temperature
            state.updateStepButtons()
        }
        
        func onCoolValueChange(_ value: CGFloat) {
            guard value.isFinite,
                  ThermostatTemperatureRange.isAdjustable(minimum: state.configMin, maximum: state.configMax),
                  let temperature = Float(value).thermostatTemperature(
                    minimum: state.configMin,
                    maximum: state.configMax
                  )
            else { return }

            state.setpointInChange = .cool
            state.coolSetpoint = temperature
            state.updateStepButtons()
        }
        
        func onSetpointChange(_ step: TemperatureChangeStep) {
            guard ThermostatTemperatureRange.isAdjustable(minimum: state.configMin, maximum: state.configMax) else { return }

            switch (state.setpointInChange) {
            case .cool:
                guard state.coolSetpoint.isFinite,
                      let value = (state.coolSetpoint + step.rawValue).hvacClamped(
                        minimum: state.configMin,
                        maximum: state.configMax
                      )
                else { return }
                state.coolSetpoint = value.roundToTenths()
            case .heat:
                guard state.heatSetpoint.isFinite,
                      let value = (state.heatSetpoint + step.rawValue).hvacClamped(
                        minimum: state.configMin,
                        maximum: state.configMax
                      )
                else { return }
                state.heatSetpoint = value.roundToTenths()
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
            state.updateValues()
            let duration = state.getTimerDuration(dateProvider.currentDate())
            if (duration <= 0) {
                return
            }

            guard state.selectedMode == .off || ThermostatTemperatureRange.isValid(
                minimum: state.configMin,
                maximum: state.configMax
            ),
                  state.selectedMode != .heating || state.heatSetpoint.hvacClamped(
                    minimum: state.configMin,
                    maximum: state.configMax
                  ) != nil,
                  state.selectedMode != .cooling || state.coolSetpoint.hvacClamped(
                    minimum: state.configMin,
                    maximum: state.configMax
                  ) != nil,
                  state.selectedMode != .auto || (
                    state.heatSetpoint.hvacClamped(minimum: state.configMin, maximum: state.configMax) != nil &&
                    state.coolSetpoint.hvacClamped(minimum: state.configMin, maximum: state.configMax) != nil
                  )
            else { return }
            
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
            let timerEndDate = channel.timerEndDate
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
            
            state.channelCurrentStateData = ChannelCurrentState.Data(
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
