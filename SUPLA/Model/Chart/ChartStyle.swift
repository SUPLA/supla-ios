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
    
protocol ChartStyle: Equatable {
    var leftAxisColor: UIColor { get }
    var rightAxisColor: UIColor { get }
    var drawBarShadow: Bool { get }
    
    func provideMarkerView() -> BaseChartMarkerView
}

struct ThermometerChartStyle: ChartStyle {
    var leftAxisColor: UIColor = .darkRed
    var rightAxisColor: UIColor = .darkBlue
    var drawBarShadow: Bool = false
    
    func provideMarkerView() -> BaseChartMarkerView { SuplaChartMarkerView() }
}

struct HumidityChartStyle: ChartStyle {
    var leftAxisColor: UIColor = .darkBlue
    var rightAxisColor: UIColor = .darkBlue
    var drawBarShadow: Bool = false
    
    func provideMarkerView() -> BaseChartMarkerView { SuplaChartMarkerView() }
}

struct GpmChartStyle: ChartStyle {
    var leftAxisColor: UIColor = .onBackground
    var rightAxisColor: UIColor = .onBackground
    var drawBarShadow: Bool = true
    
    func provideMarkerView() -> BaseChartMarkerView { SuplaChartMarkerView() }
}

struct ElectricityChartStyle: ChartStyle {
    var leftAxisColor: UIColor = .onBackground
    var rightAxisColor: UIColor = .onBackground
    var drawBarShadow: Bool = true
    
    func provideMarkerView() -> BaseChartMarkerView {
        ElectricityChartMarkerView()
    }
}

struct ImpulseCounterChartStyle: ChartStyle {
    var leftAxisColor: UIColor = .onBackground
    var rightAxisColor: UIColor = .onBackground
    var drawBarShadow: Bool = true
    
    func provideMarkerView() -> BaseChartMarkerView { ImpulseCounterChartMarkerView() }
}
