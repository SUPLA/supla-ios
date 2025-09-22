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
    
import Charts
import RxSwift
import RxRelay
import SharedCore

@objc class ImpulseCounterChartMarkerView: BaseRowsChartMarkerView {
    
    override var rows: [MarkerRowView] { _rows }
    
    private lazy var _rows: [MarkerRowView] = [.init(), .init()]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        rows.forEach { $0.setHidden(true) }
        
        guard let details = entry.data as? ChartEntryDetails else { return }
        updateTitle(details: details)
        
        guard let customData = details.customData as? ImpulseCounterMarkerCustomData else { return }
        
        if (details.aggregation.isRank) {
            guard let pieEntry = entry as? PieChartDataEntry else { return }
            showRank(pieEntry, details.aggregation, customData, highlight.x, details.valueFormatter)
        } else {
            showValueWithPrice(entry, customData, details.valueFormatter)
        }
        
        updateContainerSize()
        
        setNeedsUpdateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func showValueWithPrice(
        _ entry: ChartDataEntry,
        _ customData: ImpulseCounterMarkerCustomData,
        _ formatter: SharedCore.ValueFormatter
    ) {
        rows[0].setData(value: formatter.format(value: entry.y), color: .chartGpm)
        rows[0].bold()
        
        if (customData.price != nil && customData.currency != nil) {
            rows[1].setData(value: customData.priceString(entry.y))
        }
    }
    
    private func showRank(
        _ pieEntry: PieChartDataEntry,
        _ aggregation: ChartDataAggregation,
        _ customData: ImpulseCounterMarkerCustomData,
        _ idx: Double?,
        _ formatter: SharedCore.ValueFormatter
    ) {
        var color: UIColor? = nil
        
        if let idx {
            let intIdx = switch(aggregation) {
            case .rankMonths, .rankWeekdays: Int(idx - 1)
            default: Int(idx)
            }
            let colors = aggregation.colors
            
            if (intIdx >= 0 && intIdx < colors.count) {
                color = colors[intIdx]
            }
        }
        
        rows[0].setData(value: formatter.format(value: pieEntry.value), color: color)
        rows[0].bold()
        
        if (customData.price != nil && customData.currency != nil) {
            rows[1].setData(value: customData.priceString(pieEntry.value))
        }
    }
}
