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

import RxRelay
import RxSwift
import SwiftUI

final class DataSetsViewState: ObservableObject {
    @Published var channelsSets: [ChannelChartSets] = []
    @Published var historyEnabled: Bool = false
}

struct DataSetsRow: View {
    struct Event {
        let remoteId: Int32
        let type: ChartEntryType
    }

    var tap: Observable<DataSetsRow.Event> { tapRelay.asObservable() }
    @ObservedObject var viewState: DataSetsViewState

    fileprivate let tapRelay = PublishRelay<Event>()

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewState.channelsSets) { channelSet in
                    DataSetContainer(
                        channelSet: channelSet,
                        historyEnabled: viewState.historyEnabled
                    ) { remoteId, type in
                        tapRelay.accept(Event(remoteId: remoteId, type: type))
                    }
                    Divider()
                        .frame(width: 1)
                        .overlay(Color.Supla.background)
                        .padding([.leading, .trailing], Distance.tiny)
                }
            }
            .frame(height: 80)
            .padding([.leading], Distance.default)
        }
    }
}

struct DataSetContainer: View {
    var channelSet: ChannelChartSets
    var historyEnabled: Bool

    var onTap: (Int32, ChartEntryType) -> Void = { _, _ in }

    var body: some View {
        VStack(spacing: 2) {
            if let name = channelSet.typeName {
                Text(name).fontLabelSmall()
            }
            HStack {
                ForEach(0 ..< channelSet.dataSets.count, id: \.self) { dataSetIdx in
                    switch (channelSet.dataSets[dataSetIdx].label) {
                    case let .single(labelData):
                        DataSetItem(
                            labelData: labelData,
                            active: historyEnabled && channelSet.dataSets[dataSetIdx].active
                        )
                        .onTapGesture {
                            onTap(channelSet.remoteId, channelSet.dataSets[dataSetIdx].type)
                        }
                    case .multiple(let labelDatas):
                        ForEach(0 ..< labelDatas.count, id: \.self) { index in
                            DataSetItem(
                                labelData: labelDatas[index],
                                active: historyEnabled && channelSet.dataSets[dataSetIdx].active
                            )
                            .onTapGesture {
                                onTap(channelSet.remoteId, channelSet.dataSets[dataSetIdx].type)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct DataSetItem: View {
    var labelData: HistoryDataSet.LabelData
    var active: Bool

    var body: some View {
        HStack {
            if let icon = labelData.icon {
                icon.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: labelData.getIconSize(), height: labelData.getIconSize())
            }

            VStack(spacing: 0) {
                Text(labelData.value).fontBodyLarge()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                if (labelData.presentColor) {
                    if (active) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(labelData.color))
                            .frame(width: 50, height: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .strokeBorder(Color(labelData.color), lineWidth: 1)
                            .frame(width: 50, height: 4)
                    }
                }
            }
        }
    }
}

#Preview {
    let firstRowState = DataSetsViewState()
    firstRowState.channelsSets = [
        ChannelChartSets(
            remoteId: 123,
            function: 123,
            name: "Reverse active energy",
            aggregation: .minutes,
            dataSets: [
                HistoryDataSet(
                    type: .electricity,
                    label: .single(HistoryDataSet.LabelData(
                        icon: .suplaIcon(name: "fnc_electricitymeter"),
                        value: "301,7",
                        color: .chartPhase1
                    )),
                    valueFormatter: ListElectricityMeterValueFormatter(),
                    entries: [],
                    active: true
                )
            ],
            typeName: "Reverse active energy"
        ),
        ChannelChartSets(
            remoteId: 124,
            function: 123,
            name: "Reverse active energy",
            aggregation: .minutes,
            dataSets: [
                HistoryDataSet(
                    type: .electricity,
                    label: .multiple(
                        [
                            HistoryDataSet.LabelData(
                                icon: .suplaIcon(name: "fnc_electricitymeter"),
                                value: "301,7",
                                color: .chartPhase1
                            ),
                            HistoryDataSet.LabelData(
                                icon: nil,
                                value: "301,7",
                                color: .chartPhase2
                            )
                        ]
                    ),
                    valueFormatter: ListElectricityMeterValueFormatter(),
                    entries: [],
                    active: true
                )
            ],
            typeName: "Reverse active energy"
        )
    ]
    
    let secondRowState = DataSetsViewState()
    secondRowState.historyEnabled = true
    secondRowState.channelsSets = [
        ChannelChartSets(
            remoteId: 123,
            function: 123,
            name: "Reverse active energy",
            aggregation: .minutes,
            dataSets: [
                HistoryDataSet(
                    type: .electricity,
                    label: .single(HistoryDataSet.LabelData(
                        icon: .suplaIcon(name: "fnc_electricitymeter"),
                        value: "301,7",
                        color: .chartPhase1
                    )),
                    valueFormatter: ListElectricityMeterValueFormatter(),
                    entries: [],
                    active: true
                ),
                HistoryDataSet(
                    type: .electricity,
                    label: .single(HistoryDataSet.LabelData(
                        icon: nil,
                        value: "298,7",
                        color: .chartPhase2
                    )),
                    valueFormatter: ListElectricityMeterValueFormatter(),
                    entries: [],
                    active: true
                )
            ],
            typeName: "Voltage"
        )
    ]

    return VStack {
        DataSetsRow(viewState: firstRowState)
        DataSetsRow(viewState: secondRowState)
    }
}
