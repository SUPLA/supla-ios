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

@objc public class SAIncrementalMeterChartMarkerView: SAChartMarkerView {
    private let formatter = SAFormatter()
     
    override open func getValue1(entry: ChartDataEntry) -> String {
        if (chartHelper != nil && chartHelper is SAIncrementalMeterChartHelper) {
            let helper: SAIncrementalMeterChartHelper =
                chartHelper as! SAIncrementalMeterChartHelper
            
            if (helper.currency != nil) {
                return String(format: "%.2f %@", entry.y * helper.pricePerUnit, helper.currency!)
            }
        }
        return ""
    }
    
    override open func getValue2(entry: ChartDataEntry) -> String {
        var unit = ""
        if (chartHelper != nil && chartHelper?.unit != nil) {
            unit = String(chartHelper!.unit)
        }
        
        return formatter.double(toString: entry.y, withUnit: unit, maxPrecision: 3)
    }
}
