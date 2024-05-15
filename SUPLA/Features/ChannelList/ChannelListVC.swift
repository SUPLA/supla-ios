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

class ChannelListVC: ChannelBaseTableViewController<ChannelListViewState, ChannelListViewEvent, ChannelListViewModel> {
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
            navigator?.navigateToLegacyDetail(legacyDetailType: legacyDetailType, channelBase: channelBase)
        case .navigateToSwitchDetail(let item, let pages):
            navigator?.navigateToSwitchDetail(item: item, pages: pages)
        case .navigateToThermostatDetail(let item, let pages):
            navigator?.navigateToThermostatDetail(item: item, pages: pages)
        case .navigateToThermometerDetail(let item, let pages):
            navigator?.navigateToThermometerDetail(item: item, pages: pages)
        case .navigateToGpmDetail(let item, let pages):
            navigator?.navigateToGpmDetail(item: item, pages: pages)
        case .navigateToRollerShutterDetail(let item, let pages):
            navigator?.navigateToRollerShutterDetail(item: item, pages: pages)
        case .showAddWizard:
            navigator?.showAddWizard()
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
    
    func onIssueIconTapped(issueMessage: String) {
        let alert = UIAlertController(title: "SUPLA", message: issueMessage, preferredStyle: .alert)
        let okButton = UIAlertAction(title: Strings.General.ok, style: .default)
        
        alert.title = NSLocalizedString("Warning", comment: "")
        alert.addAction(okButton)
        navigationCoordinator?.viewController.present(alert, animated: true)
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
