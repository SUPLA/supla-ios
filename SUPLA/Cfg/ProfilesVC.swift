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
import RxCocoa
import RxDataSources
class ProfilesVC: BaseViewController {

    // UI controls
    private let headline = UILabel()
    private let tapMessage = UILabel()
    private let profileList = UITableView()

    private let disposeBag = DisposeBag()

    private var vM: ProfilesVM!
    
    func dataSource() -> RxTableViewSectionedReloadDataSource<ProfilesListModel> {
        return RxTableViewSectionedReloadDataSource<ProfilesListModel>(
            configureCell: { dataSource, table, ip, _ in
                switch dataSource[ip] {
                case let .profileItem(id, name, isActive):
                    let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: ip)
                    cell.textLabel?.text = name
                    return cell
                case .addNewProfileItem:
                    let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: ip)
                    cell.textLabel?.text = "Add new"
                    return cell
                }
                
            }
        )
    }

    
    convenience init(navigationCoordinator: NavigationCoordinator) {
        self.init(nibName: nil, bundle: nil)
        self.navigationCoordinator = navigationCoordinator
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.Profiles.Title.short
        view.backgroundColor = .viewBackground

        [ headline, tapMessage, profileList ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }

        if #available(iOS 11, *) {
            headline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: Dimens.screenMargin).isActive = true
        } else {
            headline.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.screenMargin)
              .isActive = true
        }
        headline.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.screenMargin)
          .isActive = true
        headline.rightAnchor.constraint(equalTo: view.rightAnchor, constant: Dimens.screenMargin)
          .isActive = true
        headline.text = Strings.Profiles.Title.plural.uppercased()
        headline.font = .formLabelFont
        headline.textColor = .formLabelColor

        tapMessage.topAnchor.constraint(equalTo: headline.bottomAnchor,
                                        constant: Dimens.elementOffset).isActive = true
        tapMessage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.screenMargin)
          .isActive = true
        tapMessage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: Dimens.screenMargin)
          .isActive = true
        tapMessage.text = Strings.Profiles.tapMessage
        tapMessage.font = .formLabelFont

        profileList.topAnchor.constraint(equalTo: tapMessage.bottomAnchor,
                                         constant: Dimens.Form.elementSpacing).isActive = true
        profileList.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        profileList.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        if #available(iOS 11, *) {
            profileList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
              .isActive = true
        } else {
            profileList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
              .isActive = true
        }

        profileList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let tableData: [ProfilesListModel] = [
            .profileSection(items: [
                .profileItem(id: 0, name: "one", isActive: false),
                .profileItem(id: 1, name: "two", isActive: false)]),
            .commandSection(items: [.addNewProfileItem])
        ]

        Observable.just(tableData)
            .bind(to: profileList.rx.items(dataSource: dataSource()))
            .disposed(by: disposeBag)
        profileList.rx.itemSelected.subscribe(onNext: {
            [weak self] indexPath in
            self?.profileList.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)
    }

}
