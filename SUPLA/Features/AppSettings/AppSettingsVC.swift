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
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    init() {
        super.init(viewModel: AppSettingsVM())
        self.title = Strings.Cfg.appConfigTitle
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(endEditingRecognizer())
    }
    
    override func handle(event: AppSettingsViewEvent) {
        switch (event) {
        case .navigateToAppPreferences:
            openAppSettings()
        case .changeInterfaceStyle(let style):
            (view.window?.windowScene?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = style
            overrideUserInterfaceStyle = style
        }
    }
    
    private func setupTableView() {
        tableView.register(ChannelHeightCell.self, forCellReuseIdentifier: ChannelHeightCell.id)
        tableView.register(TemperatureUnitCell.self, forCellReuseIdentifier: TemperatureUnitCell.id)
        tableView.register(TemperaturePrecisionCell.self, forCellReuseIdentifier: TemperaturePrecisionCell.id)
        tableView.register(TitleSwitchCell.self, forCellReuseIdentifier: TitleSwitchCell.id)
        tableView.register(RsOpenningClosingPersentageCell.self, forCellReuseIdentifier: RsOpenningClosingPersentageCell.id)
        tableView.register(TitleArrowButtonCell.self, forCellReuseIdentifier: TitleArrowButtonCell.id)
        tableView.register(PermissionCell.self, forCellReuseIdentifier: PermissionCell.id)
        tableView.register(NightModeCell.self, forCellReuseIdentifier: NightModeCell.id)
        tableView.register(LockScreenCell.self, forCellReuseIdentifier: LockScreenCell.id)
        tableView.register(EditTextCell.self, forCellReuseIdentifier: EditTextCell.id)
        
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
                case .temperaturePrecisionItem(let precision, let callback):
                    return TemperaturePrecisionCell.configure(precision, callback) {
                        self.getCell(for: TemperaturePrecisionCell.id, indexPath)
                    }
                case .switchItem(let title, let selected, let callback, let enabled):
                    return TitleSwitchCell.configure(title, selected, enabled, callback) {
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
                case .batteryLevelWarning(let level, let callback):
                    return EditTextCell.configure(Strings.AppSettings.batteryLevelWarning, level, callback) {
                        self.getCell(for: EditTextCell.id, indexPath)
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
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        tableView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset.bottom = 0
    }
    
    private func endEditingRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        return tap
    }
    
    @objc
    private func endEditing() {
        view.endEditing(true)
        tableView.contentInset.bottom = 0
    }
    
}

extension AppSettingsVC: NavigationSubcontroller {
    func screenTakeoverAllowed() -> Bool { false }
}
