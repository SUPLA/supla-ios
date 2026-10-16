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
import SharedCore
    
extension SwitchGeneralFeature {
    class ViewModel: SuplaCore.ViewModel<ViewState>, ViewDelegate {
        @Singleton<ElectricityMeterGeneralStateHandler> private var electricityMeterGeneralStateHandler
        @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
        @Singleton<ImpulseCounterGeneralStateHandler> private var impulseCounterGeneralStateHandler
        @Singleton<ObserveChannelWithChildren.UseCase> private var observeChannelWithChildrenUseCase
        @Singleton<ObserveGroupWithChannels.UseCase> private var observeGroupWithChannelsUseCase
        @Singleton<GetAllChannelIssuesUseCase> private var getAllChannelIssuesUseCase
        @Singleton<ExecuteSimpleAction.UseCase> private var executeSimpleActionUseCase
        @Singleton<ExecuteRelayAction.UseCase> private var executeRelayActionUseCase
        @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase
        @Singleton<ObserveRelayProgramState.UseCase> private var observeRelayProgramStateUseCase
        @Singleton<DownloadEventsManager> private var downloadEventsManager
        @Singleton<DateProvider> private var dateProvider
        @Singleton<GlobalSettings> private var settings

        var electricityState = ElectricityMeterGeneralState()
        var impulseCounterState = ImpulseCounterGeneralState()
        
        private var remoteId: Int32? = nil
        private var initialDataLoadStarted: Bool = false
        private var flags: [SuplaRelayFlag] = []
        private var weeklyScheduleEnabled = false
        private var type: SubjectType? = nil
        private let itemBundle: ItemBundle?
        
        init(itemBundle: ItemBundle? = nil) {
            self.itemBundle = itemBundle
            super.init(state: ViewState())

            if let itemBundle {
                observeData(remoteId: itemBundle.remoteId, type: itemBundle.subjectType)
            }
        }

        func observerDownload(_ remoteId: Int32) {
            downloadEventsManager.observeProgress(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
                .disposed(by: disposeBag)
        }
        
        private func observeData(remoteId: Int32, type: SubjectType) {
            self.remoteId = remoteId
            self.type = type
            switch (type) {
            case .channel:
                observerDownload(remoteId)
                observeChannelAndProgramState(remoteId: remoteId)
            case .group: observeGroup(remoteId)
            case .scene: break
            }
        }

        func onTurnOn() {
            if (flags.contains(.overcurrentRelayOff)) {
                state.alertDialogState = SuplaCore.AlertDialogState(
                    header: Strings.General.warning,
                    message: Strings.SwitchDetail.overcurrentQuestion,
                    positiveButtonText: Strings.General.yes,
                    negativeButtonText: Strings.General.no
                )
            } else {
                performAction(action: .turnOn)
            }
        }
        
        func onForceTurnOn() {
            state.alertDialogState = nil
            performAction(action: .turnOn)
        }

        func onForce() {
            guard let remoteId, let type else { return }

            if state.forceActive {
                performAction(action: weeklyScheduleEnabled ? .switchToProgramMode : .switchToManualMode)
            } else {
                executeRelayActionUseCase.invoke(
                    type: type,
                    remoteId: remoteId,
                    mode: state.on ? .forcedOn : .forcedOff
                )
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
            }
        }

        func onTurnOff() {
            performAction(action: .turnOff)
        }

        func onManual() {
            performAction(action: .switchToManualMode)
        }

        func onWeekly() {
            performAction(action: .switchToProgramMode)
        }

        func onAuto() {
            guard let remoteId, let type else { return }

            executeRelayActionUseCase.invoke(type: type, remoteId: remoteId, mode: .automatic)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        func onIntroductionClose() {
            settings.showEmGeneralIntroduction = false
            electricityState.showIntroduction = false
        }
        
        func onAlertClose() {
            state.alertDialogState = nil
        }
        
        private func observeChannelAndProgramState(remoteId: Int32) {
            let channel = observeChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .flatMapFirst { toChannelWithMeasurements($0) }

            Observable.combineLatest(channel, observeRelayProgramStateUseCase.invoke(remoteId: remoteId))
                .observe(on: MainScheduler.instance)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] channelWithMeasurements, channelProgramState in
                    self?.handleChannel(channelWithMeasurements.0, channelWithMeasurements.1, channelProgramState)
                })
                .disposed(by: disposeBag)
        }

