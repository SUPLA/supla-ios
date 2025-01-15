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

extension ElectricityMeterGeneralFeature {
    class ViewModel: SuplaCore.BaseViewModel<ViewState> {
        @Singleton private var settings: GlobalSettings
        @Singleton private var dateProvider: DateProvider
        @Singleton private var downloadEventsManager: DownloadEventsManager
        @Singleton private var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCase
        @Singleton private var downloadChannelMeasurementsUseCase: DownloadChannelMeasurementsUseCase
        @Singleton private var electricityMeterGeneralStateHandler: ElectricityMeterGeneralStateHandler
        @Singleton private var loadElectricityMeterMeasurementsUseCase: LoadElectricityMeterMeasurementsUseCase
        
        init() {
            super.init(state: ViewState())
        }
        
        func observerDownload(_ remoteId: Int32) {
            downloadEventsManager.observeProgress(remoteId: remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
                .disposed(by: disposeBag)
        }
        
        func loadData(_ remoteId: Int32, downloadingFinished: Bool = false) {
            Observable.zip(
                readChannelWithChildrenUseCase.invoke(remoteId: remoteId),
                loadElectricityMeterMeasurementsUseCase.invoke(remoteId: remoteId, startDate: dateProvider.currentDate().monthStart())
            ) { channel, measurements in (channel, measurements) }
                .asDriverWithoutError()
                .drive(onNext: { [weak self] channel, measurements in
                    self?.handleChannel(channel, measurements, downloadingFinished)
                })
                .disposed(by: disposeBag)
        }
        
        func onIntroductionClose() {
            settings.showEmGeneralIntroduction = false
        }
        
        private func handleChannel(
            _ channel: ChannelWithChildren,
            _ measurements: ElectricityMeasurements,
            _ downloadingFinished: Bool
        ) {
            if (!state.initialDataLoadStarted) {
                downloadChannelMeasurementsUseCase.invoke(channel)
            }
            state.remoteId = channel.remoteId
            state.initialDataLoadStarted = true
            if (downloadingFinished) {
                state.currentMonthDownloading = false
            }
            electricityMeterGeneralStateHandler.updateState(state, channel, measurements)
        }
        
        private func handleDownloadEvents(downloadState: DownloadEventsManagerState?) {
            switch (downloadState) {
            case .inProgress(_), .started:
                state.currentMonthDownloading = true
            default:
                if let remoteId = state.remoteId {
                    loadData(remoteId, downloadingFinished: true)
                }
            }
        }
    }
}
