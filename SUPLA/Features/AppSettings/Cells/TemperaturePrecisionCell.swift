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
    
final class TemperaturePrecisionCell: BaseSettingsCell<UISegmentedControl> {
    
    static let id = "TemperaturePrecisionCell"
    
    override func provideActionView() -> UISegmentedControl {
        let separator = Locale.current.decimalSeparator ?? ","
        let view = UISegmentedControl(items: ["X\(separator)X°", "X\(separator)XX°"])
        view.setWidth(60, forSegmentAt: 0)
        view.setWidth(60, forSegmentAt: 1)
        return view
    }
    
    static func configure(_ precision: Int, _ callback: @escaping (Int) -> Void, cellProvider: () -> TemperaturePrecisionCell) -> TemperaturePrecisionCell {
        let cell = cellProvider()
        cell.setLabel(Strings.AppSettings.temperaturePrecision)
        
        cell.actionView.rx.selectedSegmentIndex
            .subscribe(onNext: { callback($0) })
            .disposed(by: cell.disposeBag)
        cell.actionView.selectedSegmentIndex = precision - 1
        
        return cell
    }
}

