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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
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
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceTiny),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            text.topAnchor.constraint(equalTo: title.bottomAnchor),
            text.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
            
            subtext.topAnchor.constraint(equalTo: title.bottomAnchor),
            subtext.leftAnchor.constraint(equalTo: text.rightAnchor, constant: 8)
        ])
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let data = entry.data as? EntryDetails {
            switch (data.aggregation) {
            case .hours:
                let text = formatter.getFullDateString(date: entry.xAsDate)?.substringIndexed(to: -3) ?? ""
                title.text = "\(text):00"
            case .days:
                title.text = formatter.getFullDateString(date: entry.xAsDate)?.substringIndexed(to: -5)
            case .months:
                title.text = formatter.getMonthAndYearString(date: entry.xAsDate)
            case .years:
                title.text = formatter.getYearString(date: entry.xAsDate)
            default:
                title.text = formatter.getFullDateString(date: entry.xAsDate)
            }
            
            text.text = getValueString(type: data.type, entry.y)
            
            if let min = data.min,
               let max = data.max {
                let minText = getValueString(type: data.type, min)
                let maxText = getValueString(type: data.type, max)

                subtext.text = "(\(minText) - \(maxText))"
            } else {
                subtext.text = ""
            }
        }
        
        updateContainerSize()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func getValueString(type: ChartEntryType, _ value: Double) -> String {
        switch (type) {
        case .temperature:
            formatter.temperatureToString(value, withUnit: false)
        case .humidity:
            formatter.humidityToString(rawValue: value, withPercentage: true)
        }
    }
    
    private func updateContainerSize() {
        let top = title.intrinsicContentSize.width
        let bottom = text.intrinsicContentSize.width + subtext.intrinsicContentSize.width + Dimens.distanceTiny
        let width = top > bottom ? top : bottom
        let height = title.intrinsicContentSize.height + text.intrinsicContentSize.height
        
        self.frame.size.width = width + Dimens.distanceTiny * 2
        self.frame.size.height = height + Dimens.distanceTiny * 2
    }
}
