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

class SwitchGeneralVM: BaseViewModel<SwitchGeneralViewState, SwitchGeneralViewEvent>, DeviceStateHelperVMI {
    @Singleton<ElectricityMeterGeneralStateHandler> private var electricityMeterGeneralStateHandler
    @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<ExecuteSimpleActionUseCase> private var executeSimpleActionUseCase
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<DateProvider> private var dateProvider
    @Singleton<GlobalSettings> private var settings

    var electricityState: ElectricityMeterGeneralState = .init()

    override func defaultViewState() -> SwitchGeneralViewState { SwitchGeneralViewState() }
    
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
            .disposed(by: self)
    }

    func turnOn(remoteId: Int32) {
        performAction(action: .turnOn, remoteId: remoteId)
    }

    func turnOff(remoteId: Int32) {
        performAction(action: .turnOff, remoteId: remoteId)
    }
    
    func onIntroductionClose() {
        settings.showEmGeneralIntroduction = false
    }
    
    private func handleChannel(_ channel: ChannelWithChildren, _ measurements: ElectricityMeasurements?, _ downloadingFinished: Bool) {
        let showElectricityState = channel.channel.isElectricityMeter() || channel.hasElectricityMeter

        if (showElectricityState) {
            electricityMeterGeneralStateHandler.updateState(self.electricityState, channel, measurements)
        }
        if (downloadingFinished) {
            electricityState.currentMonthDownloading = false
        }
        
        updateView() {
            if (!$0.initialDataLoadStarted) {
                downloadChannelMeasurementsUseCase.invoke(remoteId: channel.remoteId, function: channel.function)
            }
            
            return $0
                .changing(path: \.remoteId, to: channel.remoteId)
                .changing(path: \.deviceState, to: self.createDeviceState(from: channel.channel))
                .changing(path: \.showButtons, to: channel.channel.switchWithButtons())
                .changing(path: \.showElectricityState, to: showElectricityState)
                .changing(path: \.initialDataLoadStarted, to: true)
        }
    }

    private func performAction(action: Action, remoteId: Int32) {
        executeSimpleActionUseCase.invoke(action: action, type: .channel, remoteId: remoteId)
            .asDriverWithoutError()
            .drive()
            .disposed(by: self)
    }
    
    private func handleDownloadEvents(downloadState: DownloadEventsManagerState?) {
        switch (downloadState) {
        case .inProgress(_), .started:
            electricityState.currentMonthDownloading = true
        default:
            if let remoteId = currentState()?.remoteId {
                loadChannel(remoteId: remoteId, downloadingFinished: true)
            }
        }
    }
}

private func toChannelWithMeasurements(_ channelWithChildren: ChannelWithChildren) -> Observable<(ChannelWithChildren, ElectricityMeasurements?)> {
    @Singleton<LoadElectricityMeterMeasurementsUseCase> var loadElectricityMeterMeasurementsUseCase
    @Singleton<DateProvider> var dateProvider
    
    return if (channelWithChildren.hasElectricityMeter) {
        loadElectricityMeterMeasurementsUseCase.invoke(
            remoteId: channelWithChildren.channel.remote_id,
            startDate: dateProvider.currentDate().monthStart()
        )
        .map { (channelWithChildren, $0) }
    } else {
        Observable.just((channelWithChildren, nil))
    }
}

enum SwitchGeneralViewEvent: ViewEvent {}

struct SwitchGeneralViewState: ViewState {
    var remoteId: Int32? = nil
    var initialDataLoadStarted: Bool = false
    
    var deviceState: DeviceStateViewState? = nil
    var showButtons: Bool = false
    var showElectricityState: Bool = false
}
