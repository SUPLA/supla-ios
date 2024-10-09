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

struct EnergyData: Equatable {
    let energy: String
    let price: String?

    init(energy: String, price: String? = nil) {
        self.energy = energy
        self.price = price
    }

    init(formatter: ChannelValueFormatter, energy: Double, pricePerUnit: Double, currency: String) {
        self.energy = formatter.format(energy)
        self.price = pricePerUnit.ifNotZero {
            let priceFormatter = NumberFormatter()
            priceFormatter.decimalSeparator = Locale.current.decimalSeparator
            priceFormatter.maximumFractionDigits = 2
            priceFormatter.minimumFractionDigits = 2
            
            return if let price = priceFormatter.string(from: NSNumber(value: energy * $0)) {
                "\(price) \(currency)"
            } else {
                nil
            }
        }
    }
}
