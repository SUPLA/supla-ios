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

@objc class SuplaChartMarkerView: BaseChartMarkerView {
    @Singleton<ValuesFormatter> private var formatter
    
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
    
    override func setupView() {
        super.setupView()
        
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
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let details = entry.data as? ChartEntryDetails {
            updateTitle(details: details)
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
        case .humidity, .humidityOnly:
            details.valueFormatter.format(value, withUnit: true, precision: precision)
        case .generalPurposeMeasurement:
            details.valueFormatter.format(value, withUnit: false)
        case .generalPurposeMeter:
            details.valueFormatter.format(value, withUnit: true)
        case .electricity:
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
