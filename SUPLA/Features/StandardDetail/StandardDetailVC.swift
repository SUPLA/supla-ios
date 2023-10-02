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
    
    @Singleton<RuntimeConfig> private var runtimeConfig
    
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
        
        viewModel.loadChannel(remoteId: remoteId)
        
        setupViewController()
    }
    
    override func handle(state: StandardDetailViewState) {
        if let title = state.title { self.title = title }
    }

    override func handle(event: StandardDetailViewEvent) {
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        runtimeConfig.setDetailOpenedPage(remoteId: remoteId, openedPage: item.tag - 1)
    }
    
    private func setupViewController() {
        var viewControllers: [UIViewController] = []
        for page in pages {
            switch(page) {
            case .general:
                let vc = SwitchDetailVC(remoteId: remoteId)
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: Strings.StandardDetail.tabGeneral,
                    image: .iconGeneral,
                    tag: DetailTabTag.General.rawValue
                )
                viewControllers.append(vc)
                break
            case .timer:
                let vc = TimerDetailVC(remoteId: remoteId)
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: Strings.StandardDetail.tabTimer,
                    image: .iconTimer,
                    tag: DetailTabTag.Timer.rawValue
                )
                viewControllers.append(vc)
                break
            case .historyEm:
                let vc = DetailViewController(detailViewType: .em, remoteId: remoteId)
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: Strings.StandardDetail.tabMetrics,
                    image: .iconMetrics,
                    tag: DetailTabTag.History.rawValue
                )
                viewControllers.append(vc)
                break
            case .historyIc:
                let vc = DetailViewController(detailViewType: .ic, remoteId: remoteId)
                vc.navigationCoordinator = navigator
                vc.tabBarItem = UITabBarItem(
                    title: Strings.StandardDetail.tabMetrics,
                    image: .iconMetrics,
                    tag: DetailTabTag.History.rawValue
                )
                viewControllers.append(vc)
                break
            }
        }
        
        self.viewControllers = viewControllers
        let pageToOpen = runtimeConfig.getDetailOpenedPage(remoteId: remoteId)
        if (pageToOpen > 0 && pageToOpen < viewControllers.count) {
            self.selectedViewController = viewControllers[pageToOpen]
        }
    }
}

enum DetailTabTag: Int {
    case General = 1
    case Timer = 2
    case History = 3
}
