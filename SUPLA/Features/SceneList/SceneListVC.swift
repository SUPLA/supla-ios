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
import RxSwift
import RxDataSources

class SceneListVC : BaseTableViewController<SceneListViewState, SceneListViewEvent, SceneListVM> {
    
    static let cellIdForScene = "SceneCell"
    private var captionEditor: SceneCaptionEditor? = nil
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        viewModel = SceneListVM()
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .scene }
    
    override func setupTableView() {
        tableView.register(SceneCell.self,forCellReuseIdentifier: SceneListVC.cellIdForScene)
        super.setupTableView()
    }
    
    override func configureCell(scene: SAScene, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SceneListVC.cellIdForScene,
            for: indexPath
        ) as! SceneCell
        
        cell.delegate = self
        cell.scaleFactor = self.scaleFactor
        cell.sceneData = scene
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
}

extension SceneListVC: SceneCellDelegate {
    func onCaptionLongPress(_ scene: SAScene) {
        vibrationService.vibrate()
        
        captionEditor = SceneCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: scene.sceneId)
    }
}
