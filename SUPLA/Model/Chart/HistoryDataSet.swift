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

import Foundation

struct HistoryDataSet: Equatable, Changeable {
    let setId: Id
    let icon: UIImage?
    let value: String
    let valueFormatter: ChannelValueFormatter
    let color: UIColor
    var entries: [[AggregatedEntity]]
    var active: Bool

    struct Id: Equatable, Codable {
        let remoteId: Int32
        let type: ChartEntryType
    }

    func toDetails(_ entity: AggregatedEntity) -> ChartEntryDetails {
        ChartEntryDetails(
            aggregation: entity.aggregation,
            type: entity.type,
            date: Date(timeIntervalSince1970: entity.date),
            min: entity.min,
            max: entity.max,
            open: entity.open,
            close: entity.close,
            valueFormatter: valueFormatter
        )
    }

    static func == (lhs: HistoryDataSet, rhs: HistoryDataSet) -> Bool {
        lhs.setId == rhs.setId
            && lhs.icon == rhs.icon
            && lhs.value == rhs.value
            && lhs.color == rhs.color
            && lhs.entries == rhs.entries
            && lhs.active == rhs.active
    }
}
