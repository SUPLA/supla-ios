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

class HomeVC : BaseViewControllerVM<HomeViewState, HomeViewEvent, HomeViewModel> {
    
    private let suplaTabBarController = UITabBarController()
    private var navigator: MainNavigationCoordinator? {
        get {
            navigationCoordinator as? MainNavigationCoordinator
        }
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        viewModel = HomeViewModel()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.NavBar.titleSupla
        
        setupTabBarController()
        setupToolbar()
    }
    
    private func setupToolbar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            style: .plain, target: self,
            action: #selector(onMenuToggle)
        )
    }
    
    @objc
    private func onMenuToggle() {
        navigator?.toggleMenuBar()
    }
    
    private func setupTabBarController() {
        suplaTabBarController.tabBar.barTintColor = .background
        suplaTabBarController.tabBar.tintColor = .suplaGreen
        suplaTabBarController.tabBar.unselectedItemTintColor = .textLight
        suplaTabBarController.tabBar.isTranslucent = false
        suplaTabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, 0)
        suplaTabBarController.tabBar.layer.shadowRadius = 2
        suplaTabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        suplaTabBarController.tabBar.layer.shadowOpacity = 0.3
        suplaTabBarController.tabBar.backgroundColor = .background
        
        let channelListVC = ChannelListVC()
        channelListVC.tabBarItem = UITabBarItem(
            title: Strings.Main.channels,
            image: UIImage(named: "list"),
            tag: HomeTabTag.Channels.rawValue
        )
        let groupListVC = GroupListVC()
        groupListVC.tabBarItem = UITabBarItem(
            title: Strings.Main.groups,
            image: UIImage(named: "bottom_bar_groups"),
            tag: HomeTabTag.Groups.rawValue
        )
        let sceneListVC = SceneListVC()
        sceneListVC.tabBarItem = UITabBarItem(
            title: Strings.Main.scenes,
            image: UIImage(named: "coffee"),
            tag: HomeTabTag.Scenes.rawValue
        )
        
        suplaTabBarController.viewControllers = [channelListVC, groupListVC, sceneListVC]
        self.view.addSubview(suplaTabBarController.view)
    }
}

enum HomeTabTag: Int {
    case Channels = 1
    case Groups = 2
    case Scenes = 3
}
