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


class ScenesVC: UIViewController {
    
    private let _tableView = UITableView()
    
    private let _sectionCellId = "section"
    private let _sceneCellId = "scene"
    

    override func loadView() {
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view = _tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow

        _tableView.dataSource = self
        _tableView.delegate = self
        if #available(iOS 11.0, *) {
            _tableView.dragInteractionEnabled = false
        }
        _tableView.register(SceneCell.self,
                            forCellReuseIdentifier: _sceneCellId)
        _tableView.register(UINib(nibName: "SectionCell", bundle: nil),
                            forCellReuseIdentifier: _sectionCellId)
    }
}

extension ScenesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _sceneCellId,
                                                 for: indexPath) as! SceneCell
        
        //cell.sceneData
        
        return cell
    }
    
    
}

extension ScenesVC: UITableViewDelegate {
    
}
