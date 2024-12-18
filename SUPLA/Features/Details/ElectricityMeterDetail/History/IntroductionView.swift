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

import SwiftUI

extension ElectricityMeterHistoryFeature {
    enum IntroductionPage: Int, Identifiable {
        case firstForSinglePhase, firstForMultiplePhases, second
        
        var id: Int { rawValue }
    }
    
    final class IntroductionState: ObservableObject {
        @Published var pages: [IntroductionPage] = []
    }
    
    struct IntroductionView: SwiftUI.View {
        @ObservedObject var viewState: IntroductionState
        
        var onClose: () -> Void = {}
        
        @State private var selectedPage = 0
        
        var body: some SwiftUI.View {
            ZStack(alignment: .topLeading) {
                Color.Supla.infoScrim.ignoresSafeArea()
                TabView(selection: $selectedPage) {
                    ForEach(viewState.pages) { page in
                        switch (page) {
                        case .firstForSinglePhase:
                            FirstPageSinglePhase {
                                withAnimation { selectedPage = 1 }
                            }.tag(0)
                        case .firstForMultiplePhases:
                            FirstPageMutliplePhases {
                                withAnimation { selectedPage = 1 }
                            }.tag(0)
                        case .second: SecondPage { onClose() }.tag(1)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    private struct SelectorFrame: View {
        var text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        var body: some View {
            SwiftUI.Text(text)
                .frame(width: 80, alignment: .leading)
                .fontBodyMedium()
                .textColor(Color.Supla.onBackground)
                .padding(6)
                .padding([.trailing], 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.Supla.outline)
                )
        }
    }

    private struct FirstPageMutliplePhases: View {
        var onClick: () -> Void = {}
        
        private static let sets = mockSetsForMultiplePhases()

        var body: some View {
            VStack {
                HStack(alignment: .top) {
                    DataSetContainer(channelSet: FirstPageMutliplePhases.sets, historyEnabled: true)
                        .padding(Dimens.distanceTiny)
                        .background(Color.Supla.surface)
                        .cornerRadius(Dimens.radiusDefault)
                        .padding(Dimens.distanceTiny)
                    Spacer()
                    Image(.Icons.arrowRight)
                        .resizable()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .padding(Distance.default)
                        .foregroundColor(Color.Supla.onPrimary)
                        .onTapGesture { onClick() }
                }
                SwiftUI.Text(Strings.ElectricityMeter.infoDataSetMultiplePhase)
                    .fontBodyMedium()
                    .multilineTextAlignment(.center)
                    .textColor(.Supla.onPrimary)
                    .padding([.top], Distance.small)
                    .padding([.leading, .trailing], Distance.default)
                Spacer()
            }
        }
    }

    private struct FirstPageSinglePhase: View {
        var onClick: () -> Void = {}
        
        private static let sets = mockSetsForSinglePhase()

        var body: some View {
            VStack {
                HStack(alignment: .top) {
                    DataSetContainer(channelSet: FirstPageSinglePhase.sets, historyEnabled: true)
                        .padding(Dimens.distanceTiny)
                        .background(Color.Supla.surface)
                        .cornerRadius(Dimens.radiusDefault)
                        .padding(Dimens.distanceTiny)
                    Spacer()
                    Image(.Icons.arrowRight)
                        .resizable()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .padding(Distance.default)
                        .foregroundColor(Color.Supla.onPrimary)
                        .onTapGesture { onClick() }
                }
                SwiftUI.Text(Strings.ElectricityMeter.infoDataSetSinglePhase)
                    .fontBodyMedium()
                    .multilineTextAlignment(.center)
                    .textColor(.Supla.onPrimary)
                    .padding([.top], Distance.small)
                    .padding([.leading, .trailing], Distance.default)
                Spacer()
            }
        }
    }
    
    private struct SecondPage: View {
        var onClick: () -> Void = {}
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Image(.Icons.close)
                        .resizable()
                        .frame(width: Dimens.iconSize, height: Dimens.iconSize)
                        .padding(Distance.default)
                        .foregroundColor(Color.Supla.onPrimary)
                        .onTapGesture { onClick() }
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            SwiftUI.Text(Strings.Charts.rangeLabel.uppercased())
                                .fontPickerLabel()
                            SelectorFrame(Strings.Charts.lastWeek)
                        }
                        .padding(Dimens.distanceSmall)
                        .background(Color.Supla.surface)
                        .cornerRadius(Dimens.radiusDefault)
                        
                        Text(Strings.ElectricityMeter.infoRange)
                            .frame(width: 160, alignment: .leading)
                            .fontBodyMedium()
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Supla.onPrimary)
                            .padding([.top], Distance.small)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        VStack(alignment: .leading) {
                            SwiftUI.Text(Strings.Charts.dataTypeLabel.uppercased())
                                .fontPickerLabel()
                            SelectorFrame(Strings.Charts.minutes)
                        }
                        .padding(Dimens.distanceSmall)
                        .background(Color.Supla.surface)
                        .cornerRadius(Dimens.radiusDefault)
                        
                        Text(Strings.ElectricityMeter.infoDataType)
                            .frame(width: 160, alignment: .leading)
                            .fontBodyMedium()
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Supla.onPrimary)
                            .padding([.top], Distance.small)
                    }
                }
                .padding(Distance.tiny)
                
