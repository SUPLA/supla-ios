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
    var returns: Observable<SUPLA.ChannelWithChildren> = Observable.empty()
    var parameters: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<SUPLA.ChannelWithChildren> {
        parameters.append(remoteId)
        return returns
    }
}

final class ReadChannelWithChildrenTreeUseCaseMock: ReadChannelWithChildrenTreeUseCase {
    var returns: Observable<SUPLA.ChannelWithChildren> = Observable.empty()
    var parameters: [Int32] = []
    func invoke(remoteId: Int32) -> Observable<SUPLA.ChannelWithChildren> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadChannelMeasurementsUseCaseMock: DownloadChannelMeasurementsUseCase {
    var parameters: [SUPLA.ChannelWithChildren] = []
    func invoke(_ channelWithChildren: SUPLA.ChannelWithChildren, type: SUPLA.DownloadEventsManagerDataType) {
        parameters.append(channelWithChildren)
    }
}

final class LoadChannelMeasurementsUseCaseMock: LoadChannelMeasurementsUseCase {
    var parameters: [(Int32, ChartDataSpec)] = []
    var returns: Observable<ChannelChartSets> = Observable.empty()
    func invoke(remoteId: Int32, spec: ChartDataSpec) -> Observable<ChannelChartSets> {
        parameters.append((remoteId, spec))
        return returns
    }
}

final class LoadChannelMeasurementsDateRangeUseCaseMock: LoadChannelMeasurementsDateRangeUseCase {
    var parameters: [Int32] = []
    var returns: Observable<DaysRange?> = Observable.empty()
    func invoke(remoteId: Int32, type: SUPLA.DownloadEventsManagerDataType) -> Observable<DaysRange?> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadTemperatureMeasurementsUseCaseMock: DownloadTemperatureLogUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadTempHumidityMeasurementsUseCaseMock: DownloadTempHumidityLogUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}

final class GetChannelValueStringUseCaseMock: GetChannelValueStringUseCase {
    var parameters: [(SAChannel, ValueType, Bool)] = []
    var returns: String = ""
    func invoke(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        parameters.append((channel, valueType, withUnit))
        return returns
    }
    
    var valueOrNilMock: FunctionMock<(SAChannel, SUPLA.ValueType, Bool), String?> = .init()
    func valueOrNil(_ channel: SAChannel, valueType: SUPLA.ValueType, withUnit: Bool) -> String? {
        valueOrNilMock.set((channel, valueType, withUnit))
        return valueOrNilMock.get()
    }
}

final class DownloadGeneralPurposeMeasurementLogUseCaseMock: DownloadGeneralPurposeMeasurementLogUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}

final class DownloadGeneralPurposeMeterLogUseCaseMock: DownloadGeneralPurposeMeterLogUseCase {
    var parameters: [Int32] = []
    var returns: Observable<Float> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<Float> {
        parameters.append(remoteId)
        return returns
    }
}

final class LoadChannelConfigUseCaseMock: LoadChannelConfigUseCase {
    var parameters: [Int32] = []
    var returns: Observable<SuplaChannelConfig?> = Observable.empty()
    func invoke(remoteId: Int32) -> Observable<SuplaChannelConfig?> {
        parameters.append(remoteId)
        return returns
    }
}

// MARK: - Channel Values Formatter Mocks -

final class ChannelValueFormatterMock: ChannelValueFormatter {
    var handleParameters: [Int32] = []
    var handleReturns: Bool = false
    func handle(function: Int32) -> Bool {
        handleParameters.append(function)
        return handleReturns
    }
    
    var formatParameters: [(Any, Bool, ChannelValuePrecision, Any?)] = []
    var formatReturns: String = ""
    func format(_ value: Any, withUnit: Bool, precision: ChannelValuePrecision, custom: Any?) -> String {
        formatParameters.append((value, withUnit, precision, custom))
        return formatReturns
    }
}
