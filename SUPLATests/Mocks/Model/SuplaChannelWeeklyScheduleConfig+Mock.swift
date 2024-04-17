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
@testable import SUPLA

extension SuplaChannelWeeklyScheduleConfig {
    
    static func mock(
        remoteId: Int32 = 0,
        channelFunc: Int32? = nil,
        withPrograms: Bool = false,
        withSchedule: Bool = false,
        secondProgram: SuplaScheduleProgram = .program1
    ) -> SuplaChannelWeeklyScheduleConfig {
        SuplaChannelWeeklyScheduleConfig(
            remoteId: remoteId,
            channelFunc: channelFunc,
            crc32: 0,
            programConfigurations: withPrograms ? mockProgramConfigurations() : [],
            schedule: withSchedule ? mockSchedule(secondProgram: secondProgram) : []
        )
    }
    
    fileprivate static func mockProgramConfigurations() -> [SuplaWeeklyScheduleProgram] {
        return [
            SuplaWeeklyScheduleProgram(
                program: .program1,
                mode: .cool,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: 1200
            ),
            SuplaWeeklyScheduleProgram(
                program: .program2,
                mode: .cool,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: 2100
            ),
            SuplaWeeklyScheduleProgram(
                program: .program3,
                mode: .cool,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: 2300
            ),
            SuplaWeeklyScheduleProgram(
                program: .program4,
                mode: .cool,
                setpointTemperatureHeat: nil,
                setpointTemperatureCool: 1800
            )
        ]
    }
    
    fileprivate static func mockSchedule(secondProgram: SuplaScheduleProgram) -> [SuplaWeeklyScheduleEntry] {
        return [
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
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 0,
                quarterOfHour: .third,
                program: .program2
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 0,
                quarterOfHour: .fourth,
                program: .program2
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 1,
                quarterOfHour: .first,
                program: .program2
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 1,
                quarterOfHour: .second,
                program: .program2
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 1,
                quarterOfHour: .third,
                program: secondProgram
            ),
            SuplaWeeklyScheduleEntry(
                dayOfWeek: .sunday,
                hour: 1,
                quarterOfHour: .fourth,
                program: secondProgram
            )
        ]
    }
}
