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
import RxDataSources
import RxCocoa

class BaseTableViewController<S : ViewState, E : ViewEvent, VM : BaseTableViewModel<S, E>>: BaseViewControllerVM<S, E, VM>, SASectionCellDelegate, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, SACaptionEditorDelegate {
    
    private var captionEditor: LocationCaptionEditor? = nil
    
    @Singleton<VibrationService> var vibrationService
    @Singleton<RuntimeConfig> private var runtimeConfig
    
    let cellIdForLocation = "LocationCell"
    let tableView = UITableView()
    var dataSource: RxTableViewSectionedReloadDataSource<List>!
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            if oldValue != scaleFactor {
                tableView.reloadData()
            }
        }
    }
    var showChannelInfo: Bool = false {
        didSet {
            if (oldValue != showChannelInfo) {
                tableView.reloadData()
            }
        }
    }
    var navigator: MainNavigationCoordinator? {
        get {
            navigationCoordinator as? MainNavigationCoordinator
        }
    }
    
    override func loadView() {
        self.view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        setupTableView()
        setupConfigObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadTable()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: Nibs.locationCell, bundle: nil), forCellReuseIdentifier: cellIdForLocation)
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorStyle = .none
        
        dataSource = createDataSource()
        
        viewModel.listItems
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: self)
        
        tableView.rx.itemMoved
            .subscribe(onNext: { self.handleItemMovedEvent(event: $0) })
            .disposed(by: self)
        tableView.rx.itemSelected
            .subscribe(onNext: { self.handleItemClicked(indexPath: $0) })
            .disposed(by: self)
    }
    
    func createDataSource() -> RxTableViewSectionedReloadDataSource<List> {
        return RxTableViewSectionedReloadDataSource<List>(
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case let .scene(scene: scene):
                    return self.configureCell(scene: scene, indexPath: indexPath)
                case let .location(location: location):
                    return self.configureCell(location: location, indexPath: indexPath)
                case let .channelBase(channelBase: channelBase):
                    return self.configureCell(channelBase: channelBase, indexPath: indexPath)
                }
            }, canMoveRowAtIndexPath: { dataSource, indexPath in
                switch dataSource[indexPath] {
                case .location(location: _):
                    return false
                default:
                    let cell = self.tableView.cellForRow(at: indexPath) as? MoveableCell
                    return cell?.movementEnabled() ?? false
                }
            }
        )
    }
    
    func configureCell(scene: SAScene, indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func configureCell(channelBase: SAChannelBase, indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func configureCell(location: _SALocation, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdForLocation,
            for: indexPath
        ) as! SASectionCell

        cell.delegate = self
        cell.label.text = location.caption
        cell.locationId = location.location_id?.int32Value ?? 0
        cell.ivCollapsed.isHidden = !location.isCollapsed(flag: .scene)
        cell.captionEditable = true
        cell.selectionStyle = .none

        return cell
    }
    
    // MARK: SACaptionEditorDelegate
    
    func captionEditorDidFinish(_ editor: SACaptionEditor) {
        captionEditor = nil
        tableView.reloadData()
    }
    
    // MARK: SASectionCellDelegate
    
    func sectionCellTouch(_ section: SASectionCell) {
        viewModel.toggleLocation(remoteId: Int(section.locationId))
    }
    
    func sectionCaptionLongPressed(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = LocationCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (dataSource[indexPath]) {
        case .location(location: _):
            return 50
        case .scene(scene: _):
            return 100 * scaleFactor
        case .channelBase(channelBase: _):
            return 100 * scaleFactor
        }
    }
    
    // MARK: Internal stuff
    
    private func setupConfigObserver() {
        runtimeConfig
            .preferencesObservable()
            .asDriverWithoutError()
            .drive(
                onNext: { [weak self] newConfig in
                    self?.scaleFactor = CGFloat(newConfig.scaleFactor)
                    self?.showChannelInfo = newConfig.showChannelInfo
                }
            )
            .disposed(by: self)
    }
    
    // MARK: Drag & Drop
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell is SASectionCell) {
            return []
        }
        if ((cell as? MoveableCell)?.movementEnabled() == false) {
            return []
        }
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = cell
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        
        let forbidden = UITableViewDropProposal(operation: .forbidden)
        if (session.items.count != 1) {
            return forbidden
        }
        
        if
            let sourceCell = session.items.first?.localObject as? SAChannelCell,
            let destinationIndexPath = destinationIndexPath,
            let destinationCell = tableView.cellForRow(at: destinationIndexPath) as? SAChannelCell {
            
            if (sourceCell.channelBase.location?.caption == destinationCell.channelBase.location?.caption) {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        }
        if
            let sourceCell = session.items.first?.localObject as? SceneCell,
            let destinationIndexPath = destinationIndexPath,
            let destinationCell = tableView.cellForRow(at: destinationIndexPath) as? SceneCell {
            
            if (sourceCell.sceneData?.location?.caption == destinationCell.sceneData?.location?.caption) {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        }
        
        return forbidden
    }
    
    func handleItemMovedEvent(event: ItemMovedEvent) {
        if
            let sourceCell = tableView.cellForRow(at: event.sourceIndex) as? SAChannelCell,
            let destinationCell = tableView.cellForRow(at: event.destinationIndex) as? SAChannelCell {
            
            viewModel.swapItems(
                firstItem: sourceCell.channelBase.remote_id,
                secondItem: destinationCell.channelBase.remote_id,
                locationCaption: sourceCell.channelBase.location!.caption!
            )
        }
        
        if
            let sourceCell = tableView.cellForRow(at: event.sourceIndex) as? SceneCell,
            let destinationCell = tableView.cellForRow(at: event.destinationIndex) as? SceneCell {
            
            viewModel.swapItems(
                firstItem: sourceCell.sceneData!.sceneId,
                secondItem: destinationCell.sceneData!.sceneId,
                locationCaption: sourceCell.sceneData!.location!.caption!
            )
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
    // MARK: Click event
    
    func handleItemClicked(indexPath: IndexPath) {
        switch(dataSource[indexPath]) {
        case let .scene(scene: scene):
            viewModel.onClicked(onItem: scene)
            break
        case let .channelBase(channelBase: channelBase):
            viewModel.onClicked(onItem: channelBase)
            break
        default:
            break
        }
    }
}
