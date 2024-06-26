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

@objc class SuplaChartMarkerView: MarkerView {
    @Singleton<ValuesFormatter> private var formatter
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var text: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .openSansBold(style: .body, size: 14)
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var subtext: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var firstRowTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.StaticSize.caption
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var firstRowValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.StaticSize.caption
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    private lazy var secondRowTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.StaticSize.caption
        label.textColor = .onBackground
        return label
    }()
    
    private lazy var secondRowValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.StaticSize.caption
        label.textColor = .onBackground
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .surface
        layer.borderWidth = 1
        layer.cornerRadius = Dimens.radiusDefault
        layer.borderColor = UIColor.primary.cgColor
        
        addSubview(title)
        addSubview(text)
        addSubview(subtext)
        addSubview(firstRowTitle)
        addSubview(firstRowValue)
        addSubview(secondRowTitle)
        addSubview(secondRowValue)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceTiny),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            text.topAnchor.constraint(equalTo: title.bottomAnchor),
            text.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            subtext.centerYAnchor.constraint(equalTo: text.centerYAnchor),
            subtext.leftAnchor.constraint(equalTo: text.rightAnchor, constant: 8),
            
            firstRowTitle.topAnchor.constraint(equalTo: text.bottomAnchor),
            firstRowTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            firstRowValue.topAnchor.constraint(equalTo: firstRowTitle.topAnchor),
            firstRowValue.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceTiny),
            
            secondRowTitle.topAnchor.constraint(equalTo: firstRowTitle.bottomAnchor),
            secondRowTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            secondRowValue.topAnchor.constraint(equalTo: secondRowTitle.topAnchor),
            secondRowValue.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimens.distanceTiny)
        ])
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        guard let chart = chartView else { return self.offset }
        
        var top = -frame.size.height - 20
        if (point.y + top < 0) {
            top = -point.y
        }
        
        let halfWidth = frame.size.width / 2
        var left = -halfWidth
        if (point.x + left < 0) {
            left = -point.x
        } else if (point.x + halfWidth > chart.bounds.maxX) {
            left = chart.bounds.maxX - frame.size.width - point.x
        }
        
        return CGPoint(x: left, y: top)
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let details = entry.data as? ChartEntryDetails {
            switch (details.aggregation) {
            case .hours:
                let text = formatter.getFullDateString(date: details.date)?.substringIndexed(to: -3) ?? ""
                title.text = "\(text):00"
            case .days:
                title.text = formatter.getFullDateString(date: details.date)?.substringIndexed(to: -5)
            case .months:
                title.text = formatter.getMonthAndYearString(date: details.date)
            case .years:
                title.text = formatter.getYearString(date: details.date)
            default:
                title.text = formatter.getFullDateString(date: details.date)
            }
            
            text.text = getValueString(details, entry.y, precision: 2)
            
            if let min = details.min,
               let max = details.max
            {
                let minText = getValueString(details, min, precision: 1)
                let maxText = getValueString(details, max, precision: 1)

                subtext.text = "(\(minText) - \(maxText))"
            } else {
                subtext.text = ""
            }
            
            if let open = details.open,
               let close = details.close,
               details.type == .generalPurposeMeasurement
            {
                firstRowTitle.text = Strings.Charts.markerOpening
                firstRowValue.text = details.valueFormatter.format(open, withUnit: false)
                secondRowTitle.text = Strings.Charts.markerClosing
                secondRowValue.text = details.valueFormatter.format(close, withUnit: false)
            } else {
                firstRowTitle.text = ""
                firstRowValue.text = ""
                secondRowTitle.text = ""
                secondRowValue.text = ""
            }
        }
        
        updateContainerSize(entry.data as? ChartEntryDetails)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func getValueString(_ details: ChartEntryDetails, _ value: Double, precision: Int = 1) -> String {
        switch (details.type) {
        case .temperature:
            details.valueFormatter.format(value, withUnit: false, precision: precision)
        case .humidity:
            details.valueFormatter.format(value, withUnit: true, precision: precision)
        case .generalPurposeMeasurement:
            details.valueFormatter.format(value, withUnit: false)
        case .generalPurposeMeter:
            details.valueFormatter.format(value, withUnit: true)
        }
    }
    
    private func updateContainerSize(_ data: ChartEntryDetails?) {
        let firstLineWidth = title.intrinsicContentSize.width
        let secondLineWidth = text.intrinsicContentSize.width + subtext.intrinsicContentSize.width + Dimens.distanceTiny
        let width = firstLineWidth > secondLineWidth ? firstLineWidth : secondLineWidth
        let height = title.intrinsicContentSize.height + text.intrinsicContentSize.height
        let tableHeight = getTableHeight(data)
        
        frame.size.width = width + Dimens.distanceTiny * 2
        frame.size.height = height + Dimens.distanceTiny * 2 + tableHeight
    }
    
    private func getTableHeight(_ data: ChartEntryDetails?) -> CGFloat {
        if (data != nil && data!.type == .generalPurposeMeasurement) {
            return firstRowTitle.intrinsicContentSize.height + secondRowTitle.intrinsicContentSize.height
        } else {
            return 0.0
        }
    }
}
