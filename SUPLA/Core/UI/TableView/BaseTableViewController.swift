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

class BaseTableViewController<S : ViewState, E : ViewEvent, VM : BaseTableViewModel<S, E>>: BaseViewControllerVM<S, E, VM>, SASectionCellDelegate, UITableViewDelegate {
    
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
    
    func sectionCellTouch(_ section: SASectionCell) {
        viewModel.toggleLocation(remoteId: Int(section.locationId))
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: Nibs.locationCell, bundle: nil), forCellReuseIdentifier: cellIdForLocation)
        tableView.delegate = self
        
        dataSource = createDataSource()
        
        viewModel.listItems
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
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
            }, canMoveRowAtIndexPath: { _, _ in
                return true
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
}
