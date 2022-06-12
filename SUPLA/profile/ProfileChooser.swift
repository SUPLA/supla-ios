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


@objc
class ProfileChooser: NSObject {

    @objc
    weak var delegate: ProfileChooserDelegate?
    
    private let _profileManager: ProfileManager

    @objc
    init(profileManager: ProfileManager) {
        _profileManager = profileManager
        super.init()
    }

    @objc
    func show(from parent: UIViewController) {
        let vc = ProfileChooserVC(profiles: _profileManager.getAllProfiles())
        vc.delegate = self
        parent.present(vc, animated: true)
    }
}

extension ProfileChooser: ProfileChooserVCDelegate {
    func profileChooserDidDismiss(selectedProfile id: ProfileID?) {
        let changed: Bool
        
        if let id = id {
            changed = _profileManager.activateProfile(id: id, force: false)
        } else {
            changed = false
        }
        delegate?.profileChooserDidDismiss(profileChanged: changed)
    }
}

@objc
protocol ProfileChooserDelegate {
    func profileChooserDidDismiss(profileChanged: Bool)
}

@objc
protocol ProfileChooserVCDelegate {
    func profileChooserDidDismiss(selectedProfile: ProfileID?)
}

fileprivate class ProfileChooserVC: UIViewController {
    weak var delegate: ProfileChooserVCDelegate?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let profileList = UITableView()

    private let cellId = "ProfileCell"
    private var cellHeightConstraint: NSLayoutConstraint?


    private let profiles: [AuthProfileItem]

    init(profiles: [AuthProfileItem]) {
        self.profiles = profiles

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen

        profileList.dataSource = self
        profileList.delegate = self
        profileList.register(ProfileItemCell.self,
                             forCellReuseIdentifier: cellId)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let gr = UITapGestureRecognizer(target: self,
                                        action: #selector(onBackgroundTap(_:)))
        gr.delegate = self
        view.addGestureRecognizer(gr)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.backgroundColor = .white
        
        [titleLabel, profileList].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview($0)
        }
        titleLabel.text = Strings.ProfileChooser.title
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                        constant: Dimens.Form.elementSpacing).isActive = true

        profileList.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileList.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        profileList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                         constant: Dimens.screenMargin).isActive = true
        profileList.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                            constant: -Dimens.Form.elementSpacing).isActive = true
        profileList.widthAnchor.constraint(equalToConstant:240).isActive = true

        profileList.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor,
                                            multiplier: 0.6,
                                            constant: 0)
          .isActive = true
        
    }

    @objc private func onBackgroundTap(_ gr: UIGestureRecognizer) {
        presentingViewController?.dismiss(animated: true) { 
            self.delegate?.profileChooserDidDismiss(selectedProfile: nil)
        }
    }


    override func updateViewConstraints() {
        guard let cell = profileList.cellForRow(at: IndexPath(row: 0, section: 0)) else {
            return
        }
        let height = cell.frame.size.height
        cellHeightConstraint?.isActive = false        
        cellHeightConstraint = profileList.heightAnchor
          .constraint(equalToConstant: height * CGFloat(profiles.count))
        cellHeightConstraint!.priority = .defaultLow
        cellHeightConstraint!.isActive = true
        super.updateViewConstraints()
    }
}

extension ProfileChooserVC: UITableViewDataSource {

    func tableView(_ tv: UITableView, numberOfRowsInSection: Int) -> Int {
        return profiles.count
    }


    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: cellId,
                                          for: ip) as! ProfileItemCell
        let profile = profiles[ip.row]
        
        cell.setProfileItem(.profileItem(id: profile.objectID,
                                         name: profile.displayName,
                                         isActive: profile.isActive))
        return cell
    }
}

extension ProfileChooserVC: UITableViewDelegate {
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let profile = profiles[ip.row]
        presentingViewController?.dismiss(animated: true) { 
            self.delegate?.profileChooserDidDismiss(selectedProfile: profile.objectID)
        }
    }
}

extension ProfileChooserVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gr: UIGestureRecognizer,
                           shouldReceive touch:  UITouch) -> Bool {
        return !containerView.frame.contains(touch.location(in: view))
    }
}