                Spacer()
            }
        }
    }
}

private func mockSetsForMultiplePhases() -> ChannelChartSets {
    let formatter = ListElectricityMeterValueFormatter()

    return ChannelChartSets(
        remoteId: 124,
        function: 123,
        name: Strings.ElectricityMeter.forwardActiveEnergy,
        aggregation: .minutes,
        dataSets: [
            HistoryDataSet(
                type: .electricity,
                label: .multiple(
                    [
                        HistoryDataSet.LabelData(
                            icon: .suplaIcon(name: "fnc_electricitymeter"),
                            value: formatter.format(78.08, withUnit: false),
                            color: .chartPhase1
                        ),
                        HistoryDataSet.LabelData(
                            icon: nil,
                            value: formatter.format(73.45, withUnit: false),
                            color: .chartPhase2
                        ),
                        HistoryDataSet.LabelData(
                            icon: nil,
                            value: formatter.format(28.66, withUnit: false),
                            color: .chartPhase3
                        )
                    ]
                ),
                valueFormatter: formatter,
                entries: [],
                active: true
            )
        ],
        typeName: Strings.ElectricityMeter.forwardActiveEnergy
    )
}

private func mockSetsForSinglePhase() -> ChannelChartSets {
    let formatter = ListElectricityMeterValueFormatter()

    return ChannelChartSets(
        remoteId: 124,
        function: 123,
        name: Strings.ElectricityMeter.forwardActiveEnergy,
        aggregation: .minutes,
        dataSets: [
            HistoryDataSet(
                type: .electricity,
                label: .multiple(
                    [
                        HistoryDataSet.LabelData(
                            icon: .suplaIcon(name: "fnc_electricitymeter"),
                            value: formatter.format(78.08, withUnit: false),
                            color: .chartPhase1
                        )
                    ]
                ),
                valueFormatter: formatter,
                entries: [],
                active: true
            )
        ],
        typeName: Strings.ElectricityMeter.forwardActiveEnergy
    )
}

#Preview("Single phase") {
    var state = ElectricityMeterHistoryFeature.IntroductionState()
    state.pages = [.firstForSinglePhase, .second]
    
    return ElectricityMeterHistoryFeature.IntroductionView(viewState: state)
}

#Preview("Multiple phases") {
    var state = ElectricityMeterHistoryFeature.IntroductionState()
    state.pages = [.firstForMultiplePhases, .second]
    
    return ElectricityMeterHistoryFeature.IntroductionView(viewState: state)
}
