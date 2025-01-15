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
import RxRelay
import RxSwift
import SwiftUI

@objc class ElectricityChartMarkerView: BaseRowsChartMarkerView {
    
    override var rows: [MarkerRowView] { _rows }
    
    private lazy var _rows: [MarkerRowView] = [.init(), .init(), .init(), .init()]
    private let formatter = ListElectricityMeterValueFormatter(useNoValue: false)
    
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
        
        guard let customData = details.customData as? ElectricityMarkerCustomData,
              let filters = customData.filters
        else { return }
        
        if (details.aggregation.isRank) {
            guard let pieEntry = entry as? PieChartDataEntry else { return }
            showRank(pieEntry, details.aggregation, customData, highlight.x)
        } else {
            guard let barEntry = entry as? BarChartDataEntry else { return }
            
            switch (filters.type) {
            case .reverseActiveEnergy,
                 .forwardActiveEnergy,
                 .reverseReactiveEnergy,
                 .forwardReactiveEnergy: showPhases(filters.selectedPhases, highlight, barEntry, customData)
            case .balanceHourly,
                 .balanceVector,
                 .balanceArithmetic: showBalanceTwoValues(highlight, barEntry, customData)
            case .balanceChartAggregated: showBalanceThreeValues(highlight, barEntry)
            }
        }
        
        updateContainerSize()
        
        setNeedsUpdateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func showPhases(
        _ selectedPhases: [Phase],
        _ highlight: Highlight,
        _ barEntry: BarChartDataEntry,
        _ customData: ElectricityMarkerCustomData
    ) {
        var yIdx = 0
        var sum: Double = 0
        
        for phase in Phase.allCases {
            if (selectedPhases.contains(phase)),
               let value = barEntry.yValues?[yIdx]
            {
                rows[yIdx].setData(
                    value: formatter.format(value),
                    color: phase.color,
                    label: phase.label,
                    price: customData.priceString(value)
                )
                if (highlight.stackIndex == yIdx || selectedPhases.count == 1) {
                    rows[yIdx].bold()
                } else {
                    rows[yIdx].regular()
                }
                
                sum += value
                yIdx += 1
            }
        }
        
        if (yIdx > 1) {
            rows[yIdx].setData(
                value: formatter.format(sum),
                label: Strings.ElectricityMeter.sum,
                price: customData.priceString(sum)
            )
        }
    }
    
    private func showBalanceTwoValues(
        _ highlight: Highlight,
        _ barEntry: BarChartDataEntry,
        _ customData: ElectricityMarkerCustomData
    ) {
        var yIdx = 0
        if let forwardEnergy = barEntry.yValues?[0] {
            rows[yIdx].setData(
                value: formatter.format(forwardEnergy),
                icon: .iconForwardEnergy,
                price: customData.priceString(forwardEnergy)
            )
            
            highlight.stackIndex == yIdx ? rows[yIdx].bold() : rows[yIdx].regular()
            yIdx += 1
        }
        
        if let reverseEnergy = barEntry.yValues?[1] {
            rows[yIdx].setData(
                value: formatter.format(reverseEnergy),
                icon: .iconReversedEnergy
            )
            
            highlight.stackIndex == yIdx ? rows[yIdx].bold() : rows[yIdx].regular()
        }
    }
    
    private func showBalanceThreeValues(
        _ highlight: Highlight,
        _ barEntry: BarChartDataEntry
    ) {
        var yIdx = 0
        if let value = barEntry.yValues?[3] {
            rows[yIdx].setData(
                value: formatter.format(value),
                color: .onSurfaceVariant
            )
            
            highlight.stackIndex == 3 ? rows[yIdx].bold() : rows[yIdx].regular()
            yIdx += 1
        }
        if let value = barEntry.yValues?[1] {
            rows[yIdx].setData(
                value: formatter.format(value),
                icon: .iconForwardEnergy
            )
            
            highlight.stackIndex == 1 ? rows[yIdx].bold() : rows[yIdx].regular()
            yIdx += 1
        }
        if let value = barEntry.yValues?[2] {
            rows[yIdx].setData(
                value: formatter.format(value),
                icon: .iconReversedEnergy
            )
            
            highlight.stackIndex == 2 ? rows[yIdx].bold() : rows[yIdx].regular()
            yIdx += 1
        }
        if let value = barEntry.yValues?[0] {
            rows[yIdx].setData(
                value: formatter.format(value),
                color: .onSurfaceVariant
            )
            
            highlight.stackIndex == 0 ? rows[yIdx].bold() : rows[yIdx].regular()
            yIdx += 1
        }
    }
    
    private func showRank(_ pieEntry: PieChartDataEntry, _ aggregation: ChartDataAggregation, _ customData: ElectricityMarkerCustomData, _ idx: Double?) {
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
        
        rows[0].setData(
            value: formatter.format(pieEntry.value),
            color: color,
            price: customData.priceString(pieEntry.value)
        )
        rows[0].regular()
    }
}
