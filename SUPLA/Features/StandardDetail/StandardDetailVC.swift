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

class StandardDetailVC : SuplaTabBarController<StandardDetailViewState, StandardDetailViewEvent, StandardDetailVM> {
    
    private let remoteId: Int32
    private let pages: [DetailPage]
    
    private var navigator: StandardDetailNavigationCoordinator? {
        get {
            navigationCoordinator as? StandardDetailNavigationCoordinator
        }
    }
    
    init(navigator: StandardDetailNavigationCoordinator, remoteId: Int32, pages: [DetailPage]) {
        self.remoteId = remoteId
        self.pages = pages
        super.init(navigationCoordinator: navigator, viewModel: StandardDetailVM())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.backgroundColor = .background
        
        setupViewController()
    }
    
    override func handle(state: StandardDetailViewState) {
    }

    override func handle(event: StandardDetailViewEvent) {
    }
    
    private func setupViewController() {
        var viewControllers: [UIViewController] = []
        for page in pages {
            switch(page) {
            case .general:
                let vc = SwitchDetailVC(remoteId: remoteId)
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: "General",
                    image: UIImage(named: "list"),
                    tag: DetailTabTag.General.rawValue
                )
                viewControllers.append(vc)
                break
            case .timer:
                let vc = TimerDetailVC()
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: "TImer",
                    image: UIImage(named: "list"),
                    tag: DetailTabTag.Timer.rawValue
                )
                viewControllers.append(vc)
                break
            case .historyEm:
                // TODO: Add history
                break
            case .historyIc:
                // TODO: Add history
                break
            }
        }
        
        self.viewControllers = viewControllers
    }
}

enum DetailTabTag: Int {
    case General = 1
    case Timer = 2
}
