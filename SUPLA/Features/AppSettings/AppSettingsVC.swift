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

import RxDataSources
import RxSwift
import RxSwiftExt
import UIKit

class AppSettingsVC: BaseViewControllerVM<AppSettingsViewState, AppSettingsViewEvent, AppSettingsVM> {
    
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        viewModel = AppSettingsVM()
        self.title = Strings.Cfg.appConfigTitle
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func handle(event: AppSettingsViewEvent) {
        switch (event) {
        case .navigateToLocationOrdering:
            coordinator.navigateToLocationOrdering()
        case .navigateToAppPreferences:
            openAppSettings()
        case .navigateToPinSetup(let scope): coordinator.navigateToPinSetup(lockScreenScope: scope)
        case .navigateToPinVerification(let unlockAction): coordinator.navigateToLockScreen(unlockAction: unlockAction)
        case .changeInterfaceStyle(let style):
            (UIApplication.shared.delegate as? AppDelegate)?.window?.overrideUserInterfaceStyle = style
            overrideUserInterfaceStyle = style
        }
    }
    
    private func setupTableView() {
        tableView.register(ChannelHeightCell.self, forCellReuseIdentifier: ChannelHeightCell.id)
        tableView.register(TemperatureUnitCell.self, forCellReuseIdentifier: TemperatureUnitCell.id)
        tableView.register(TitleSwitchCell.self, forCellReuseIdentifier: TitleSwitchCell.id)
        tableView.register(RsOpenningClosingPersentageCell.self, forCellReuseIdentifier: RsOpenningClosingPersentageCell.id)
        tableView.register(TitleArrowButtonCell.self, forCellReuseIdentifier: TitleArrowButtonCell.id)
        tableView.register(PermissionCell.self, forCellReuseIdentifier: PermissionCell.id)
        tableView.register(NightModeCell.self, forCellReuseIdentifier: NightModeCell.id)
        tableView.register(LockScreenCell.self, forCellReuseIdentifier: LockScreenCell.id)
        
        viewModel.stateObservable()
            .map { $0.list }
            .distinctUntilChanged()
            .asDriverWithoutError()
            .drive(tableView.rx.items(dataSource: createDataSource()))
            .disposed(by: self)
    }
    
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<SettingsList> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, _, indexPath, _ in
                switch dataSource[indexPath] {
                case .heightItem(let channelHeight, let callback):
                    return ChannelHeightCell.configure(channelHeight, callback) {
                        self.getCell(for: ChannelHeightCell.id, indexPath)
                    }
                case .temperatureUnitItem(let temperatureUnit, let callback):
                    return TemperatureUnitCell.configure(temperatureUnit, callback) {
                        self.getCell(for: TemperatureUnitCell.id, indexPath)
                    }
                case .switchItem(let title, let selected, let callback):
                    return TitleSwitchCell.configure(title, selected, callback) {
                        self.getCell(for: TitleSwitchCell.id, indexPath)
                    }
                case .rsOpeningPercentageItem(let opening, let callback):
                    return RsOpenningClosingPersentageCell.configure(opening, callback) {
                        self.getCell(for: RsOpenningClosingPersentageCell.id, indexPath)
                    }
                case .arrowButtonItem(let title, let callback):
                    return TitleArrowButtonCell.configure(title, callback) {
                        self.getCell(for: TitleArrowButtonCell.id, indexPath)
                    }
                case .permissionItem(let title, let active, let callback):
                    return PermissionCell.configure(title, active, callback) {
                        self.getCell(for: PermissionCell.id, indexPath)
                    }
                case .darkModeItem(let nightModeSetting, let callback):
                    return NightModeCell.configure(nightModeSetting, callback) {
                        self.getCell(for: NightModeCell.id, indexPath)
                    }
                case .lockScreenItem(let lockScreenScope, let callback):
                    return LockScreenCell.configure(lockScreenScope, callback) {
                        self.getCell(for: LockScreenCell.id, indexPath)
                    }
                }
            }, titleForHeaderInSection: { dataSource, sectionIndex in
                switch dataSource[sectionIndex] {
                case .preferences:
                    return Strings.Cfg.appConfigTitle
                case .permissions:
                    return Strings.AppSettings.permissionsHeader
                }
                
            })
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func getCell<T>(for id: String, _ indexPath: IndexPath) -> T {
        tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! T
    }
}
