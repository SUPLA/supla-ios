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

@testable import SUPLA

final class CreateProfileChannelsListUseCaseMock: CreateProfileChannelsListUseCase {
    
    var observable: Observable<[List]> = Observable.empty()
    var invokeCounter = 0
    
    func invoke() -> Observable<[List]> {
        invokeCounter += 1
        return observable
    }
}

final class SwapChannelPositionsUseCaseMock: SwapChannelPositionsUseCase {
    
    var observable: Observable<Void> = Observable.empty()
    var firstRemoteIdArray: [Int32] = []
    var secondRemoteIdArray: [Int32] = []
    var locationCaptionArray: [String] = []
    
    func invoke(firstRemoteId: Int32, secondRemoteId: Int32, locationCaption: String) -> Observable<Void> {
        firstRemoteIdArray.append(firstRemoteId)
        secondRemoteIdArray.append(secondRemoteId)
        locationCaptionArray.append(locationCaption)
        
        return observable
    }
}

final class GetChannelConfigUseCaseMock: GetChannelConfigUseCase {
    
    var parameters: [(Int32, ChannelConfigType)] = []
    var returns: Observable<RequestResult> = Observable.empty()
    func invoke(remoteId: Int32, type: ChannelConfigType) -> Observable<RequestResult> {
        parameters.append((remoteId, type))
        return returns
    }
}

final class ReadChannelByRemoteIdUseCaseMock: ReadChannelByRemoteIdUseCase {
    
    var returns: Observable<SAChannel> = Observable.empty()
    var remoteIdArray: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<SAChannel> {
        remoteIdArray.append(remoteId)
        return returns
    }
}

final class ReadChannelWithChildrenUseCaseMock: ReadChannelWithChildrenUseCase {
    var returns: Observable<ChannelWithChildren> = Observable.empty()
    var parameters: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<ChannelWithChildren> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadChannelMeasurementsUseCaseMock: DownloadChannelMeasurementsUseCase {
    var parameters: [(Int32, Int32)] = []
    func invoke(remoteId: Int32, function: Int32) {
        parameters.append((remoteId, function))
    }
}

final class LoadChannelMeasurementsUseCaseMock: LoadChannelMeasurementsUseCase {
    var parameters: [(Int32, Date, Date, ChartDataAggregation)] = []
    var returns: Observable<[HistoryDataSet]> = Observable.empty()
    func invoke(remoteId: Int32, startDate: Date, endDate: Date, aggregation: ChartDataAggregation) -> Observable<[HistoryDataSet]> {
        parameters.append((remoteId, startDate, endDate, aggregation))
        return returns
    }
}

final class LoadChannelMeasurementsDateRangeUseCaseMock: LoadChannelMeasurementsDateRangeUseCase {
    var parameters: [Int32] = []
    var returns: Observable<DaysRange?> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<DaysRange?> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadTemperatureMeasurementsUseCaseMock: DownloadTemperatureMeasurementsUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadTempHumidityMeasurementsUseCaseMock: DownloadTempHumidityMeasurementsUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}
