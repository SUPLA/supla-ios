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
    
class ChartColors {
    private let colors: [UIColor]
    private var position: Int = 0
    
    init(colors: [UIColor]) {
        self.colors = colors
    }
    
    func nextColor() -> UIColor {
        let color = colors[position % colors.count]
        position += 1
        return color
    }
}

final class TemperatureColors: ChartColors {
    init() {
        super.init(colors: [TemperatureColors.standard, .chartTemperature2])
    }
    
    static let standard: UIColor = .chartTemperature1
}

final class HumidityColors: ChartColors {
    init() {
        super.init(colors: [HumidityColors.standard, .chartHumidity2])
    }
    
    static let standard: UIColor = .chartHumidity1
}
