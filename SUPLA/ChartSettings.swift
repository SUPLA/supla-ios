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

@objc
class ChartSettings: NSObject {

    private let _channelId: Int
    private let _profileId: String
    private let _chartTypeField: SAChartFilterField
    private let _dateRangeField: SAChartFilterField

    @objc
    init(channelId: Int,
         chartTypeField: SAChartFilterField,
         dateRangeField: SAChartFilterField) {
        _channelId = channelId
        _chartTypeField = chartTypeField
        _dateRangeField = dateRangeField

        _profileId = SAApp.profileManager()
          .getCurrentProfile().objectID.uriRepresentation()
          .dataRepresentation.base64EncodedString()
        
        super.init()
    }

    @objc
    func restore() {
        let defs = UserDefaults.standard
        if let chartType = ChartType(rawValue: UInt(defs.integer(forKey: chartTypeKey))) {
            _chartTypeField.chartType = chartType
        }

        if let dateRange = DateRange(rawValue: UInt(defs.integer(forKey: dateRangeKey))) {
            _dateRangeField.dateRange = dateRange
        }
    }

    @objc
    func persist() {
        let defs = UserDefaults.standard
        defs.set(_chartTypeField.chartType.rawValue,
                 forKey: chartTypeKey)
        defs.set(_dateRangeField.dateRange.rawValue,
                 forKey: dateRangeKey)
    }


    private var chartTypeKey: String {
        return "ct\(_channelId)_prof_\(_profileId)_0"
    }

    private var dateRangeKey: String {
        return "ct\(_channelId)_prof_\(_profileId)_1"
    }
}
