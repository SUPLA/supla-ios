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
import SwiftUI

class GroupListVC: ChannelBaseTableViewController<GroupListViewState, GroupListViewEvent, GroupListViewModel> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    private lazy var overlay: UIHostingController = {
        let view = UIHostingController(rootView: GroupListView(captionChangeDialogViewModel: captionChangeViewModel))
        view.view.translatesAutoresizingMaskIntoConstraints = false
        view.view.backgroundColor = .clear
        view.view.isHidden = true
        return view
    }()
    
    init() {
        super.init(viewModel: GroupListViewModel())
        setupView()
    }
    
    @available(*, unavailable)
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .group }
    
    override func handle(event: GroupListViewEvent) {
        switch (event) {
        case let .navigateToDetail(legacy: legacyDetailType, channelBase: channelBase):
            coordinator.navigateToLegacyDetail(legacyDetailType, channelBase: channelBase)
        case let .navigateToRollerShutterDetail(item, pages):
            coordinator.navigateToWindowDetail(item: item, pages: pages)
        case let .navigateToGateDetail(item, pages):
            coordinator.navigateToGateDetail(item: item, pages: pages)
        case let .navigateToSwitchDetail(item, pages):
            coordinator.navigateToSwitchDetail(item: item, pages: pages)
        case let .open(url):
            coordinator.openUrl(url: url)
        }
    }
    
    override func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(channelBase: channelBase, children: children, indexPath: indexPath) as! SAChannelCell
        cell.delegate = self
        
        return cell
    }
    
    override func showEmptyMessage(_ tableView: UITableView?) {
        guard let tableView = tableView else { return }
        tableView.backgroundView = createNoContentView(Strings.Groups.emptyListButton)
    }
    
    override func setOverlayHidden(_ hidden: Bool) {
        overlay.view.isHidden = hidden
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
        setupOverlay(overlay)
    }
}

extension GroupListVC: SAChannelCellDelegate {
    func infoIconPressed(_ remoteId: Int32) {}
    
    func channelButtonClicked(_ cell: SAChannelCell!) {}
    
    func channelCaptionLongPressed(_ remoteId: Int32) {
        captionChangeViewModel.show(self, groupRemoteId: remoteId)
    }
}
