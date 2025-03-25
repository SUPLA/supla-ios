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

class SceneListVC: BaseTableViewController<SceneListViewState, SceneListViewEvent, SceneListVM> {
    @Singleton<SuplaAppCoordinator> private var coordinator
    
    static let cellIdForScene = "SceneCell"
    private var captionEditor: SceneCaptionEditor? = nil
    
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
        tableView.backgroundView = createNoContentView(Strings.Scenes.emptyListButton)
    }
    
    private func setupView() {
        viewModel.bind(noContentButton.rx.tap) { [weak self] in self?.viewModel.onNoContentButtonClicked() }
    }
}

extension SceneListVC: SceneCellDelegate {
    func onButtonTapped(buttonType: CellButtonType, remoteId: Int32, data: Any?) {
        viewModel.onButtonClicked(buttonType: buttonType, sceneId: remoteId)
    }
    
    func onIssuesIconTapped(issues: ListItemIssues) {} // Not relevant for scene
    
    func onInfoIconTapped(_ channel: SAChannel) {} // Not relevant for scene
    
    func onCaptionLongPress(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = SceneCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
}
