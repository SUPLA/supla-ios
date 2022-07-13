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

import Foundation
import Charts

@objc class SAElectricityMeterChartMarkerView: SAIncrementalMeterChartMarkerView {


    @IBOutlet private var allTitle: UILabel!
    @IBOutlet private var selTitle: UILabel!

    @IBOutlet private var selValue1: UILabel!
    @IBOutlet private var selValue2: UILabel!

    override var allLabels: [UILabel] {
        return [label1, selTitle, selValue1, selValue2,
                allTitle, label2, label3]
    }

    private let formatter = SAFormatter()

    override func refreshContent(entry: ChartDataEntry,
                                 highlight: Highlight)
    {
        setLabel(label: allTitle, text: Strings.Charts.Electricity.allPhasesTitle)

        let si = highlight.stackIndex
        let lbl = String(format: Strings.Charts.Electricity.selPhaseTitle, si+1)
        setLabel(label: selTitle, text: lbl)
        if let entry = entry as? BarChartDataEntry,
           let vals = entry.yValues,
           si >= 0 && vals.count > si {
           setLabel(label: selValue1,
                    text: getSelValue1(entry: entry, index: si))
           setLabel(label: selValue2,
                    text: getSelValue2(entry: entry, index: si))
        }
        
        super.refreshContent(entry: entry, highlight: highlight)
    }

    private func getSelValue2(entry: BarChartDataEntry,
                              index: Int) -> String {
        guard let helper = self.chartHelper as? SAElectricityChartHelper,
              let vals = entry.yValues else {
            return ""
        }

        return formatter.double(toString: vals[index],
                                withUnit: helper.unit,
                                maxPrecision: 2)
    }

    private func getSelValue1(entry: BarChartDataEntry,
                              index: Int) -> String {
        guard let helper = self.chartHelper as? SAElectricityChartHelper,
              let vals = entry.yValues else {
            return ""
        }

        return formatter.double(toString: vals[index] * helper.pricePerUnit,
                                withUnit: helper.currency as String?,
                                maxPrecision: 2)
    }
}
