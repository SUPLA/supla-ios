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

extension TSCS_ChannelConfig {
    func payload<T>(as _: T.Type = T.self) -> T {
        precondition(MemoryLayout<T>.size <= MemoryLayout.size(ofValue: Config))

        var config = Config
        return withUnsafePointer(to: &config) {
            UnsafeRawPointer($0).assumingMemoryBound(to: T.self).pointee
        }
    }

    mutating func setPayload<T>(_ payload: T) {
        precondition(MemoryLayout<T>.size <= MemoryLayout.size(ofValue: Config))

        var payload = payload
        withUnsafeBytes(of: &payload) { source in
            withUnsafeMutableBytes(of: &Config) { destination in
                destination.copyBytes(from: source)
            }
        }
        ConfigSize = UInt16(MemoryLayout<T>.size)
    }
}

extension TChannelConfig_WeeklySchedule {
    static var programCount: Int {
        Int(SUPLA_WEEKLY_SCHEDULE_PROGRAMS_MAX_SIZE)
    }

    static var quarterCount: Int {
        MemoryLayout.size(ofValue: TChannelConfig_WeeklySchedule().Quarters) * 2
    }

    func program(at index: Int) -> TWeeklyScheduleProgram {
        precondition((0..<Self.programCount).contains(index))

        var programs = Program
        return withUnsafeBytes(of: &programs) {
            $0.bindMemory(to: TWeeklyScheduleProgram.self)[index]
        }
    }

    mutating func setProgram(_ program: TWeeklyScheduleProgram, at index: Int) {
        precondition((0..<Self.programCount).contains(index))

        withUnsafeMutableBytes(of: &Program) {
            $0.bindMemory(to: TWeeklyScheduleProgram.self)[index] = program
        }
    }

    func program(atQuarter index: Int) -> UInt8 {
        precondition((0..<Self.quarterCount).contains(index))

        var quarters = Quarters
        let packedValue = withUnsafeBytes(of: &quarters) {
            $0.bindMemory(to: UInt8.self)[index / 2]
        }
        return index.isMultiple(of: 2) ? packedValue & 0x0F : packedValue >> 4
    }

    mutating func setProgram(_ program: UInt8, atQuarter index: Int) {
        precondition((0..<Self.quarterCount).contains(index))
        precondition(program <= 0x0F)

        withUnsafeMutableBytes(of: &Quarters) {
            let quarters = $0.bindMemory(to: UInt8.self)
            let byteIndex = index / 2
            if index.isMultiple(of: 2) {
                quarters[byteIndex] = (quarters[byteIndex] & 0xF0) | program
            } else {
                quarters[byteIndex] = (quarters[byteIndex] & 0x0F) | (program << 4)
            }
        }
    }
}

extension THVACTemperatureCfg {
    static var temperatureCount: Int {
        MemoryLayout.size(ofValue: THVACTemperatureCfg().Temperature) / MemoryLayout<Int16>.stride
    }

    func temperature(for indexMask: UInt32) -> Int16? {
        guard indexMask.nonzeroBitCount == 1, Index & indexMask != 0 else {
            return nil
        }

        return temperature(at: indexMask.trailingZeroBitCount)
    }

    func temperature(at index: Int) -> Int16 {
        precondition((0..<Self.temperatureCount).contains(index))

        var temperatures = Temperature
        return withUnsafeBytes(of: &temperatures) {
            $0.bindMemory(to: Int16.self)[index]
        }
    }

    mutating func setTemperature(_ temperature: Int16, at index: Int) {
        precondition((0..<Self.temperatureCount).contains(index))

        withUnsafeMutableBytes(of: &Temperature) {
            $0.bindMemory(to: Int16.self)[index] = temperature
        }
    }
}
