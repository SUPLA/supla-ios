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
    private let _headline = UILabel()
    private let _tapMessage = UILabel()
    private let _profileList = UITableView()

    private let _disposeBag = DisposeBag()

    private var _viewModel: ProfilesVM!

    private let _activateProfile = PublishSubject<Int>()
    private let _editProfile = PublishSubject<Int>()
    private let _addNewProfile = PublishSubject<Void>()

    private let _profileCellId = "ProfileCell"
    
    func dataSource() -> RxTableViewSectionedReloadDataSource<ProfilesListModel> {
        let profileCellId = _profileCellId
        return RxTableViewSectionedReloadDataSource<ProfilesListModel>(
            configureCell: { [weak self] dataSource, table, ip, _ in
                switch dataSource[ip] {
                case let .profileItem(id, name, isActive):
                    let cell = table.dequeueReusableCell(withIdentifier: profileCellId, for: ip)
                      as! ProfileItemCell
                    cell.setProfileItem(dataSource[ip])
                    cell.editProfileTrigger
                    .subscribe { _ in
                                   print("edit item \(id)")
                    }.disposed(by: cell.disposeBag)
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

        [ _headline, _tapMessage, _profileList ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }

        if #available(iOS 11, *) {
            _headline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: Dimens.screenMargin).isActive = true
        } else {
            _headline.topAnchor.constraint(equalTo: view.topAnchor, constant: Dimens.screenMargin)
              .isActive = true
        }
        _headline.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.screenMargin)
          .isActive = true
        _headline.rightAnchor.constraint(equalTo: view.rightAnchor, constant: Dimens.screenMargin)
          .isActive = true
        _headline.text = Strings.Profiles.Title.plural.uppercased()
        _headline.font = .formLabelFont
        _headline.textColor = .formLabelColor

        _tapMessage.topAnchor.constraint(equalTo: _headline.bottomAnchor,
                                         constant: Dimens.elementOffset).isActive = true
        _tapMessage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Dimens.screenMargin)
          .isActive = true
        _tapMessage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: Dimens.screenMargin)
          .isActive = true
        _tapMessage.text = Strings.Profiles.tapMessage
        _tapMessage.font = .formLabelFont

        _profileList.topAnchor.constraint(equalTo: _tapMessage.bottomAnchor,
                                          constant: Dimens.Form.elementSpacing).isActive = true
        _profileList.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        _profileList.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        if #available(iOS 11, *) {
            _profileList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
              .isActive = true
        } else {
            _profileList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
              .isActive = true
        }

        _profileList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        _profileList.register(ProfileItemCell.self,
                              forCellReuseIdentifier: _profileCellId)

        let tableData: [ProfilesListModel] = [
            .profileSection(items: [
                .profileItem(id: 0, name: "one", isActive: false),
                .profileItem(id: 1, name: "two", isActive: true)]),
            .commandSection(items: [.addNewProfileItem])
        ]


        

        let ds = dataSource()
        Observable.just(tableData)
            .bind(to: _profileList.rx.items(dataSource: ds))
            .disposed(by: _disposeBag)
        _profileList.rx.itemSelected.subscribe(onNext: {
            [weak self] indexPath in
            guard let self = self else { return }
            switch ds[indexPath] {
                case .profileItem(let id, _, _):
                    print("tap on profile \(id)")
                    self._activateProfile.on(.next(id))
                case .addNewProfileItem:
                    print("tap on command add new")
                    self._addNewProfile.on(.next(()))
            }
            self._profileList.deselectRow(at: indexPath, animated: true)
        }).disposed(by: _disposeBag)
    }

    func bind(viewModel: ProfilesVM) {
        _viewModel = viewModel
        let inputs = ProfilesVM.Inputs(
          onActivate: _activateProfile,
          onEdit: _editProfile,
          onAddNew: _addNewProfile
        )

        _viewModel.bind(inputs: inputs)
    }

}
