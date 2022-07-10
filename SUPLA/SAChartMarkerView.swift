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

@objc public class SAChartMarkerView: MarkerView
{
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    @objc open weak var chartHelper: SAChartHelper?
    private let formatter = SAFormatter()
    
    private func setLabelPosition(label: UILabel, offset: CGFloat) -> CGFloat {
        if (label.isHidden) {
            return offset;
        }
        
        label.frame.origin.y = offset;
        
        return label.frame.origin.y+label.frame.size.height;
    }
    
    private func getWidth(label: UILabel, width: CGFloat) -> CGFloat {
        if (!label.isHidden && label.frame.size.width > width) {
            return label.frame.size.width;
        }
        
        return width;
    }

    internal var allLabels: [UILabel] {
        return [label1, label2, label3]
    }
    
    private func updatePositions() {
        let offset = allLabels.reduce(0) { off, label in
            self.setLabelPosition(label: label, offset: off)
        }

        let width = allLabels.reduce(0) { w, label in
            self.getWidth(label: label, width: w)
        }

        self.frame.size.width = width
        self.frame.size.height = offset
    }
    
    internal func setLabel(label: UILabel, text: String?) {
        if (text != nil) {
            label.text = text
            label.isHidden = text!.count == 0
        } else {
            label.text = ""
            label.isHidden = true
        }
        
        label.sizeToFit()
  
        updatePositions()
    }
    
    open func getTime(entry: ChartDataEntry) -> String? {
        
        if (entry is PieChartDataEntry) {
            return (entry as! PieChartDataEntry).label!;
        }
        
        if (chartHelper != nil) {
            return chartHelper?.string(forValue: entry.x, axis: nil);
        }
        
        return "";
    }
    
    open func getValue1(entry: ChartDataEntry) -> String {
        return "";
    }
    
    open func getValue2(entry: ChartDataEntry) -> String {
        var unit = "";
        if (chartHelper != nil && chartHelper?.unit != nil) {
           unit = String(chartHelper!.unit);
        }
        
        return formatter.double(toString: entry.y,
                                withUnit: unit,
                                maxPrecision: 2)
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(label: label1, text: getTime(entry: entry));
        setLabel(label: label2, text: getValue1(entry: entry));
        setLabel(label: label3, text: getValue2(entry: entry));
        layoutIfNeeded()
    }
}
