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

import XCTest
@testable import SUPLA
import SharedCore

final class ExecuteThermostatActionUseCaseTests: UseCaseTest<RequestResult> {
    
    private lazy var useCase: ExecuteThermostatActionUseCase! = { ExecuteThermostatActionUseCaseImpl() }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaClientProvider.self, suplaClientProvider!)
    }
    
    override func tearDown() {
        useCase = nil
        suplaClientProvider = nil
        
        super.tearDown()
    }
    
    func test_executeWithAllParameters() {
        // given
        let type: SubjectType = .channel
        let remoteId: Int32 = 123
        let mode: SuplaHvacMode = .cool
        let setpointTemperatureHeat: Float = 12.2
        let setpointTemperatureCool: Float = 21.4
        let duration: Int32 = 234
        suplaClientProvider.suplaClientMock.executeActionReturns = true
        
        // when
        useCase.invoke(
            type: type,
            remoteId: remoteId,
            mode: mode,
            setpointTemperatureHeat: setpointTemperatureHeat,
            setpointTemperatureCool: setpointTemperatureCool,
            durationInSec: duration
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.success), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, Action.setHvacParameters.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_HVAC_Parameters>.size))
        
        let hvacParametersStruct = parameters.3!.assumingMemoryBound(to: TAction_HVAC_Parameters.self).pointee
        XCTAssertEqual(hvacParametersStruct.DurationSec, UInt32(duration))
        XCTAssertEqual(hvacParametersStruct.Mode, UInt8(mode.value))
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureHeat, setpointTemperatureHeat.toSuplaTemperature())
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureCool, setpointTemperatureCool.toSuplaTemperature())
        XCTAssertEqual(hvacParametersStruct.Flags, 3)
    }
    
    func test_executeModeOnly() {
        // given
        let type: SubjectType = .channel
        let remoteId: Int32 = 123
        let mode: SuplaHvacMode = .cool
        
        // when
        useCase.invoke(
            type: type,
            remoteId: remoteId,
            mode: mode,
            setpointTemperatureHeat: nil,
            setpointTemperatureCool: nil,
            durationInSec: nil
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.failure), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, Action.setHvacParameters.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_HVAC_Parameters>.size))
        
        let hvacParametersStruct = parameters.3!.assumingMemoryBound(to: TAction_HVAC_Parameters.self).pointee
        XCTAssertEqual(hvacParametersStruct.DurationSec, 0)
        XCTAssertEqual(hvacParametersStruct.Mode, UInt8(mode.value))
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureHeat, 0)
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureCool, 0)
        XCTAssertEqual(hvacParametersStruct.Flags, 0)
    }
    
    func test_executeSetpointHeatOnly() {
        // given
        let type: SubjectType = .channel
        let remoteId: Int32 = 123
        let setpointTemperatureHeat: Float = 12.2
        suplaClientProvider.suplaClientMock.executeActionReturns = true
        
        // when
        useCase.invoke(
            type: type,
            remoteId: remoteId,
            mode: nil,
            setpointTemperatureHeat: setpointTemperatureHeat,
            setpointTemperatureCool: nil,
            durationInSec: nil
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.success), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, Action.setHvacParameters.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_HVAC_Parameters>.size))
        
        let hvacParametersStruct = parameters.3!.assumingMemoryBound(to: TAction_HVAC_Parameters.self).pointee
        XCTAssertEqual(hvacParametersStruct.DurationSec, 0)
        XCTAssertEqual(hvacParametersStruct.Mode, 0)
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureHeat, setpointTemperatureHeat.toSuplaTemperature())
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureCool, 0)
        XCTAssertEqual(hvacParametersStruct.Flags, 1)
    }
    
    func test_executeSetpointCoolOnly() {
        // given
        let type: SubjectType = .channel
        let remoteId: Int32 = 123
        let setpointTemperatureCool: Float = 21.4
        
        // when
        useCase.invoke(
            type: type,
            remoteId: remoteId,
            mode: nil,
            setpointTemperatureHeat: nil,
            setpointTemperatureCool: setpointTemperatureCool,
            durationInSec: nil
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.failure), .completed])
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, Action.setHvacParameters.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_HVAC_Parameters>.size))
        
        let hvacParametersStruct = parameters.3!.assumingMemoryBound(to: TAction_HVAC_Parameters.self).pointee
        XCTAssertEqual(hvacParametersStruct.DurationSec, 0)
        XCTAssertEqual(hvacParametersStruct.Mode, 0)
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureHeat, 0)
        XCTAssertEqual(hvacParametersStruct.SetpointTemperatureCool, setpointTemperatureCool.toSuplaTemperature())
        XCTAssertEqual(hvacParametersStruct.Flags, 2)
    }
}
