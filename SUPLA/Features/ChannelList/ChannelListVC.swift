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

import SharedCore

class ChannelListVC: ChannelBaseTableViewController<ChannelListViewState, ChannelListViewEvent, ChannelListViewModel> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private var captionEditor: ChannelCaptionEditor? = nil
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        viewModel = ChannelListViewModel()
        
        setupView()
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .channel }
    
    override func handle(event: ChannelListViewEvent) {
        switch (event) {
        case .navigateToDetail(let legacyDetailType, let channelBase):
            coordinator.navigateToLegacyDetail(legacyDetailType, channelBase: channelBase)
        case .navigateToSwitchDetail(let item, let pages):
            coordinator.navigateToSwitchDetail(item: item, pages: pages)
        case .navigateToThermostatDetail(let item, let pages):
            coordinator.navigateToThermostatDetail(item: item, pages: pages)
        case .navigateToThermometerDetail(let item, let pages):
            coordinator.navigateToThermometerDetail(item: item, pages: pages)
        case .navigateToGpmDetail(let item, let pages):
            coordinator.navigateToGpmDetail(item: item, pages: pages)
        case .navigateToRollerShutterDetail(let item, let pages):
            coordinator.navigateToWindowDetail(item: item, pages: pages)
        case .navigateToElectricityMeterDetail(let item, let pages):
            coordinator.navigateToElectricityMeterDetail(item: item, pages: pages)
        case .navigateToImpulseCounterDetail(let item, let pages):
            coordinator.navigateToImpulseCounterDetail(item: item, pages: pages)
        case .navigateToHumidityDetail(let item, let pages):
            coordinator.navigateToHumidityDetail(item: item, pages: pages)
        case .navigateToValveDetail(let item, let pages):
            coordinator.navigateToValveDetail(item: item, pages: pages)
        case .navigateToContainerDetail(let item, let pages):
            coordinator.navigateToContainerDetail(item: item, pages: pages)
        case .showAddWizard:
            coordinator.navigateToAddWizard()
        case .showValveWarningDialog(let remoteId, let message, let action):
            showValveWarningDialog(remoteId, message, action)
        }
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(channelBase: channelBase, children: children, indexPath: indexPath)
        
        if let channelCell = cell as? SAChannelCell {
            channelCell.delegate = self
        }
        if let baseCell = cell as? MGSwipeTableCell {
            baseCell.delegate = self
        }
        
        return cell
    }
    
    override func captionEditorDidFinish(_ editor: SACaptionEditor) {
        if (editor == captionEditor) {
            captionEditor = nil
            tableView.reloadData()
        } else {
            super.captionEditorDidFinish(editor)
        }
    }
    
    override func showEmptyMessage(_ tableView: UITableView?) {
        guard let tableView = tableView else { return }
        tableView.backgroundView = createNoContentView(Strings.Menu.addDevice)
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
    }
    
    private func showValveWarningDialog(_ remoteId: Int32, _ message: String, _ action: Action) {
        let alert = UIAlertController(title: Strings.General.warning, message: message, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: Strings.General.yes, style: .default) { [weak self] _ in
            self?.viewModel.forceAction(action, remoteId: remoteId)
        }
        let noButton = UIAlertAction(title: Strings.General.no, style: .cancel)
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        coordinator.present(alert, animated: true)
    }
    
}

extension ChannelListVC: SAChannelCellDelegate {
    func channelButtonClicked(_ cell: SAChannelCell!) {}
    
    func channelCaptionLongPressed(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = ChannelCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
}

extension ChannelListVC: BaseCellDelegate {
    func onButtonTapped(buttonType: CellButtonType, remoteId: Int32, data: Any?) {
        viewModel.onButtonClicked(buttonType: buttonType, data: data)
    }
    
    func onIssuesIconTapped(issues: ListItemIssues) {
        let alert = UIAlertController(title: "SUPLA", message: issues.message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: Strings.General.ok, style: .default)
        
        alert.title = NSLocalizedString("Warning", comment: "")
        alert.addAction(okButton)
        coordinator.present(alert, animated: true)
    }
    
    func onCaptionLongPress(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = ChannelCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
    
    func onInfoIconTapped(_ channel: SAChannel) {
        SAChannelStatePopup.globalInstance().show(channel)
    }
}