        private func handleChannel(
            _ channel: ChannelWithChildren,
            _ measurements: SummarizedMeasurements?,
            _ channelProgramState: [ChannelProgramState.Data]
        ) {
            let showElectricityState = channel.isOrHasElectricityMeter
            let showImpulseCounterState = channel.isOrHasImpulseCounter

            if (showElectricityState) {
                electricityMeterGeneralStateHandler.updateState(electricityState, channel, measurements as? ElectricityMeasurements)
            }
            if (showImpulseCounterState) {
                impulseCounterGeneralStateHandler.updateState(impulseCounterState, channel, measurements as? ImpulseCounterMeasurements)
            }
            if (!initialDataLoadStarted) {
                downloadChannelMeasurementsUseCase.invoke(channel)
                initialDataLoadStarted = true
            }
            
            let online = channel.channel.status().online
            let on = channel.channel.value?.hiValue() ?? 0 > 0
            let relayValue = channel.channel.value?.asRelayValue()
            let forceSupported = channel.channel.flags & Int64(SUPLA_CHANNEL_FLAG_RELAY_MODE_FORCED_SUPPORTED) != 0
            let forced = relayValue?.mode == .forcedOn || relayValue?.mode == .forcedOff
            let weeklyActive = relayValue?.flags.contains(.weeklyScheduleEnabled) == true
            
            state.online = online
            state.on = on
            state.forceSupported = forceSupported
            state.forceActive = forceSupported && forced
            state.forceButtonDisabled = weeklyActive
            state.lockIconType = lockIconType(forced: forced, weeklyActive: weeklyActive)
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channel.shareable)
            state.showElectricityState = showElectricityState
            state.showImpulseCounterState = showImpulseCounterState
            state.offButtonState = .init(
                icon: getChannelBaseIconUseCase.invoke(iconData: channel.channel.getIconData(state: .default(value: .off))),
                label: Strings.General.turnOff,
                active: !on,
                colors: .errorColors
            )
            state.onButtonState = .init(
                icon: getChannelBaseIconUseCase.invoke(iconData: channel.channel.getIconData(state: .default(value: .on))),
                label: Strings.General.turnOn,
                active: on,
                colors: .primaryColors
            )
            handleOperationButtons(relayValue, channel.channel.flags)
            state.channelCurrentStateData = ChannelCurrentState.Data.from(channel.channel, online, on)
            state.channelProgramState = relayValue?.showProgram(channelProgramState, channel.channel.timerEndDate) ?? []
        }

        private func lockIconType(forced: Bool, weeklyActive: Bool) -> LockIconType {
            return if forced && weeklyActive {
                .temporaryClosed
            } else if forced {
                .closed
            } else {
                .opened
            }
        }

        private func stateValue(online: Bool, on: Bool) -> String {
            if (!online) {
                Strings.SwitchDetail.stateOffline
            } else if (on) {
                Strings.SwitchDetail.stateOn
            } else {
                Strings.SwitchDetail.stateOff
            }
        }

        private func handleOperationButtons(_ relayValue: RelayValue?, _ channelFlags: Int64) {
            let weeklyAllowed = channelFlags & Int64(SUPLA_CHANNEL_FLAG_WEEKLY_SCHEDULE) != 0
            let autoAllowed = channelFlags & Int64(SUPLA_CHANNEL_FLAG_RELAY_MODE_AUTOMATIC_SUPPORTED) != 0
            let weeklyActive = relayValue?.flags.contains(.weeklyScheduleEnabled) == true

            weeklyScheduleEnabled = weeklyActive
            flags = relayValue?.flags ?? []
            state.manualAllowed = weeklyAllowed || autoAllowed
            state.manualActive = !weeklyActive && relayValue?.mode != .automatic
            state.weeklyAllowed = weeklyAllowed
            state.weeklyActive = weeklyActive
            state.autoAllowed = autoAllowed
            state.autoActive = !weeklyActive && relayValue?.mode == .automatic
        }
        
        private func observeGroup(_ remoteId: Int32) {
            observeGroupWithChannelsUseCase.invoke(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] groupWithChannels in
                    self?.handleGroup(groupWithChannels)
                })
                .disposed(by: disposeBag)
        }
        
        private func handleGroup(_ groupWithChannels: ReadGroupWithChannels.GroupWithChannels) {
            let groupState = groupWithChannels.aggregatedState(policy: .onOff)
            
            state.online = true
            state.issues = []
            state.channelCurrentStateData = nil
            state.showElectricityState = false
            state.showImpulseCounterState = false
            state.relatedChannelsData = groupWithChannels.relatedChannelData
            state.offButtonState = .init(
                icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .default(value: .off)),
                label: Strings.General.turnOff,
                active: groupState == .off,
                colors: .errorColors
            )
            state.onButtonState = .init(
                icon: getChannelBaseIconUseCase.stateIcon(groupWithChannels.group, state: .default(value: .on)),
                label: Strings.General.turnOn,
                active: groupState == .on,
                colors: .primaryColors
            )
            state.forceSupported = false
            state.forceActive = false
            state.forceButtonDisabled = false
            state.lockIconType = .opened

            state.manualAllowed = false
            state.manualActive = false
            state.weeklyAllowed = false
            state.weeklyActive = false
            state.autoAllowed = false
            state.autoActive = false
            state.channelProgramState = []
            weeklyScheduleEnabled = false
        }

        private func performAction(action: ActionId) {
            if let remoteId, let type {
                executeSimpleActionUseCase.invoke(action: action, type: type, remoteId: remoteId)
                    .asDriverWithoutError()
                    .drive()
                    .disposed(by: disposeBag)
            }
        }
        
        private func handleDownloadEvents(downloadState: DownloadEventsManagerState?) {
            switch (downloadState) {
            case .inProgress(_), .started:
                electricityState.currentMonthDownloading = true
                impulseCounterState.currentMonthDownloading = true
            default:
                electricityState.currentMonthDownloading = false
                impulseCounterState.currentMonthDownloading = false
            }
        }
    }
}

private func toChannelWithMeasurements(_ channelWithChildren: ChannelWithChildren) -> Observable<(ChannelWithChildren, SummarizedMeasurements?)> {
    @Singleton<LoadElectricityMeterMeasurementsUseCase> var loadElectricityMeterMeasurementsUseCase
    @Singleton<LoadImpulseCounterMeasurementsUseCase> var loadImpulseCounterMeasurementsUseCase
    @Singleton<DateProvider> var dateProvider
    
    return if (channelWithChildren.isOrHasElectricityMeter) {
        loadElectricityMeterMeasurementsUseCase.invoke(
            remoteId: channelWithChildren.channel.remote_id,
            startDate: dateProvider.currentDate().monthStart()
        )
        .map { (channelWithChildren, $0) }
    } else if (channelWithChildren.isOrHasImpulseCounter) {
        loadImpulseCounterMeasurementsUseCase.invoke(
            remoteId: channelWithChildren.channel.remote_id,
            startDate: dateProvider.currentDate().monthStart()
        ).map { (channelWithChildren, $0) }
    } else {
        Observable.just((channelWithChildren, nil))
    }
}
