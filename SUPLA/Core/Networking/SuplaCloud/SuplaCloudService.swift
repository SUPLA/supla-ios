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
}

final class SuplaCloudServiceImpl: SuplaCloudService {
    
    @Singleton<RequestHelper> private var requestHelper
    @Singleton<SuplaCloudConfigHolder> private var configHolder
    
    func getInitialMeasurements(
        remoteId: Int32
    ) -> Observable<(response: HTTPURLResponse, data: Data)> {
        
        guard let host = configHolder.url else {
            return Observable.error(SuplaCloudError.urlIsNull)
        }
        
        let urlPath = Constants.urlInitialMeasurements
            .replacingOccurrences(of: "{remoteId}", with: "\(remoteId)")
        let urlString = "\(host)\(urlPath)"
        
        return requestHelper.getOAuthRequest(urlString: urlString)
    }
    
    func getTemperatureMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureMeasurement]> {
        guard let host = configHolder.url else {
            return Observable.error(SuplaCloudError.urlIsNull)
        }
        
        let urlPath = Constants.urlMeasurements
            .replacingOccurrences(of: "{remoteId}", with: "\(remoteId)")
        let urlString = "\(host)\(urlPath)\(afterTimestamp)"
        
        return requestHelper.getOAuthRequest(urlString: urlString)
            .flatMap { (response, data) in
                if (response.statusCode != 200) {
                    return Observable<[SuplaCloudClient.TemperatureMeasurement]>
                        .error(SuplaCloudError.statusCodeNoSuccess)
                }
                
                do {
                    let measurements = try SuplaCloudClient.TemperatureMeasurement.fromJson(data: data)
                    return Observable.just(measurements)
                } catch {
                    return Observable.error(error)
                }
            }
    }
    
    func getTemperatureAndHumidityMeasurements(
        remoteId: Int32,
        afterTimestamp: TimeInterval
    ) -> Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]> {
        guard let host = configHolder.url else {
            return Observable.error(SuplaCloudError.urlIsNull)
        }
        
        let urlPath = Constants.urlMeasurements
            .replacingOccurrences(of: "{remoteId}", with: "\(remoteId)")
        let urlString = "\(host)\(urlPath)\(afterTimestamp)"
        
        return requestHelper.getOAuthRequest(urlString: urlString)
            .flatMap { (response, data) in
                if (response.statusCode != 200) {
                    return Observable<[SuplaCloudClient.TemperatureAndHumidityMeasurement]>
                        .error(SuplaCloudError.statusCodeNoSuccess)
                }
                
                do {
                    let measurements = try SuplaCloudClient.TemperatureAndHumidityMeasurement
                        .fromJson(data: data)
                    return Observable.just(measurements)
                } catch {
                    return Observable.error(error)
                }
            }
    }
    
    fileprivate struct Constants {
        static let apiVersion = "2.2.0"
        
        static let urlInitialMeasurements = "/api/\(apiVersion)/channels/{remoteId}/measurement-logs?order=ASC&limit=2&offset=0"
        
        static let urlMeasurements = "/api/\(apiVersion)/channels/{remoteId}/measurement-logs?order=ASC&limit=5000&afterTimestamp="
    }
}

enum SuplaCloudError: Error {
    case urlIsNull
    case statusCodeNoSuccess
}
