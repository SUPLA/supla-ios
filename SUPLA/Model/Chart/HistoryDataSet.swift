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

struct HistoryDataSet: Equatable, Changeable, Identifiable {
    var id: Int { type.rawValue }

    let type: ChartEntryType
    let label: Label
    let valueFormatter: SharedCore.ValueFormatter
    var entries: [[AggregatedEntity]]
    var active: Bool

    var min: Double? { entries.map { $0.map { $0.value.min }.min() }.minOrNull() }
    var max: Double? { entries.map { $0.map { $0.value.max }.max() }.maxOrNull() }
    var isEmpty: Bool { entries.isEmpty }
    var minDate: TimeInterval? { entries.flatMap { $0 }.map { $0.date }.min() }
    var maxDate: TimeInterval? { entries.flatMap { $0 }.map { $0.date }.max() }

    func toChartDetails(aggregation: ChartDataAggregation, entity: AggregatedEntity, customData: (any Equatable)? = nil) -> ChartEntryDetails {
        switch (entity.value) {
        case .single(_, let min, let max, let open, let close):
            .default(
                aggregation: aggregation,
                type: type,
                date: Date(timeIntervalSince1970: entity.date),
                min: min,
                max: max,
                open: open,
                close: close,
                valueFormatter: valueFormatter,
                customData: customData
            )
        case .multiple:
            .default(
                aggregation: aggregation,
                type: type,
                date: Date(timeIntervalSince1970: entity.date),
                min: nil,
                max: nil,
                open: nil,
                close: nil,
                valueFormatter: valueFormatter,
                customData: customData
            )
        case .withPhase(_, let min, let max, let phase):
            .withPhase(
                aggregation: aggregation,
                type: type,
                date: Date(timeIntervalSince1970: entity.date),
                min: min,
                max: max,
                valueFormatter: valueFormatter,
                phase: phase
            )
        }
    }

    static func == (lhs: HistoryDataSet, rhs: HistoryDataSet) -> Bool {
        lhs.type == rhs.type
            && lhs.label == rhs.label
            && lhs.entries == rhs.entries
            && lhs.active == rhs.active
    }

    enum Label: Equatable {
        case single(LabelData)
        case multiple([LabelData])

        var colors: [UIColor] {
            switch (self) {
            case .single(let data): [data.color]
            case .multiple(let datas): datas.filter { $0.useColor }.map { $0.color }
            }
        }
    }

    struct LabelData: Equatable {
        let icon: IconResult?
        let value: String
        let color: UIColor
        let presentColor: Bool
        let useColor: Bool
        let justColor: Bool
        let iconSize: CGFloat?
        let description: String?

        init(
            icon: IconResult?,
            value: String,
            color: UIColor,
            presentColor: Bool = true,
            useColor: Bool = true,
            justColor: Bool = false,
            iconSize: CGFloat? = nil,
            description: String? = nil
        ) {
            self.icon = icon
            self.value = value
            self.color = color
            self.presentColor = presentColor
            self.useColor = useColor
            self.justColor = justColor
            self.iconSize = iconSize
            self.description = description
        }

        init(color: UIColor) {
            self.icon = nil
            self.value = ""
            self.color = color
            self.presentColor = false
            self.useColor = true
            self.justColor = true
            self.iconSize = nil
            self.description = nil
        }

        func getIconSize() -> CGFloat { iconSize ?? Dimens.iconSizeBig }
    }
}

func singleLabel(
    _ image: IconResult?,
    _ value: String,
    _ color: UIColor,
    _ description: String? = nil
) -> HistoryDataSet.Label {
    .single(HistoryDataSet.LabelData(icon: image, value: value, color: color, description: description))
}
