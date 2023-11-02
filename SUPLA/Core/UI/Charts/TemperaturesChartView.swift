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

class TemperaturesChartView: UIView {
    
    var parametersObservable: Observable<ChartParameters> {
        get { parametersRelay.asObservable() }
    }
    
    var data: CombinedChartData? {
        get { combinedChart.data as? CombinedChartData }
        set {
            combinedChart.highlightValue(nil)
            combinedChart.data = newValue
            if let yMinValue = newValue?.allData.map({ $0.yMin }).min() {
                combinedChart.leftAxis.axisMinimum = yMinValue < 0 ? yMinValue : 0
            }
        }
    }
    
    var rangeStart: Double? {
        get { combinedChart.xAxis.axisMinimum }
        set { if let minimum = newValue { combinedChart.xAxis.axisMinimum = minimum } }
    }
    
    var rangeEnd: Double? {
        get { combinedChart.xAxis.axisMaximum }
        set { if let maximum = newValue { combinedChart.xAxis.axisMaximum = maximum } }
    }
    
    var emptyChartMessage: String {
        get { combinedChart.noDataText }
        set { combinedChart.noDataText = newValue }
    }
    
    var withHumdity: Bool {
        get { combinedChart.rightAxis.isEnabled }
        set { combinedChart.rightAxis.enabled = newValue }
    }
    
    var maxTemperature: Double? {
        get { combinedChart.leftAxis.axisMaximum }
        set { if let max = newValue { combinedChart.leftAxis.axisMaximum = max } }
    }
    
    private lazy var combinedChart: CombinedChartView = {
        let view = CombinedChartView()
        let xAxisFormatter = AxisXFormatter(chart: view, handler: view.viewPortHandler)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        
        view.xAxis.drawGridLinesEnabled = false
        view.xAxis.drawAxisLineEnabled = false
        view.legend.enabled = false
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.labelTextColor = .darkRed
        view.leftAxis.gridColor = .darkRed
        view.leftAxis.zeroLineColor = .onBackground
        view.leftAxis.valueFormatter = AxisLeftFormatter()
        view.rightAxis.drawAxisLineEnabled = false
        view.rightAxis.labelTextColor = .darkBlue
        view.rightAxis.gridColor = .darkBlue
        view.rightAxis.zeroLineColor = .onBackground
        view.rightAxis.valueFormatter = AxisRightFormatter()
        view.xAxis.labelPosition = .bottom
        view.xAxis.valueFormatter = xAxisFormatter
        view.xAxis.labelCount = 6
        view.rightAxis.axisMinimum = 0
        view.rightAxis.axisMaximum = 100
        view.chartDescription.enabled = false
        view.delegate = self
        view.noDataTextColor = .onBackground
        view.noDataFont = .body2
        let marker = SuplaChartMarkerView()
        marker.chartView = view
        view.marker = marker
        view.drawMarkers = true
        return view
    }()
    
    private let parametersRelay = PublishRelay<ChartParameters>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fitScreen() {
        combinedChart.fitScreen()
    }
    
    func zoom(parameters: ChartParameters) {
        combinedChart.notifyDataSetChanged()
        combinedChart.setNeedsLayout()
        combinedChart.zoom(
            scaleX: parameters.scaleX,
            scaleY: parameters.scaleY,
            xValue: parameters.x,
            yValue: parameters.y,
            axis: .left
        )
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(combinedChart)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            combinedChart.topAnchor.constraint(equalTo: topAnchor),
            combinedChart.bottomAnchor.constraint(equalTo: bottomAnchor),
            combinedChart.leftAnchor.constraint(equalTo: leftAnchor),
            combinedChart.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension TemperaturesChartView: ChartViewDelegate {
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        publishParameters()
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        publishParameters()
    }
    
    private func publishParameters() {
        let centerPoint = combinedChart.viewPortHandler.contentCenter
        let centerPosition = combinedChart.valueForTouchPoint(point: centerPoint, axis: .left)
        parametersRelay.accept(
            ChartParameters(
                scaleX: combinedChart.viewPortHandler.scaleX,
                scaleY: combinedChart.viewPortHandler.scaleY,
                x: centerPosition.x,
                y: centerPosition.y
            )
        )
    }
}

fileprivate class AxisXFormatter: NSObject, AxisValueFormatter {
    
    @Singleton<ValuesFormatter> private var formatter
    
    let chart: CombinedChartView
    let handler: ViewPortHandler
    
    init(chart: CombinedChartView, handler: ViewPortHandler) {
        self.chart = chart
        self.handler = handler
    }
    
    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        let left = chart.valueForTouchPoint(
            point: CGPoint(x: handler.contentLeft, y: handler.contentBottom),
            axis: .left
        )
        let right = chart.valueForTouchPoint(
            point: CGPoint(x: handler.contentRight, y: handler.contentBottom),
            axis: .left
        )
        
        let distanceInDays = (right.x - left.x) / 24 / 3600
        return if (distanceInDays <= 1) {
            formatter.getHourString(date: Date(timeIntervalSince1970: value)) ?? ""
        } else {
            formatter.getMonthString(date: Date(timeIntervalSince1970: value)) ?? ""
        }
    }
}

fileprivate class AxisLeftFormatter: NSObject, AxisValueFormatter {
    
    @Singleton<ValuesFormatter> private var formatter
    
    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        formatter.temperatureToString(value, withUnit: false)
    }
}

fileprivate class AxisRightFormatter: NSObject, AxisValueFormatter {
    
    @Singleton<ValuesFormatter> private var formatter
    
    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        return if (value > 100) {
            ""
        } else {
            formatter.humidityToString(value, withPercentage: true)
        }
    }
}
