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

final class TitleSwitchCell: BaseSettingsCell<UISwitch> {
    
    static let id = "TitleSwitchCell"
    
    override func provideActionView() -> UISwitch {
        return UISwitch()
    }
    
    static func configure(_ label: String, _ selected: Bool, _ callback: @escaping (Bool) -> Void, cellProvider: () -> TitleSwitchCell) -> TitleSwitchCell {
        let cell = cellProvider()
        cell.setLabel(label)
        cell.actionView.setOn(selected, animated: false)
        cell.actionView.rx.isOn
            .subscribe(onNext: { callback($0) })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}
