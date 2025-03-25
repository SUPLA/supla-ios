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

class BaseTableViewController<S: ViewState, E: ViewEvent, VM: BaseTableViewModel<S, E>>: BaseViewControllerVM<S, E, VM>, SASectionCellDelegate, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, SACaptionEditorDelegate {
    private var captionEditor: LocationCaptionEditor? = nil
    
    @Singleton<VibrationService> var vibrationService
    @Singleton<RuntimeConfig> private var runtimeConfig
    
    let cellIdForLocation = "LocationCell"
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
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var noContentIcon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconEmpty
        view.tintColor = .gray
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var noContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Main.noEntries
        label.font = .h4
        label.textColor = .gray
        return label
    }()
    
    lazy var noContentButton: UIBorderedButton = {
        let button = UIBorderedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(viewModel: VM) {
        super.init(viewModel: viewModel)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func getToolbarFont() -> UIFont { .suplaTitleBarFont }
    
    func setupTableView() {
        tableView.register(UINib(nibName: Nibs.locationCell, bundle: nil), forCellReuseIdentifier: cellIdForLocation)
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorStyle = .none
        
        dataSource = createDataSource()
        
        viewModel.listItems
            .asDriverWithoutError()
            .do(
                onNext: { [weak self] in
                    if ($0.isEmpty == true) {
                        self?.showLoading(self?.tableView)
                    } else {
                        if ($0[0].items.isEmpty) {
                            self?.showEmptyMessage(self?.tableView)
                        } else {
                            self?.tableView.backgroundView = nil
                        }
                    }
                }
            )
            .drive() { tableView.rx.items(dataSource: dataSource)($0) }
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
            configureCell: { dataSource, _, indexPath, _ in
                switch dataSource[indexPath] {
                case let .scene(scene: scene):
                    return self.configureCell(scene: scene, indexPath: indexPath)
                case let .location(location: location):
                    return self.configureCell(location: location, indexPath: indexPath)
                case let .channelBase(channelBase: channelBase, children: children):
                    return self.configureCell(channelBase: channelBase, children: children, indexPath: indexPath)
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
    
    func configureCell(channelBase: SAChannelBase, children: [ChannelChild], indexPath: IndexPath) -> UITableViewCell {
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
        cell.ivCollapsed.isHidden = !location.isCollapsed(flag: getCollapsedFlag())
        cell.captionEditable = true
        cell.selectionStyle = .none

        return cell
    }
    
    func getCollapsedFlag() -> CollapsedFlag {
        fatalError("getCollapsedFlag() has not been implemented")
    }
    
    func showEmptyMessage(_ tableView: UITableView?) {}
    
    func showLoading(_ tableView: UITableView?) {
        tableView?.backgroundView = createLoadingView()
    }
    
    func createNoContentView(_ buttonLabel: String) -> UIView {
        noContentButton.setAttributedTitle(buttonLabel)
        
        let content = UIView()
        content.addSubview(noContentIcon)
        content.addSubview(noContentLabel)
        content.addSubview(noContentButton)
        
        NSLayoutConstraint.activate([
            noContentIcon.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            noContentIcon.bottomAnchor.constraint(equalTo: noContentLabel.topAnchor),
            noContentIcon.widthAnchor.constraint(equalToConstant: 64),
            noContentIcon.heightAnchor.constraint(equalToConstant: 64),
            
            noContentLabel.bottomAnchor.constraint(equalTo: content.centerYAnchor, constant: -Dimens.distanceSmall),
            noContentLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            
            noContentButton.topAnchor.constraint(equalTo: content.centerYAnchor, constant: Dimens.distanceSmall),
            noContentButton.centerXAnchor.constraint(equalTo: content.centerXAnchor)
        ])
        
        return content
    }
    
    func createLoadingView() -> UIView {
        let loadingIndicatorView = UIActivityIndicatorView()
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let content = UIView()
        content.addSubview(loadingIndicatorView)
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: content.centerXAnchor)
        ])
        
        loadingIndicatorView.startAnimating()
        
        return content
    }
    
    // MARK: SACaptionEditorDelegate
    
    func captionEditorDidFinish(_ editor: SACaptionEditor) {
        captionEditor = nil
        tableView.reloadData()
    }
    
    // MARK: SASectionCellDelegate
    
    func sectionCellTouch(_ section: SASectionCell) {
        viewModel.toggleLocation(remoteId: section.locationId)
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
        
        vibrationService.vibrate()
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
            let sourceCell = session.items.first?.localObject as? MoveableCell,
            let destinationIndexPath = destinationIndexPath,
            let destinationCell = tableView.cellForRow(at: destinationIndexPath) as? MoveableCell
        {
            if (sourceCell.dropAllowed(to: destinationCell)) {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        }
        
        return forbidden
    }
    
    func handleItemMovedEvent(event: ItemMovedEvent) {
        if
            let sourceCell = tableView.cellForRow(at: event.sourceIndex) as? MoveableCell,
            let destinationCell = tableView.cellForRow(at: event.destinationIndex) as? MoveableCell
        {
            viewModel.swapItems(
                firstItem: sourceCell.getRemoteId()!,
                secondItem: destinationCell.getRemoteId()!,
                locationCaption: sourceCell.getLocationCaption()!
            )
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
    
    // MARK: Click event
    
    func handleItemClicked(indexPath: IndexPath) {
        switch (dataSource[indexPath]) {
        case let .scene(scene: scene):
            viewModel.onClicked(onItem: scene)
        case let .channelBase(channelBase: channelBase, _):
            viewModel.onClicked(onItem: channelBase)
        default:
            break
        }
    }
}
