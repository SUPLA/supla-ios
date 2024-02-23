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
    
    var data: ChartData? {
        didSet {
            combinedData = data?.combinedData()
            if (combinedData == nil || data?.isEmpty == true) {
                combinedChart.highlightValue(nil)
            }
            combinedChart.data = combinedData
            if let data = data {
                combinedChart.xAxis.valueFormatter = AxisXFormatter(converter: data)
                combinedChart.leftAxis.valueFormatter = AxisYFormatter(formatter: data.leftAxisFormatter)
                combinedChart.rightAxis.valueFormatter = AxisYFormatter(formatter: data.rightAxisFormatter)
            }
            combinedChart.notifyDataSetChanged()
            combinedChart.setNeedsLayout()
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
        set { if let max = newValue { combinedChart.leftAxis.axisMaximum = max < 0 ? 0 : max } }
    }
    
    var minLeftAxis: Double? {
        get { combinedChart.leftAxis.axisMinimum }
        set {
            if let min = newValue,
               let function = channelFunction,
               isNotGmp(function: function)
            {
                combinedChart.leftAxis.axisMinimum = min < 0 ? min : 0
            }
        }
    }
    
    var maxRightAxis: Double? {
        get { combinedChart.rightAxis.axisMaximum }
        set { if let max = newValue { combinedChart.rightAxis.axisMaximum = max > 100 ? max : 100 } }
    }
    
    var channelFunction: Int32? = nil
    
    private lazy var combinedChart: DGCharts.CombinedChartView = {
        let view = DGCharts.CombinedChartView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        
        // Left axis
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.labelTextColor = .darkRed
        view.leftAxis.gridColor = .darkRed
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
        view.xAxis.labelCount = 6
        // Others
        view.legend.enabled = false
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
    
    private func isNotGmp(function: Int32) -> Bool {
        function != SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
            && function != SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
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
    
    init(converter: ChartData) {
        self.converter = converter
    }
    
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        let distanceInDays = converter.distanceInDays ?? 1
        return if (distanceInDays <= 1) {
            formatter.getHourString(date: Date(timeIntervalSince1970: value)) ?? ""
        } else {
            formatter.getMonthString(date: Date(timeIntervalSince1970: value)) ?? ""
        }
    }
}

private class AxisYFormatter: NSObject, AxisValueFormatter {
    private let formatter: ChannelValueFormatter
    
    init(formatter: ChannelValueFormatter) {
        self.formatter = formatter
    }
    
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        formatter.format(value, withUnit: false, precision: 1)
    }
}
