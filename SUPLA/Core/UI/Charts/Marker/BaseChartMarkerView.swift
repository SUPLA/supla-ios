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

@objc class BaseChartMarkerView: MarkerView {
    @Singleton<ValuesFormatter> private var formatter
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .onBackground
        return label
    }()
    
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
    
    func updateTitle(details: ChartEntryDetails) {
        switch (details.aggregation) {
        case .hours:
            let text = formatter.getFullDateString(date: details.date)?.substringIndexed(to: -3) ?? ""
            title.text = "\(text):00"
        case .days:
            title.text = formatter.getFullDateString(date: details.date)?.substringIndexed(to: -5)
        case .months:
            title.text = formatter.getMonthAndYearString(date: details.date)?.capitalized
        case .years:
            title.text = formatter.getYearString(date: details.date)
        case .rankHours, .rankWeekdays, .rankMonths:
            title.text = details.aggregation.label(details.date.timeIntervalSince1970)
        default:
            title.text = formatter.getFullDateString(date: details.date)
        }
    }
    
    func setupView() {
        backgroundColor = .surface
        layer.borderWidth = 1
        layer.cornerRadius = Dimens.radiusDefault
        layer.borderColor = UIColor.primary.cgColor
        
        addSubview(title)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: Dimens.distanceTiny),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: Dimens.distanceTiny),
        ])
    }
}

private extension ChartDataAggregation {
    func label(_ value: TimeInterval) -> String {
        let formatter = DateFormatter()
        
        return switch (self) {
        case .rankHours: Strings.ElectricityMeter.hourMarkerTitle.arguments(String(format: "%.0f", value))
        case .rankWeekdays: "\(formatter.weekdaySymbols[Int(value - 1)])".capitalized
        case .rankMonths: "\(formatter.standaloneMonthSymbols[Int(value - 1)])".capitalized
        default: ""
        }
    }
}
