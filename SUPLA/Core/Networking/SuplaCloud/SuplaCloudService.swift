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

protocol SuplaCloudService {
    func getInitialMeasurements(
        remoteId: Int32
    ) -> Observable<(response: HTTPURLResponse, data: Data)>
    
    func getTemperatureMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureMeasurement]>
    
    func getTemperatureAndHumidityMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]>
    
    func getGeneralPurposeMeasurement(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.GeneralPurposeMeasurement]>
    
    func getGeneralPurposeMeter(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.GeneralPurposeMeter]>
}

final class SuplaCloudServiceImpl: SuplaCloudService {
    @Singleton<RequestHelper> private var requestHelper
    @Singleton<SuplaCloudConfigHolder> private var configHolder
    
    func getInitialMeasurements(
        remoteId: Int32
    ) -> Observable<(response: HTTPURLResponse, data: Data)> {
        do {
            return requestHelper.getOAuthRequest(urlString: try buildInitialMeasurementsUrl(remoteId))
        } catch {
            return Observable.error(error)
        }
    }
    
    func getTemperatureMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureMeasurement]> {
        do {
            return requestHelper.getOAuthRequest(urlString: try buildMeasurementsUrl(remoteId, afterTimestamp))
                .flatMap { (response, data) in
                    if (response.statusCode != 200) {
                        return Observable<[SuplaCloudClient.TemperatureMeasurement]>
                            .error(SuplaCloudError.statusCodeNoSuccess(code: response.statusCode))
                    }
                    
                    do {
                        let measurements = try SuplaCloudClient.TemperatureMeasurement.fromJson(data: data)
                        return Observable.just(measurements)
                    } catch {
                        return Observable.error(error)
                    }
                }
        } catch {
            return Observable.error(error)
        }
    }
    
    func getTemperatureAndHumidityMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]> {
        do {
            return requestHelper.getOAuthRequest(urlString: try buildMeasurementsUrl(remoteId, afterTimestamp))
                .flatMap { (response, data) in
                    if (response.statusCode != 200) {
                        return Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]>
                            .error(SuplaCloudError.statusCodeNoSuccess(code: response.statusCode))
                    }
                    
                    do {
                        let measurements = try SuplaCloudClient.TemperatureAndHumidityMeasurement
                            .fromJson(data: data)
                        return Observable.just(measurements)
                    } catch {
                        return Observable.error(error)
                    }
                }
        } catch {
            return Observable.error(error)
        }
    }
    
    func getGeneralPurposeMeasurement(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.GeneralPurposeMeasurement]> {
        do {
            return requestHelper.getOAuthRequest(urlString: try buildMeasurementsUrl(remoteId, afterTimestamp))
                .flatMap { (response, data) in
                    if (response.statusCode != 200) {
                        return Observable<[SuplaCloudClient.GeneralPurposeMeasurement]>
                            .error(SuplaCloudError.statusCodeNoSuccess(code: response.statusCode))
                    }
                    
                    do {
                        let measurements = try SuplaCloudClient.GeneralPurposeMeasurement.fromJson(data: data)
                        return Observable.just(measurements)
                    } catch {
                        return Observable.error(error)
                    }
                }
        } catch {
            return Observable.error(error)
        }
    }
    
    func getGeneralPurposeMeter(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.GeneralPurposeMeter]> {
        do {
            return requestHelper.getOAuthRequest(urlString: try buildMeasurementsUrl(remoteId, afterTimestamp))
                .flatMap { (response, data) in
                    if (response.statusCode != 200) {
                        return Observable<[SuplaCloudClient.GeneralPurposeMeter]>
                            .error(SuplaCloudError.statusCodeNoSuccess(code: response.statusCode))
                    }
                    
                    do {
                        let measurements = try SuplaCloudClient.GeneralPurposeMeter.fromJson(data: data)
                        return Observable.just(measurements)
                    } catch {
                        return Observable.error(error)
                    }
                }
        } catch {
            return Observable.error(error)
        }
    }
    
    private func buildMeasurementsUrl(_ remoteId: Int32, _ afterTimestamp: TimeInterval) throws -> String {
        let host = try configHolder.requireUrl()
        let urlPath = Constants.urlMeasurements.replacingOccurrences(of: "{remoteId}", with: "\(remoteId)")
        return "\(host)\(urlPath)\(Int(afterTimestamp))"
    }
    
    private func buildInitialMeasurementsUrl(_ remoteId: Int32) throws -> String {
        let host = try configHolder.requireUrl()
        let urlPath = Constants.urlInitialMeasurements.replacingOccurrences(of: "{remoteId}", with: "\(remoteId)")
        return "\(host)\(urlPath)"
    }
    
    fileprivate enum Constants {
        static let apiVersion = "2.2.0"
        
        static let urlInitialMeasurements = "/api/\(apiVersion)/channels/{remoteId}/measurement-logs?order=ASC&limit=2&offset=0"
        
        static let urlMeasurements = "/api/\(apiVersion)/channels/{remoteId}/measurement-logs?order=ASC&limit=5000&afterTimestamp="
    }
}

enum SuplaCloudError: Error {
    case urlIsNull
    case statusCodeNoSuccess(code: Int)
}
