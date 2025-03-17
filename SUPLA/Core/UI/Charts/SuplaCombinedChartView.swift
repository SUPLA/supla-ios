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

import DGCharts
import RxRelay
import RxSwift

class SuplaCombinedChartView: UIView {
    var parametersObservable: Observable<ChartParameters> { parametersRelay.asObservable() }
    
    var combinedData: DGCharts.CombinedChartData? = nil
    
    var data: CombinedChartData? {
        didSet {
            combinedData = data?.combinedData()
            if (combinedData == nil || data?.isEmpty == true) {
                combinedChart.highlightValue(nil)
            }
            combinedChart.data = combinedData
            if let data = data {
                combinedChart.xAxis.valueFormatter = AxisXFormatter(converter: data, chart: combinedChart, handler: combinedChart.viewPortHandler)
                combinedChart.leftAxis.valueFormatter = AxisYFormatter(formatter: data.leftAxisFormatter)
                combinedChart.rightAxis.valueFormatter = AxisYFormatter(formatter: data.rightAxisFormatter)
            }
            combinedChart.notifyDataSetChanged()
            combinedChart.setNeedsLayout()
        }
    }
    
    var chartStyle: ChartStyle? = nil {
        didSet {
            guard let chartStyle = chartStyle else { return }
            if (chartStyle.isEqualTo(oldValue) == true) { return }
            
            combinedChart.leftAxis.labelTextColor = chartStyle.leftAxisColor
            combinedChart.leftAxis.gridColor = chartStyle.leftAxisColor
            combinedChart.rightAxis.labelTextColor = chartStyle.rightAxisColor
            combinedChart.rightAxis.gridColor = chartStyle.rightAxisColor
            combinedChart.drawBarShadowEnabled = chartStyle.drawBarShadow
            if (!chartStyle.setMaxValue) {
                combinedChart.leftAxis.resetCustomAxisMax()
                combinedChart.rightAxis.resetCustomAxisMax()
            }
            if (!chartStyle.setMinValue) {
                combinedChart.leftAxis.resetCustomAxisMin()
                combinedChart.rightAxis.resetCustomAxisMin()
            }
            
            let marker = chartStyle.markerView
            marker.chartView = combinedChart
            combinedChart.marker = marker
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
    
    var withLeftAxis: Bool {
        get { combinedChart.leftAxis.isEnabled }
        set { combinedChart.leftAxis.enabled = newValue }
    }
    
    var withRightAxis: Bool {
        get { combinedChart.rightAxis.isEnabled }
        set { combinedChart.rightAxis.enabled = newValue }
    }
    
    var maxLeftAxis: Double? {
        get { combinedChart.leftAxis.axisMaximum }
        set {
            if let max = newValue, chartStyle?.setMaxValue == true {
                combinedChart.leftAxis.axisMaximum = max < 0 ? 0 : max
            }
        }
    }
    
    var minLeftAxis: Double? {
        get { combinedChart.leftAxis.axisMinimum }
        set {
            if let min = newValue, chartStyle?.setMinValue == true {
                combinedChart.leftAxis.axisMinimum = min > 0 ? 0 : min
            }
        }
    }
    
    var maxRightAxis: Double? {
        get { combinedChart.rightAxis.axisMaximum }
        set {
            if let max = newValue, chartStyle?.setMaxValue == true {
                combinedChart.rightAxis.axisMaximum = max > 100 ? max : 100
            }
        }
    }
    
    var channelFunction: Int32? = nil
    
    override var isHidden: Bool {
        didSet {
            combinedChart.isHidden = isHidden
        }
    }
    
    private lazy var combinedChart: DGCharts.CombinedChartView = {
        let view = DGCharts.CombinedChartView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        
        // Left axis
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.zeroLineColor = .onBackground
        view.leftAxis.gridLineDashLengths = [1.5]
        view.leftAxis.gridLineDashLengths = [3]
        // Right axis
        view.rightAxis.drawAxisLineEnabled = false
        view.rightAxis.labelTextColor = .darkBlue
        view.rightAxis.gridColor = .darkBlue
        view.rightAxis.zeroLineColor = .onBackground
        view.rightAxis.axisMinimum = 0
        view.rightAxis.axisMaximum = 100
        view.rightAxis.gridLineDashLengths = [1.5]
        view.rightAxis.gridLineDashLengths = [3]
        // X axis
        view.xAxis.drawGridLinesEnabled = false
        view.xAxis.drawAxisLineEnabled = false
        view.xAxis.labelPosition = .bottom
        view.xAxis.labelCount = 4
        // Others
        view.legend.enabled = false
        view.chartDescription.enabled = false
        view.delegate = self
        view.noDataTextColor = .onBackground
        view.noDataFont = .body2
        view.drawMarkers = true
        view.highlightFullBarEnabled = false
        return view
    }()
    
    private let parametersRelay = PublishRelay<ChartParameters>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
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
    
    func clearHighlight() {
        combinedChart.highlightValue(nil)
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

extension SuplaCombinedChartView: ChartViewDelegate {
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

private class AxisXFormatter: NSObject, AxisValueFormatter {
    @Singleton<ValuesFormatter> private var formatter
    
    private let converter: ChartData
    private let chart: CombinedChartView
    private let handler: ViewPortHandler
    
    init(converter: ChartData, chart: CombinedChartView, handler: ViewPortHandler) {
        self.converter = converter
        self.chart = chart
        self.handler = handler
    }
    
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        let left = chart.getEntryByTouchPoint(point: CGPoint(x: handler.contentLeft, y: handler.contentTop))
        let right = chart.getEntryByTouchPoint(point: CGPoint(x: handler.contentRight, y: handler.contentTop))
        let distanceInDaysFromChart = converter.distanceInDays(start: CGFloat(left?.x ?? 0.0), end: CGFloat(right?.x ?? 0.0))
        let distanceInDays = converter.distanceInDays ?? 1
        let date = Date(timeIntervalSince1970: value)
        return if (converter.aggregation == .years) {
            formatter.getYearString(date: date) ?? ""
        } else if (distanceInDays > 1 && distanceInDaysFromChart <= 2) {
            formatter.getDayAndHourShortDateString(date: date) ?? ""
        } else if (distanceInDaysFromChart <= 1.1) {
            formatter.getHourString(date: date) ?? ""
        } else {
            formatter.getMonthString(date: date) ?? ""
        }
    }
}

private class AxisYFormatter: NSObject, AxisValueFormatter {
    private let formatter: ChannelValueFormatter
    
    init(formatter: ChannelValueFormatter) {
        self.formatter = formatter
    }
    
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        formatter.format(value, withUnit: false, precision: .customPrecision(value: axis?.decimals ?? 1))
    }
}
