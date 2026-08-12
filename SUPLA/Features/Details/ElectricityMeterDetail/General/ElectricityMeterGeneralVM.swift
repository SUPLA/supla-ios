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
    class ViewModel: SuplaCore.ViewModel<ViewState> {
        @Singleton private var settings: GlobalSettings
        @Singleton private var dateProvider: DateProvider
        @Singleton private var downloadEventsManager: DownloadEventsManager
        @Singleton private var readChannelWithChildrenUseCase: ReadChannelWithChildrenUseCase
        @Singleton private var downloadChannelMeasurementsUseCase: DownloadChannelMeasurementsUseCase
        @Singleton private var electricityMeterGeneralStateHandler: ElectricityMeterGeneralStateHandler
        @Singleton private var loadElectricityMeterMeasurementsUseCase: LoadElectricityMeterMeasurementsUseCase
        
        private let item: ItemBundle

        init(item: ItemBundle) {
            self.item = item
            super.init(
                state: ViewState(),
                eventSelector: #selector(handleValueChange(notification:)),
                eventName: NSNotification.Name.saChannelValueChanged
            )
        }

        override func onViewCreated() {
            downloadEventsManager.observeProgress(remoteId: item.remoteId)
                .asDriverWithoutError()
                .drive(onNext: { [weak self] in self?.handleDownloadEvents(downloadState: $0) })
                .disposed(by: disposeBag)
        }

        override func onViewAppear() {
            loadData()
        }
        
        @objc
        private func handleValueChange(notification: Notification) {
            if let isGroup = notification.userInfo?["isGroup"] as? NSNumber,
               let remoteId = notification.userInfo?["remoteId"] as? NSNumber,
               !isGroup.boolValue,
               remoteId.int32Value == item.remoteId
            {
                loadData()
            }
        }

        private func loadData(downloadingFinished: Bool = false) {
            Observable.zip(
                readChannelWithChildrenUseCase.invoke(remoteId: item.remoteId),
                loadElectricityMeterMeasurementsUseCase.invoke(
                    remoteId: item.remoteId,
                    startDate: dateProvider.currentDate().monthStart()
                )
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
                if (state.remoteId != nil) {
                    loadData(downloadingFinished: true)
                }
            }
        }
    }
}
