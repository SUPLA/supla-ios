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
import FMMoveTableView

class LocationOrderingVC: BaseViewController {

    private let _disposeBag = DisposeBag()

    private let _tableView = SAMoveTableView()
    
    private var _locationData = [_SALocation]()
    private var _viewModel: LocationOrderingVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.Cfg.locationOrdering

        _tableView.translatesAutoresizingMaskIntoConstraints = false
        
        _tableView.dataSource = self
        _tableView.delegate = self
        if #available(iOS 11.0, *) {
            _tableView.dragInteractionEnabled = false
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
    
    private class LocationCell: FMMoveTableViewCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textLabel!.font = UIFont(name: "Open Sans", size: 14)
            let av = UIImageView(image: UIImage(named: "order"))
            av.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
            av.contentMode = .center
            accessoryView = av
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        func touchAtHandle(_ touch: UITouch) -> Bool {
            return accessoryView!.frame.contains(touch.location(in: self))
        }

    }
}

extension LocationOrderingVC: FMMoveTableViewDataSource {
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
    
    func moveTableView(_ tableView: FMMoveTableView!,
                       moveRowFrom fromIndexPath: IndexPath!,
                       to toIndexPath: IndexPath!) {
        let tmp = self._locationData[fromIndexPath.row]
        let dir = fromIndexPath.row < toIndexPath.row ? 1:-1
        var si = fromIndexPath.row
        while dir*si < dir*toIndexPath.row {
            self._locationData[si] = self._locationData[si+dir]
            si += dir
        }
        self._locationData[toIndexPath.row] = tmp
        self._viewModel?.locations.accept(self._locationData)
    }
}

extension LocationOrderingVC: FMMoveTableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LocationOrderingVC: SAMoveTableViewDelegate {
    func tableView(_ tv: SAMoveTableView, touchAtDragHandle touch: UITouch) -> Bool {
        let tblpos = touch.location(in: tv)
        guard let cellip = tv.indexPathForRow(at: tblpos),
              let cell = tv.cellForRow(at: cellip) as? LocationCell else {
                  return false
              }
        return cell.touchAtHandle(touch)
    }
}
