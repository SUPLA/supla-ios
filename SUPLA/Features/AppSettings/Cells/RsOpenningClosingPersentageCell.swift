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

final class RsOpenningClosingPersentageCell: BaseSettingsCell<UISegmentedControl> {
    
    static let id = "RsOpenningClosingPersentageCell"
    
    override func provideActionView() -> UISegmentedControl {
        return UISegmentedControl(items: [
            Strings.Cfg.showOpeningModeOpening,
            Strings.Cfg.showOpeningModeClosing
        ])
    }
    
    static func configure(_ opening: Bool, _ callback: @escaping (Bool) -> Void, cellProvider: () -> RsOpenningClosingPersentageCell) -> RsOpenningClosingPersentageCell {
        let cell = cellProvider()
        cell.setLabel(Strings.Cfg.rsDisplayMode)
        cell.actionView.selectedSegmentIndex = opening ? 0 : 1
        cell.actionView.rx.selectedSegmentIndex
            .subscribe(onNext: { callback($0 == 0) })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}
