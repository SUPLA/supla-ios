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

import Foundation

class GroupListVC: ChannelBaseTableViewController<GroupListViewState, GroupListViewEvent, GroupListViewModel> {
    private var captionEditor: GroupCaptionEditor? = nil
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        viewModel = GroupListViewModel()
        
        setupView()
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .group }
    
    override func handle(event: GroupListViewEvent) {
        switch (event) {
        case let .navigateToDetail(legacy: legacyDetailType, channelBase: channelBase):
            navigator?.navigateToLegacyDetail(legacyDetailType: legacyDetailType, channelBase: channelBase)
        case let .naviagetToRollerShutterDetail(item, pages):
            navigator?.navigateToRollerShutterDetail(item: item, pages: pages)
        case .openCloud:
            navigator?.openCloud()
        }
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(channelBase: channelBase, children: children, indexPath: indexPath) as! SAChannelCell
        cell.delegate = self
        
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
        tableView.backgroundView = createNoContentView(Strings.Groups.emptyListButton)
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
    }
}

extension GroupListVC: SAChannelCellDelegate {
    func channelButtonClicked(_ cell: SAChannelCell!) {}
    
    func channelCaptionLongPressed(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = GroupCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
}
