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

final class SetChannelConfigUseCaseTests: UseCaseTest<RequestResult> {
    
    private lazy var useCase: SetChannelConfigUseCase! = { SetChannelConfigUseCaseImpl() }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaClientProvider.self, component: suplaClientProvider!)
    }
    
    override func tearDown() {
        useCase = nil
        suplaClientProvider = nil
        
        super.tearDown()
    }
    
    func test_shouldBrakeWithFatalError_whenConfigNotWeeklySchedule() {
        expectFatalError(expectedMessage: "Trying to set config which is not supported for SUPLA.SuplaChannelConfig") {
            _ = self.useCase.invoke(
                remoteId: 123,
                config: SuplaChannelConfig(remoteId: 123)
            )
        }
    }
    
    func test_shouldSetWeeklyScheduleConfig() {
        // given
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig(
            remoteId: 123,
            channelFunc: nil,
            programConfigurations: [
                SuplaWeeklyScheduleProgram(
                    program: .program1,
                    mode: .cool,
                    setpointTemperatureHeat: nil,
                    setpointTemperatureCool: 1200
                )
            ],
            schedule: [
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: .sunday,
                    hour: 0,
                    quarterOfHour: .first,
                    program: .program2
                ),
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: .sunday,
                    hour: 0,
                    quarterOfHour: .second,
                    program: .program2
                )
            ]
        )
        
        // when
        useCase.invoke(remoteId: 123, config: weeklyConfig).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(.failure), .completed])
        
        XCTAssertEqual(suplaClientProvider.suplaClientMock.setChannelConfigParameters.count, 1)
        var parameters = suplaClientProvider.suplaClientMock.setChannelConfigParameters[0].pointee
        XCTAssertEqual(parameters.ChannelId, 123)
        XCTAssertEqual(parameters.ConfigType, UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE))
        XCTAssertEqual(parameters.ConfigSize, UInt16(MemoryLayout<TChannelConfig_WeeklySchedule>.size))
        
        let config = extract(pointee: &(parameters.Config))
        XCTAssertEqual(config.Program.0.Mode, SuplaHvacMode.cool.rawValue)
        XCTAssertEqual(config.Program.0.SetpointTemperatureHeat, 0)
        XCTAssertEqual(config.Program.0.SetpointTemperatureCool, 1200)
        XCTAssertEqual(config.Quarters.0, 0x22)
        XCTAssertEqual(config.Quarters.1, 0)
    }
    
    func test_shouldBrakeWithFatalError_whenInvalidProgramSet() {
        // given
        let weeklyConfig = SuplaChannelWeeklyScheduleConfig(
            remoteId: 123,
            channelFunc: nil,
            programConfigurations: [
                SuplaWeeklyScheduleProgram(
                    program: .off,
                    mode: .cool,
                    setpointTemperatureHeat: nil,
                    setpointTemperatureCool: 1200
                )
            ],
            schedule: []
        )
        
        // when
        expectFatalError(expectedMessage: "Trying to set invalid program off") {
            _ = self.useCase.invoke(
                remoteId: 123,
                config: weeklyConfig
            ).subscribe(self.observer).disposed(by: self.disposeBag)
        }
    }
    
    private func extract(pointee: UnsafeMutableRawPointer) -> TChannelConfig_WeeklySchedule {
        return pointee.assumingMemoryBound(to: TChannelConfig_WeeklySchedule.self).pointee
    }
}
