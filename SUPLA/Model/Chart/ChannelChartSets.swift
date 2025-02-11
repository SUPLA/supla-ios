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
    
struct ChannelChartSets: Equatable, Identifiable {
    var id: Int32 { remoteId }
    
    let remoteId: Int32
    let function: Int32
    let name: String
    let aggregation: ChartDataAggregation
    let dataSets: [HistoryDataSet]
    let customData: (any Equatable)?
    let typeName: String?
    
    init(
        remoteId: Int32,
        function: Int32,
        name: String,
        aggregation: ChartDataAggregation,
        dataSets: [HistoryDataSet],
        customData: (any Equatable)? = nil,
        typeName: String? = nil
    ) {
        self.remoteId = remoteId
        self.function = function
        self.name = name
        self.aggregation = aggregation
        self.dataSets = dataSets
        self.customData = customData
        self.typeName = typeName
    }
    
    var active: Bool {
        for set in dataSets {
            if (set.active) {
                return true
            }
        }
        
        return false
    }
    
    func empty() -> ChannelChartSets {
        ChannelChartSets(
            remoteId: remoteId,
            function: function,
            name: name,
            aggregation: aggregation,
            dataSets: dataSets.map { $0.changing(path: \.entries, to: []) },
            customData: customData,
            typeName: typeName
        )
    }
    
    func setActive(types: [ChartEntryType]?) -> ChannelChartSets {
        ChannelChartSets(
            remoteId: remoteId,
            function: function,
            name: name,
            aggregation: aggregation,
            dataSets: dataSets.map { $0.changing(path: \.active, to: types?.contains($0.type) == true) },
            customData: customData,
            typeName: typeName
        )
    }
    
    func activate() -> ChannelChartSets {
        ChannelChartSets(
            remoteId: remoteId,
            function: function,
            name: name,
            aggregation: aggregation,
            dataSets: dataSets.map { $0.changing(path: \.active, to: true) },
            customData: customData,
            typeName: typeName
        )
    }
    
    func deactivate() -> ChannelChartSets {
        ChannelChartSets(
            remoteId: remoteId,
            function: function,
            name: name,
            aggregation: aggregation,
            dataSets: dataSets.map { $0.changing(path: \.active, to: false) },
            customData: customData,
            typeName: typeName
        )
    }
    
    func toggleActive(type: ChartEntryType) -> ChannelChartSets {
        ChannelChartSets(
            remoteId: remoteId,
            function: function,
            name: name,
            aggregation: aggregation,
            dataSets: dataSets.map { $0.type == type ? $0.changing(path: \.active, to: !$0.active) : $0 },
            customData: customData,
            typeName: typeName
        )
    }
    
    static func == (lhs: ChannelChartSets, rhs: ChannelChartSets) -> Bool {
        lhs.remoteId == rhs.remoteId &&
            lhs.function == rhs.function &&
            lhs.name == rhs.name &&
            lhs.aggregation == rhs.aggregation &&
            lhs.dataSets == rhs.dataSets &&
            lhs.customData.equalTo(rhs.customData) &&
            lhs.typeName == rhs.typeName
    }
}

extension ChannelChartSets {
    var hasCustomFilters: Bool {
        switch (function) {
        case SUPLA_CHANNELFNC_ELECTRICITY_METER,
             SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER: true
        default: false
        }
    }
}
