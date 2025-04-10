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
import RxCocoa
import RxDataSources
import RxSwift
import SharedCore
import SwiftUI

class SceneListVC: BaseTableViewController<SceneListViewState, SceneListViewEvent, SceneListVM> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    static let cellIdForScene = "SceneCell"

    private lazy var overlay: UIHostingController = {
        let view = UIHostingController(rootView: SceneListView(captionChangeDialogViewModel: captionChangeViewModel))
        view.view.translatesAutoresizingMaskIntoConstraints = false
        view.view.backgroundColor = .clear
        view.view.isHidden = true
        return view
    }()
    
    init() {
        super.init(viewModel: SceneListVM())
        setupView()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .scene }
    
    override func handle(event: SceneListViewEvent) {
        switch (event) {
        case .open(let url): coordinator.openUrl(url: url)
        }
    }
    
    override func setupTableView() {
        tableView.register(SceneCell.self, forCellReuseIdentifier: SceneListVC.cellIdForScene)
        super.setupTableView()
    }
    
    override func configureCell(scene: SAScene, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SceneListVC.cellIdForScene,
            for: indexPath
        ) as! SceneCell
        
        cell.delegate = self
        cell.scaleFactor = scaleFactor
        cell.data = scene
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func showEmptyMessage(_ tableView: UITableView?) {
        guard let tableView = tableView else { return }
        tableView.backgroundView = createNoContentView(Strings.Scenes.emptyListButton)
    }
    
    override func setOverlayHidden(_ hidden: Bool) {
        overlay.view.isHidden = hidden
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
        setupOverlay(overlay)
    }
}

extension SceneListVC: SceneCellDelegate {
    func onButtonTapped(buttonType: CellButtonType, remoteId: Int32, data: Any?) {
        viewModel.onButtonClicked(buttonType: buttonType, sceneId: remoteId)
    }
    
    func onIssuesIconTapped(issues: ListItemIssues) {} // Not relevant for scene
    
    func onInfoIconTapped(_ channel: SAChannel) {} // Not relevant for scene
    
    func onCaptionLongPress(_ remoteId: Int32) {
        captionChangeViewModel.show(self, sceneRemoteId: remoteId)
    }
}
