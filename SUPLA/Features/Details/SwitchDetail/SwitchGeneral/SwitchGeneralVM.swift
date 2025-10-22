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
    class ViewModel: SuplaCore.BaseViewModel<ViewState>, ChannelUpdatesObserver {
        @Singleton<ElectricityMeterGeneralStateHandler> private var electricityMeterGeneralStateHandler
        @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
        @Singleton<ImpulseCounterGeneralStateHandler> private var impulseCounterGeneralStateHandler
        @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
        @Singleton<GetAllChannelIssuesUseCase> private var getAllChannelIssuesUseCase
        @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
        @Singleton<DownloadEventsManager> private var downloadEventsManager
        @Singleton<DateProvider> private var dateProvider
        @Singleton<GlobalSettings> private var settings
        @Singleton<GetChannelBaseIconUseCase> private var getChannelBaseIconUseCase

        var electricityState = ElectricityMeterGeneralState()
        var impulseCounterState = ImpulseCounterGeneralState()
        
        private var remoteId: Int32? = nil
        private var initialDataLoadStarted: Bool = false
        private var flags: [SuplaRelayFlag] = []
        
        init() {
            super.init(state: ViewState())
        }
     
        func observerDownload(_ remoteId: Int32) {
            downloadEventsManager.observeProgress(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
                .disposed(by: disposeBag)
        }

        func loadChannel(remoteId: Int32, downloadingFinished: Bool = false) {
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId)
                .flatMapFirst { toChannelWithMeasurements($0) }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleChannel($0.0, $0.1, downloadingFinished) })
                .disposed(by: disposeBag)
        }

        func turnOn(remoteId: Int32) {
            if (flags.contains(.overcurrentRelayOff)) {
                state.alertDialogState = SuplaCore.AlertDialogState(
                    header: Strings.General.warning,
                    message: Strings.SwitchDetail.overcurrentQuestion,
                    positiveButtonText: Strings.General.yes,
                    negativeButtonText: Strings.General.no
                )
            } else {
                performAction(action: .turnOn, remoteId: remoteId)
            }
        }
        
        func forceTurnOnAction(remoteId: Int32) {
            state.alertDialogState = nil
            performAction(action: .turnOn, remoteId: remoteId)
        }

        func turnOff(remoteId: Int32) {
            performAction(action: .turnOff, remoteId: remoteId)
        }
        
        func onIntroductionClose() {
            settings.showEmGeneralIntroduction = false
            electricityState.showIntroduction = false
        }
        
        func closeAlertDialog() {
            state.alertDialogState = nil
        }
        
        func onChannelUpdate(_ channelWithChildren: ChannelWithChildren) {
            loadChannel(remoteId: channelWithChildren.remoteId)
        }
        
        private func handleChannel(_ channel: ChannelWithChildren, _ measurements: SummarizedMeasurements?, _ downloadingFinished: Bool) {
            let showElectricityState = channel.isOrHasElectricityMeter
            let showImpulseCounterState = channel.isOrHasImpulseCounter

            if (showElectricityState) {
                electricityMeterGeneralStateHandler.updateState(electricityState, channel, measurements as? ElectricityMeasurements)
            }
            if (showImpulseCounterState) {
                impulseCounterGeneralStateHandler.updateState(impulseCounterState, channel, measurements as? ImpulseCounterMeasurements)
            }
            if (downloadingFinished) {
                electricityState.currentMonthDownloading = false
                impulseCounterState.currentMonthDownloading = false
            }
            
            if (initialDataLoadStarted) {
                downloadChannelMeasurementsUseCase.invoke(channel)
                initialDataLoadStarted = true
            }
            
            let online = channel.channel.status().online
            let on = channel.channel.value?.hiValue() ?? 0 > 0
            
            remoteId = channel.remoteId
            flags = channel.channel.value?.asRelayValue().flags ?? []
            state.online = online
            state.on = on
            state.stateValue =
                if (!online) {
                    Strings.SwitchDetail.stateOffline
                } else if (on) {
                    Strings.SwitchDetail.stateOn
                } else {
                    Strings.SwitchDetail.stateOff
                }
            state.issues = getAllChannelIssuesUseCase.invoke(channelWithChildren: channel.shareable)
            state.stateLabel = createStateLabel(channel.channel)
            state.stateIcon = getChannelBaseIconUseCase.invoke(channel: channel.channel)
            state.showElectricityState = showElectricityState
            state.showImpulseCounterState = showImpulseCounterState
            state.offButtonState = .init(
                icon: getChannelBaseIconUseCase.invoke(iconData: channel.channel.getIconData(state: .off)),
                label: Strings.General.turnOff,
                active: !on,
                type: .negative
            )
            state.onButtonState = .init(
                icon: getChannelBaseIconUseCase.invoke(iconData: channel.channel.getIconData(state: .on)),
                label: Strings.General.turnOn,
                active: on,
                type: .positive
            )
        }
        
        private func createStateLabel(_ channel: SAChannel) -> String {
            if
                let state = channel.ev?.timerState,
                let timerEndTime = state.countdownEndsAt,
                timerEndTime.timeIntervalSince1970 > dateProvider.currentTimestamp()
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Strings.General.hourFormat
                let dateString = dateFormatter.string(from: timerEndTime)
                    
                return .init(format: Strings.SwitchDetail.stateLabelForTimer, dateString)
            }
            
            return Strings.SwitchDetail.stateLabel
        }

        private func performAction(action: Action, remoteId: Int32) {
            executeSimpleActionUseCase.invoke(action: action, type: .channel, remoteId: remoteId)
                .asDriverWithoutError()
                .drive()
                .disposed(by: disposeBag)
        }
        
        private func handleDownloadEvents(downloadState: DownloadEventsManagerState?) {
            switch (downloadState) {
            case .inProgress(_), .started:
                electricityState.currentMonthDownloading = true
                impulseCounterState.currentMonthDownloading = true
            default:
                if let remoteId {
                    loadChannel(remoteId: remoteId, downloadingFinished: true)
                }
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
