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
    
class SuplaPieChartView: UIView {
    
    override var isHidden: Bool {
        didSet {
            pieChart.isHidden = isHidden
        }
    }
    
    var data: PieChartData? {
        didSet {
            let pieData = data?.pieData()
            if (pieData == nil || data?.isEmpty == true) {
                pieChart.highlightValue(nil)
            }
            pieChart.data = pieData
            
            pieChart.notifyDataSetChanged()
            pieChart.setNeedsLayout()
        }
    }
    
    var chartStyle: ChartStyle? = nil {
        didSet {
            guard let chartStyle = chartStyle else { return }
            if (chartStyle.isEqualTo(oldValue) == true) { return }
            
            let marker = chartStyle.markerView
            marker.chartView = pieChart
            pieChart.marker = marker
        }
    }
    
    var emptyChartMessage: String {
        get { pieChart.noDataText }
        set { pieChart.noDataText = newValue }
    }
    
    private lazy var pieChart: DGCharts.PieChartView = {
        let view = DGCharts.PieChartView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        
        // Others
        view.legend.enabled = false
        view.chartDescription.enabled = false
        view.noDataTextColor = .onBackground
        view.noDataFont = .body2
        view.drawMarkers = true
        view.holeColor = .background
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearHighlight() {
        pieChart.highlightValue(nil)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(pieChart)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            pieChart.topAnchor.constraint(equalTo: topAnchor),
            pieChart.bottomAnchor.constraint(equalTo: bottomAnchor),
            pieChart.leftAnchor.constraint(equalTo: leftAnchor),
            pieChart.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
