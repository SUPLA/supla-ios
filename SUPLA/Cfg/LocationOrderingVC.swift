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

import UIKit
import RxSwift

class LocationOrderingVC: BaseViewController {

    private let _disposeBag = DisposeBag()

    private let _tableView = UITableView()
    
    private var _locationData = [_SALocation]()
    private var _viewModel: LocationOrderingVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.Cfg.locationOrdering

        _tableView.translatesAutoresizingMaskIntoConstraints = false
        
        _tableView.dataSource = self
        _tableView.delegate = self
        if #available(iOS 11.0, *) {
            _tableView.dragDelegate = self
            _tableView.dropDelegate = self
        }
        _tableView.register(LocationCell.self, forCellReuseIdentifier: "locationCell")
        
        view.addSubview(_tableView)
        _tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        _tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        _tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        _tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func bind(viewModel: LocationOrderingVM) {
        _viewModel = viewModel
        viewModel.locations.subscribe { list in
            guard let newList = list.element else { return }
            self._locationData = newList
            DispatchQueue.main.async {
                self._tableView.reloadData()
            }
        }.disposed(by: _disposeBag)
    }
    
    private class LocationCell: UITableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textLabel!.font = UIFont(name: "Open Sans", size: 14)
            accessoryView = UIImageView(image: UIImage(named: "order"))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension LocationOrderingVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _locationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell",
                                                 for: indexPath) as! LocationCell
        let location = _locationData[indexPath.row]
        
        cell.textLabel!.text = location.caption
        
        return cell
    }
}

extension LocationOrderingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 11, *)
extension LocationOrderingVC: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let wrapper = LocationWrapper(position: indexPath.row)
        let provider = NSItemProvider(item: wrapper,
                                      typeIdentifier: "locationdata")
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
}

@available(iOS 11, *)
extension LocationOrderingVC: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard coordinator.items.count == 1 else { return }
        coordinator.items[0].dragItem.itemProvider.loadDataRepresentation(forTypeIdentifier: "locationdata") {data, _ in
            guard let data = data,
                  let locationToMove = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LocationWrapper.self, from: data),
                  let destIP = coordinator.destinationIndexPath,
                  locationToMove.position != destIP.row else {
                return
            }
            
            let tmp = self._locationData[locationToMove.position]
            self._locationData[locationToMove.position] = self._locationData[destIP.row]
            self._locationData[destIP.row] = tmp
            self._viewModel?.locations.accept(self._locationData)
            DispatchQueue.main.async {
                coordinator.drop(coordinator.items[0].dragItem, toRowAt: destIP)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        guard let item = session.items.first else { return false }
        return item.itemProvider.hasItemConformingToTypeIdentifier("locationdata")
    }
    
    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

@objc(LocationWrapper)
fileprivate class LocationWrapper: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    let position: Int
    
    init(position p: Int) {
        position = p
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(position, forKey: "locationid")
    }
    
    required init?(coder: NSCoder) {
        position = coder.decodeInteger(forKey: "locationid")
        super.init()
    }
}
