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

final class LockScreenCell: BaseSettingsCell<UISegmentedControl> {
    static let id = "LockScreenCell"

    override func provideActionView() -> UISegmentedControl {
        let channels = [
            Strings.AppSettings.lockScreenNone,
            Strings.AppSettings.lockScreenApp,
            Strings.AppSettings.lockScreenAccounts
        ]
        let view = UISegmentedControl(items: channels)
        view.apportionsSegmentWidthsByContent = true
        return view
    }

    static func configure(_ lockScreenScope: LockScreenScope, _ callback: @escaping (LockScreenScope) -> Void, cellProvider: () -> LockScreenCell) -> LockScreenCell {
        let cell = cellProvider()
        cell.setLabel(Strings.AppSettings.lockScreen)

        cell.actionView.selectedSegmentIndex = lockScreenScope.rawValue
        cell.actionView.rx.selectedSegmentIndex
            .subscribe(onNext: {
                callback(LockScreenScope.from($0))
                cell.actionView.selectedSegmentIndex = lockScreenScope.rawValue
            })
            .disposed(by: cell.disposeBag)

        return cell
    }
}
