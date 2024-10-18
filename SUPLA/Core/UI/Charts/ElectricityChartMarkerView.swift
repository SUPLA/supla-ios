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

struct RowData {
    let dotColor: UIColor?
    let label: String?
    let value: String
    let price: String?
}

@objc class ElectricityChartMarkerView: BaseChartMarkerView {
    
    private lazy var rows: [Row] = [Row(), Row(), Row(), Row()]
    
    private let formatter = ListElectricityMeterValueFormatter(useNoValue: false)
    private var dynamicConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        rows.forEach { addSubview($0) }
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        rows.forEach { $0.setHidden(true) }
        
        guard let details = entry.data as? ChartEntryDetails else { return }
        updateTitle(details: details)
        
        guard let customData = details.customData as? ElectricityMarkerCustomData,
              let filters = customData.filters
        else { return }
        
        if (details.aggregation.isRank) {
            // TODO: Add later
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
    
    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()
        
        var imageWidth: CGFloat = 0
        var labelWidth: CGFloat = 0
        var valueWidth: CGFloat = 0
        var priceWidth: CGFloat = 0
        
        for row in rows {
            imageWidth = max(imageWidth, row.imageView.image == nil ? Row.DOT_SIZE : Row.ICON_SIZE)
            labelWidth = max(labelWidth, row.labelView.intrinsicContentSize.width)
            valueWidth = max(valueWidth, row.valueView.intrinsicContentSize.width)
            priceWidth = max(priceWidth, row.priceView.intrinsicContentSize.width)
        }

        var topAnchor = title.bottomAnchor
        for row in rows {
            let constraints = row.getConstraints(leftAnchor, topAnchor, imageWidth, labelWidth, valueWidth, priceWidth)
            dynamicConstraints.append(contentsOf: constraints)
            topAnchor = row.valueView.bottomAnchor
        }
        NSLayoutConstraint.activate(dynamicConstraints)
    }
    
    private func updateContainerSize() {
        let titleWidth = Distance.tiny + title.intrinsicContentSize.width + Distance.tiny
        var height = Distance.tiny + title.intrinsicContentSize.height
        
        var imageWidth: CGFloat = 0
        var labelWidth: CGFloat = 0
        var valueWidth: CGFloat = 0
        var priceWidth: CGFloat = 0
        
        for row in rows {
            imageWidth = max(imageWidth, row.imageView.image == nil ? Row.DOT_SIZE : Row.ICON_SIZE)
            labelWidth = max(labelWidth, row.labelView.intrinsicContentSize.width)
            valueWidth = max(valueWidth, row.valueView.intrinsicContentSize.width)
            priceWidth = max(priceWidth, row.priceView.intrinsicContentSize.width)
            height += row.valueView.intrinsicContentSize.height + Row.CELL_DISTANCE
        }
        let tableWidth = Distance.tiny + imageWidth + labelWidth + valueWidth + priceWidth + Row.CELL_DISTANCE * 3 + Distance.tiny
        
        frame.size.width = max(titleWidth, tableWidth)
        frame.size.height = height + Row.CELL_DISTANCE
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
}

private extension UIView {
    func addSubview(_ subview: Row) {
        addSubview(subview.imageView)
        addSubview(subview.labelView)
        addSubview(subview.valueView)
        addSubview(subview.priceView)
    }
}

private class Row {
    static let CELL_DISTANCE: CGFloat = Distance.tiny / 2
    static let DOT_SIZE: CGFloat = 8
    static let ICON_SIZE: CGFloat = 18
    
    fileprivate lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Row.DOT_SIZE / 2
        return view
    }()
    
    fileprivate lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        return label
    }()
    
    fileprivate lazy var valueView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    fileprivate lazy var priceView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .StaticSize.marker
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    func setData(value: String, color: UIColor? = nil, icon: UIImage? = nil, label: String? = nil, price: String? = nil) {
        setHidden(false)
        
        valueView.text = value
        
        imageView.isHidden = color == nil && icon == nil
        if let dotColor = color {
            imageView.layer.backgroundColor = dotColor.cgColor
            imageView.image = nil
        }
        if let icon {
            imageView.layer.backgroundColor = UIColor.clear.cgColor
            imageView.image = icon
        }
        labelView.isHidden = label == nil
        if let label = label {
            labelView.text = label
        }
        priceView.isHidden = price == nil
        if let price = price {
            priceView.text = price
        }
    }
    
    func setHidden(_ isHidden: Bool) {
        imageView.isHidden = isHidden
        labelView.isHidden = isHidden
        valueView.isHidden = isHidden
        priceView.isHidden = isHidden
    }
    
    func bold() {
        labelView.font = .StaticSize.markerBold
        valueView.font = .StaticSize.markerBold
        priceView.font = .StaticSize.markerBold
    }
    
    func regular() {
        labelView.font = .StaticSize.marker
        valueView.font = .StaticSize.marker
        priceView.font = .StaticSize.marker
    }
    
    func getConstraints(
        _ leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        _ topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        _ plannedImageWidth: CGFloat,
        _ labelWidth: CGFloat,
        _ valueWidth: CGFloat,
        _ priceWidth: CGFloat
    ) -> [NSLayoutConstraint] {
        let padding: CGFloat = plannedImageWidth > Row.DOT_SIZE && imageView.image == nil ? 5 : 0
        let imageWidth = imageView.image == nil ? Row.DOT_SIZE : Row.ICON_SIZE
        return [
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Distance.tiny + padding),
            imageView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            labelView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: Row.CELL_DISTANCE + padding),
            labelView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            labelView.widthAnchor.constraint(equalToConstant: labelWidth),
            
            valueView.leftAnchor.constraint(equalTo: labelView.rightAnchor, constant: Row.CELL_DISTANCE),
            valueView.topAnchor.constraint(equalTo: topAnchor, constant: Row.CELL_DISTANCE),
            valueView.widthAnchor.constraint(equalToConstant: valueWidth),
            
            priceView.leftAnchor.constraint(equalTo: valueView.rightAnchor, constant: Row.CELL_DISTANCE),
            priceView.centerYAnchor.constraint(equalTo: valueView.centerYAnchor),
            priceView.widthAnchor.constraint(equalToConstant: priceWidth)
        ]
    }
}
