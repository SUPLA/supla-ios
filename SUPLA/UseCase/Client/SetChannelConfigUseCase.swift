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

protocol SetChannelConfigUseCase {
    func invoke(remoteId: Int32, config: SuplaChannelConfig) -> Observable<RequestResult>
}

final class SetChannelConfigUseCaseImpl: SetChannelConfigUseCase {
    
    @Singleton<SuplaClientProvider> private var suplaClientProvider
    
    func invoke(remoteId: Int32, config: SuplaChannelConfig) -> Observable<RequestResult> {
        guard let scheduleConfig = config as? SuplaChannelWeeklyScheduleConfig
        else {
            fatalError("Trying to set config which is not supported \(config)")
        }
        
        return Observable.create { observer in
            var config = TSCS_ChannelConfig()
            self.setPrograms(scheduleConfig: scheduleConfig, suplaConfig: &config)
            self.setQuarters(scheduleConfig: scheduleConfig, suplaConfig: &config)
            
            config.ChannelId = remoteId
            config.ConfigType = UInt8(SUPLA_CONFIG_TYPE_WEEKLY_SCHEDULE)
            config.ConfigSize = UInt16(MemoryLayout<TChannelConfig_WeeklySchedule>.size)
            
            if (self.suplaClientProvider.provide().setChannelConfig(&config)) {
                observer.onNext(.success)
            } else {
                observer.onNext(.failure)
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    private func setPrograms(scheduleConfig: SuplaChannelWeeklyScheduleConfig, suplaConfig:  UnsafeMutablePointer<TSCS_ChannelConfig>!) {
        
        for program in scheduleConfig.programConfigurations {
            let programId = program.program.rawValue
            if (programId < 1 || programId > 4) {
                fatalError("Trying to set invalid program \(program)")
            }
            
            SuplaChannelConfigIntegrator.setProgramWith(
                programId - 1,
                withMode: program.mode.rawValue,
                withHeatTemp: program.setpointTemperatureHeat ?? 0,
                withCoolTemp: program.setpointTemperatureCool ?? 0,
                in: suplaConfig
            )
        }
    }
    
    private func setQuarters(scheduleConfig: SuplaChannelWeeklyScheduleConfig, suplaConfig: UnsafeMutablePointer<TSCS_ChannelConfig>!) {
        
        for quarter in scheduleConfig.schedule {
            let dayOfWeek = Int32(quarter.dayOfWeek.rawValue)
            let hour = Int32(quarter.hour)
            let quarterOfHour = Int32(quarter.quarterOfHour.rawValue)
            
            let index = (dayOfWeek * 24 + hour) * 2 + quarterOfHour / 3
            let program: UInt8
            if (quarterOfHour == 1 || quarterOfHour == 3) {
                program = quarter.program.rawValue
            } else {
                program = quarter.program.rawValue << 4
            }
            
            SuplaChannelConfigIntegrator.setQuarterProgram(program, for: index, in: suplaConfig)
        }
    }
}
