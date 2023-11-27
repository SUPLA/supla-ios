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

final class ThermostatHistoryDetailVM: BaseHistoryDetailVM {
    
    @Singleton<DownloadEventsManager> private var downloadEventsManager
    @Singleton<ReadChannelWithChildrenUseCase> private var readChannelWithChildrenUseCase
    @Singleton<DownloadChannelMeasurementsUseCase> private var downloadChannelMeasurementsUseCase
    @Singleton<LoadChannelWithChildrenMeasurementsUseCase> private var loadChannelWithChildrenMeasurementsUseCase
    @Singleton<LoadChannelWithChildrenMeasurementsDateRangeUseCase> private var loadChannelWithChildrenMeasurementsDateRangeUseCase
    
    override func measurementsObservable(remoteId: Int32, start: Date, end: Date, aggregation: ChartDataAggregation) -> Observable<([HistoryDataSet], DaysRange?)> {
        Observable.zip(
            loadChannelWithChildrenMeasurementsUseCase.invoke(remoteId: remoteId, startDate: start, endDate: end, aggregation: aggregation),
            loadChannelWithChildrenMeasurementsDateRangeUseCase.invoke(remoteId: remoteId)
        ) { ($0, $1) }
    }
    
    override func triggerDataLoad(remoteId: Int32) {
        Observable.zip(
            readChannelWithChildrenUseCase.invoke(remoteId: remoteId),
            profileRepository.getActiveProfile().map {
                self.userStateHolder.getTemperatureChartState(profileId: $0.idString, remoteId: remoteId)
            }
        ) { ($0, $1) }
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] in self?.handleData(channel: $0.0, chartState: $0.1) }
            )
            .disposed(by: self)
    }
    
    private func handleData(channel: ChannelWithChildren, chartState: TemperatureChartState) {
        updateView { $0.changing(path: \.profileId, to: channel.channel.profile.idString) }
        
        if (channel.children.filter({ $0.relationType.isThermometer()}).isEmpty) {
            updateView { $0.changing(path: \.loading, to: false) }
        } else {
            restoreRange(chartState: chartState)
            configureDownloadObserver(channel: channel)
            startInitialDataLoad(channel: channel)
        }
    }
    
    private func configureDownloadObserver(channel: ChannelWithChildren) {
        if (currentState()?.downloadConfigured == true) {
            // Needs to be performed only once
            return
        }
        updateView { $0.changing(path: \.downloadConfigured, to: true) }
        
        let mainThermometerId = channel.children.first { $0.relationType == .mainThermometer }?.channel.remote_id
        let auxThermometerId = channel.children.first { $0.relationType.isAux() }?.channel.remote_id
        
        var observables: [Observable<DownloadEventsManagerState>] = []
        if let id = mainThermometerId { observables.append(downloadEventsManager.observeProgress(remoteId: id)) }
        if let id = auxThermometerId { observables.append(downloadEventsManager.observeProgress(remoteId: id)) }
        
        let observable: Observable<(DownloadEventsManagerState, DownloadEventsManagerState?)> = switch (observables.count) {
        case 2: Observable.combineLatest(observables[0], observables[1]) { ($0, $1) }
        case 1: observables[0].map { ($0, nil) }
        default: Observable.empty()
        }
        
        observable.subscribe(on: ConcurrentMainScheduler.instance)
            .map { self.mergeEvents(main: $0.0, aux: $0.1) }
            .distinctUntilChanged()
            .asDriverWithoutError()
            .drive(onNext: { self.handleDownloadEvents(downloadState: $0) })
            .disposed(by: self)
    }
    
    private func startInitialDataLoad(channel: ChannelWithChildren) {
        if (currentState()?.initialLoadStarted == true) {
            return
        }
        updateView { $0.changing(path: \.initialLoadStarted, to: true) }
        
        let mainThermometer = channel.children.first { $0.relationType == .mainThermometer }?.channel
        let auxThermometer = channel.children.first { $0.relationType.isAux() }?.channel
        
        if let main = mainThermometer {
            downloadChannelMeasurementsUseCase.invoke(remoteId: main.remote_id, function: main.func)
        }
        if let aux = auxThermometer {
            downloadChannelMeasurementsUseCase.invoke(remoteId: aux.remote_id, function: aux.func)
        }
    }
    
    private func mergeEvents(main: DownloadEventsManagerState, aux: DownloadEventsManagerState?) -> DownloadEventsManagerState {
        guard let aux = aux else { return main }
        
        return if (main == aux) {
            if (main.isInProgress() && main.getProgress() > aux.getProgress()) {
                aux
            } else {
                main
            }
        } else if (main.order < aux.order) {
            main
        } else {
            aux
        }
    }
}
